//
//  BrowserViewController.m
//  punakea
//
//  Created by Johannes Hoffart on 27.06.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BrowserViewController.h"
#import "PATagCloud.h"

@interface BrowserViewController (PrivateAPI)

- (void)selectedTagsHaveChanged;
- (void)relatedTagsHaveChanged;
- (void)tagsHaveChanged;

- (PATag*)tagWithBestAbsoluteRating:(NSArray*)tagSet;

@end

@implementation BrowserViewController

#pragma mark init + dealloc
- (id)initWithNibName:(NSString*)nibName
{
	if (self = [super init])
	{
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		tagCloudSettings = [[NSMutableDictionary alloc] initWithDictionary:[defaults objectForKey:@"TagCloud"]];
		
		tagger = [PATagger sharedInstance];
		tags = [tagger tags];
				
		selectedTags = [[PASelectedTags alloc] init];
		
		query = [[PAQuery alloc] init];
		[query setBundlingAttributes:[NSArray arrayWithObjects:@"kMDItemContentTypeTree", nil]];
		[query setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:(id)kMDItemFSName ascending:YES] autorelease]]];
		
		relatedTags = [[PARelatedTags alloc] initWithSelectedTags:selectedTags query:query];
		
		typeAheadFind = [[PATypeAheadFind alloc] init];
		
		buffer = [[NSMutableString alloc] init];
		
		nc = [NSNotificationCenter defaultCenter];
		
		[nc addObserver:self 
			   selector:@selector(selectedTagsHaveChanged:) 
				   name:@"PASelectedTagsHaveChanged" 
				 object:selectedTags];
		
		[nc addObserver:self 
			   selector:@selector(relatedTagsHaveChanged:) 
				   name:@"PARelatedTagsHaveChanged" 
				 object:relatedTags];
		
		[nc addObserver:self 
			   selector:@selector(tagsHaveChanged:) 
				   name:@"PATagsHaveChanged" 
				 object:tags];
		
		[self setVisibleTags:[tags tagArray]];
		[typeAheadFind setActiveTags:[tags tagArray]];	
		
		//TODO this stuff should be in the superclass!
		[NSBundle loadNibNamed:nibName owner:self];
	}
	return self;
}

- (void)awakeFromNib
{
	[[[self mainView] window] setInitialFirstResponder:tagCloud];
	[outlineView setQuery:query];
}	

- (void)dealloc
{
	[nc removeObserver:self];
	[visibleTags release];
	[buffer release];
	[typeAheadFind release];
	[relatedTags release];
    [query release];
	[selectedTags release];
	[tagCloudSettings release];
	[super dealloc];
}

#pragma mark accessors
// This method returns a pointer to the view in the nib loaded.
-(NSView*)mainView
{
	return mainView;
}

- (PAQuery*)query 
{
	return query;
}

- (PARelatedTags*)relatedTags;
{
	return relatedTags;
}

- (void)setRelatedTags:(PARelatedTags*)otherRelatedTags
{
	[otherRelatedTags retain];
	[relatedTags release];
	relatedTags = otherRelatedTags;
}

- (PASelectedTags*)selectedTags;
{
	return selectedTags;
}

- (void)setSelectedTags:(PASelectedTags*)otherSelectedTags
{
	[otherSelectedTags retain];
	[selectedTags release];
	selectedTags = otherSelectedTags;
}

- (PATag*)currentBestTag
{
	return currentBestTag;
}

- (void)setCurrentBestTag:(PATag*)otherTag
{
	[otherTag retain];
	[currentBestTag release];
	currentBestTag = otherTag;
}

- (NSMutableString*)buffer
{
	return buffer;
}

- (void)setBuffer:(NSMutableString*)string
{
	[string retain];
	[buffer release];
	buffer = string;
}

- (NSOutlineView *)outlineView
{
	return outlineView;
}

- (void)setOutlineView:(NSOutlineView *)anOutlineView
{
	outlineView = anOutlineView;
}

- (NSMutableArray*)visibleTags;
{
	return visibleTags;
}

- (void)setVisibleTags:(NSMutableArray*)otherTags
{
	if (visibleTags != otherTags)
	{
		[visibleTags release];
		
		NSSortDescriptor *sortDescriptor;
		
		// sort otherTags accorings to userDefaults
		if ([[tagCloudSettings objectForKey:@"sortKey"] isEqualToString:@"name"])
		{
			sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
		}
		else if ([[tagCloudSettings objectForKey:@"sortKey"] isEqualToString:@"rating"])
		{
			sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"absoluteRating" ascending:NO];
		}
		else
		{
			NSLog(@"fatal error, could not sort, specify sortKey in UserDefaults/TagCloud");
		}
		
		NSArray *sortedArray = [otherTags sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		visibleTags = [sortedArray mutableCopy];
	}
	
	if ([visibleTags count] > 0)
		[self setCurrentBestTag:[self tagWithBestAbsoluteRating:visibleTags]];
}


#pragma mark tag stuff
- (PATag*)tagWithBestAbsoluteRating:(NSArray*)tagSet
{
	NSEnumerator *e = [tagSet objectEnumerator];
	PATag *tag;
	PATag *maxTag;
	
	if (tag = [e nextObject])
		maxTag = tag;
	
	while (tag = [e nextObject])
	{
		if ([tag absoluteRating] > [maxTag absoluteRating])
			maxTag = tag;
	}	
	
	return maxTag;
}
- (IBAction)clearSelectedTags:(id)sender
{
	[selectedTags removeAllObjects];
}

- (void)bufferHasChanged
{
	// if buffer has any content, display tags with corresponding prefix
	// else display all tags
	if ([buffer length] > 0)
	{
		[self setVisibleTags:[typeAheadFind tagsForPrefix:buffer]];
	}
	else
	{
		[self setVisibleTags:[typeAheadFind activeTags]];
	}
}

//needs to be called whenever the selected tags have been changed
- (void)selectedTagsHaveChanged:(NSNotification*)notification
{
	if ([buffer length] > 0)
	{
		[self resetBuffer];
	}
	
	//stop an active query
	if ([query isStarted])
	{
		[query stopQuery];
	}
	
	//the query is only started, if there are any tags to look for
	if ([selectedTags count] > 0)
	{
		[query setTags:selectedTags];
		[query startQuery];
		
		// empty visible tags until new related tags are found
		[self setVisibleTags:[NSMutableArray array]];
	}
	else 
	{
		// there are no selected tags, reset all tags
		[self setVisibleTags:[tags tagArray]];
		[typeAheadFind setActiveTags:[tags tagArray]];
	}
}

- (void)relatedTagsHaveChanged:(NSNotification*)notification
{
	if ([buffer length] > 0)
	{
		[self resetBuffer];
	}
	
	[self setVisibleTags:[relatedTags relatedTagArray]];
	[typeAheadFind setActiveTags:[relatedTags relatedTagArray]];
}

- (void)tagsHaveChanged:(NSNotification*)notification
{
	if ([buffer length] > 0)
	{
		[self resetBuffer];
	}
	
	/*only do something if there are no selected tags,
	because then the relatedTags are shown */
	if ([selectedTags count] == 0)
	{
		[self setVisibleTags:[tags tagArray]];
		[typeAheadFind setActiveTags:[tags tagArray]];
	}
}

- (void)resetBuffer
{
	[self setBuffer:[[NSMutableString alloc] initWithString:@""]];
}

#pragma mark events
- (void)keyDown:(NSEvent*)event 
{
	//TODO exclude everything with modifier keys pressed!
	// get the pressed key
	NSLog(@"BVC keyDown: %x", [[event characters] characterAtIndex:0]);
	unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
	
	// create character set for testing
	NSCharacterSet *alphanumericCharacterSet = [NSCharacterSet alphanumericCharacterSet];
	
	if (key == NSDeleteCharacter) 
	{
		// if buffer has any content (i.e. user is using type-ahead-find), delete last char
		if ([buffer length] > 0)
		{
			NSRange range = NSMakeRange([buffer length] - 1,1);
			[buffer deleteCharactersInRange:range];
			[self bufferHasChanged];
		}
		else if ([selectedTags count] > 0)
		// else delete the last selected tag
		{
			[selectedTags removeLastTag];
		}
	}
	else if ([alphanumericCharacterSet characterIsMember:key]) 
	{
		// only add to buffer if there are any tags, otherwise do nothing
		NSMutableString *tmpBuffer = [buffer mutableCopy];
		[tmpBuffer appendString:[event charactersIgnoringModifiers]];
		
		if ([typeAheadFind hasTagsForPrefix:tmpBuffer])
		{
			[buffer appendString:[event charactersIgnoringModifiers]];
			[self bufferHasChanged];
		}
		else
		{
			// TODO give user negative feedback
		}
		
		[tmpBuffer release];
	}
	else
	{
		// forward unhandled events
		[[self nextResponder] keyDown:event];
	}
}

#pragma mark Temp
- (void)setGroupingAttributes:(id)sender;
{
	NSSegmentedControl *sc = sender;
	if([sc selectedSegment] == 0) {
		[query setBundlingAttributes:[NSArray arrayWithObjects:@"kMDItemContentTypeTree", nil]];
	}
	if([sc selectedSegment] == 1) {
		[query setBundlingAttributes:[NSArray arrayWithObjects:nil]];
	}
}

@end
