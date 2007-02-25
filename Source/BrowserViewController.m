//
//  BrowserViewController.m
//  punakea
//
//  Created by Johannes Hoffart on 27.06.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "BrowserViewController.h"
#import "PATagCloud.h"


float const SPLITVIEW_PANEL_MIN_HEIGHT = 150.0;


@interface BrowserViewController (PrivateAPI)

- (void)tagsHaveChanged;

- (NSMutableArray*)visibleTags;
- (void)setVisibleTags:(NSMutableArray*)otherTags;

- (NNTag*)tagWithBestAbsoluteRating:(NSArray*)tagSet;

- (NNTag*)currentBestTag;
- (void)setCurrentBestTag:(NNTag*)otherTag;

- (void)showTypeAheadView;
- (void)hideTypeAheadView;

- (NSString*)buffer;
- (void)setBuffer:(NSString*)string;
- (void)resetBuffer;
- (void)bufferHasChanged;

- (void)setMainController:(PABrowserViewMainController*)aController;

- (PABrowserViewControllerState)state;
- (void)setState:(PABrowserViewControllerState)aState;

- (void)updateSortDescriptor;

@end

@implementation BrowserViewController

#pragma mark init + dealloc
- (id)init
{
	if (self = [super init])
	{
 		[self setState:PABrowserViewControllerNormalState];
		
		tags = [NNTags sharedTags];
				
		typeAheadFind = [[PATypeAheadFind alloc] init];
		
		buffer = [[NSMutableString alloc] init];
		
		[self addObserver:self forKeyPath:@"buffer" options:nil context:NULL];
	
		sortKey = [[NSUserDefaults standardUserDefaults] integerForKey:@"TagCloud.SortKey"];
		[self updateSortDescriptor];
		
		[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self 
																  forKeyPath:@"values.TagCloud.SortKey" 
																	 options:0 
																	 context:NULL];
		
		[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self 
																  forKeyPath:@"values.TagCloud.ClickCountWeight" 
																	 options:0 
																	 context:NULL];
		
		
		[self setVisibleTags:[tags tags]];
		[typeAheadFind setActiveTags:[tags tags]];

		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(tagsHaveChanged:) 
													 name:NNTagsHaveChangedNotification
												   object:tags];
		
		[NSBundle loadNibNamed:@"BrowserView" owner:self];
	}
	return self;
}

- (void)awakeFromNib
{
	[searchField setEditable:NO];
	[self showResults];
	[[[self view] window] setInitialFirstResponder:tagCloud];
}	

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self
																 forKeyPath:@"values.TagCloud.SortKey"];
	[[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self
																 forKeyPath:@"values.TagCloud.ClickCountWeight"];
	
	[sortDescriptor release];
	[mainController release];
	[visibleTags release];
	[buffer release];
	[typeAheadFind release];
	[super dealloc];
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath isEqualToString:@"buffer"])
	{
		[self bufferHasChanged];
	}
	else if ([keyPath isEqual:@"values.TagCloud.SortKey"])
	{
		sortKey = [[[NSUserDefaultsController sharedUserDefaultsController] valueForKeyPath:@"values.TagCloud.SortKey"] intValue];
		[self updateSortDescriptor];
		NSMutableArray *currentVisibleTags = [visibleTags mutableCopy];
		[self setVisibleTags:currentVisibleTags];
		[currentVisibleTags release];
	}
	else if ([keyPath isEqualToString:@"values.TagCloud.ClickCountWeight"])
	{
		[self reset];
	}
}

#pragma mark accessors
- (PABrowserViewControllerState)state
{
	return state;
}

- (void)setState:(PABrowserViewControllerState)aState
{
	state = aState;
}

- (NNTag*)currentBestTag
{
	return currentBestTag;
}

- (void)setCurrentBestTag:(NNTag*)otherTag
{
	[otherTag retain];
	[currentBestTag release];
	currentBestTag = otherTag;
}

- (NSString*)buffer
{
	return buffer;
}

- (void)setBuffer:(NSString*)string
{
	if (!string)
		string = @"";
	
	[buffer release];
	buffer = [string mutableCopy];
}

- (PABrowserViewMainController*)mainController
{
	return mainController;
}

- (void)setMainController:(PABrowserViewMainController*)aController
{
	[aController retain];
	[mainController release];

	mainController = aController;
	
	[mainController setDelegate:self];
	[mainController setNextResponder:self];
	
	// remove all subviews
	NSArray *subviews = [controlledView subviews];
	NSEnumerator *e = [subviews objectEnumerator];
	NSView *subview;

	while (subview = [e nextObject])
	{
		[subview removeFromSuperview];
	}
	
	[controlledView addSubview:[mainController view]];
}

- (NSView*)controlledView
{
	return controlledView;
}

- (BOOL)isWorking
{
	if (!mainController || ![mainController isWorking])
		return NO;
	else
		return YES;
}

- (NSMutableArray*)visibleTags;
{
	return visibleTags;
}

- (void)setVisibleTags:(NSMutableArray*)otherTags
{
	[visibleTags release];
			
	NSArray *sortedArray = [otherTags sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	visibleTags = [sortedArray mutableCopy];
	
	if ([visibleTags count] > 0)
		[self setCurrentBestTag:[self tagWithBestAbsoluteRating:visibleTags]];
}

- (void)setDisplayTags:(NSMutableArray*)someTags
{
	if ([self state] == PABrowserViewControllerTypeAheadFindState)
		[self resetBuffer];
	
	[self setState:PABrowserViewControllerMainControllerState];
	[self setVisibleTags:someTags];
	[typeAheadFind setActiveTags:someTags];
}

- (void)resetDisplayTags
{
	if ([self state] == PABrowserViewControllerTypeAheadFindState)
		[self resetBuffer];
	
	[self setState:PABrowserViewControllerNormalState];
	[self setVisibleTags:[tags tags]];
	[typeAheadFind setActiveTags:[tags tags]];
	[[[self view] window] makeFirstResponder:tagCloud];
}

- (void)displaySelectedTag:(NNTag*)tag
{
	[tagCloud selectTag:tag];
}

- (void)removeActiveTagButton
{
	[tagCloud removeActiveTagButton];
}

#pragma mark tag stuff
- (IBAction)tagButtonClicked:(id)sender
{
	NNTag *tag = [sender genericTag];
	[mainController handleTagActivation:tag];
}

- (IBAction)findFieldAction:(id)sender
{
	PATagButton *button = [tagCloud activeButton];
	
	if (button)
	{
		[self tagButtonClicked:button];
	}
}

- (NNTag*)tagWithBestAbsoluteRating:(NSArray*)tagSet
{
	NSEnumerator *e = [tagSet objectEnumerator];
	NNTag *tag;
	NNTag *maxTag;
	
	if (tag = [e nextObject])
		maxTag = tag;
	
	while (tag = [e nextObject])
	{
		if ([tag absoluteRating] > [maxTag absoluteRating])
			maxTag = tag;
	}	
	
	return maxTag;
}

#pragma mark typeAheadFind
- (void)showTypeAheadView
{
	float height = NSHeight([typeAheadView frame]);
	NSScrollView *sv = [tagCloud enclosingScrollView];
	// placed above
	[sv setFrame:NSMakeRect(0,NSMinY([sv frame]),NSWidth([sv frame]),NSHeight([sv frame])-height)];
	[tagCloud setNeedsDisplay:YES];
	
	[typeAheadView setHidden:NO];
	[self setState:PABrowserViewControllerTypeAheadFindState];
}

- (void)hideTypeAheadView
{
	float height = NSHeight([typeAheadView frame]);
	NSScrollView *sv = [tagCloud enclosingScrollView];
	// placed above
	[sv setFrame:NSMakeRect(0,NSMinY([sv frame]),NSWidth([sv frame]),NSHeight([sv frame])+height)];
	[tagCloud setNeedsDisplay:YES];
	
	[typeAheadView setHidden:YES];	
	[self setState:PABrowserViewControllerNormalState];
}

- (void)resetBuffer
{
	[self setBuffer:@""];
}

#pragma mark events
- (void)keyDown:(NSEvent*)event 
{
	// get the pressed key
	unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
	
	// create character set for testing
	NSCharacterSet *alphanumericCharacterSet = [NSCharacterSet alphanumericCharacterSet];
	
	if (key == NSDeleteCharacter) 
	{
		// if buffer has any content (i.e. user is using type-ahead-find), delete last char
		if ([buffer length] > 0)
		{
			NSString *tmpBuffer = [buffer substringToIndex:[buffer length]-1];
			[self setBuffer:tmpBuffer];
		}
		else if ([mainController isKindOfClass:[PAResultsViewController class]])
		// else delete the last selected tag (if resultsview is active)
		{
			[(PAResultsViewController*)mainController removeLastTag];
		}
	}
	// handle escape key (27)
	else if (key == 27)
	{
		[self reset];
	}
	else if ([alphanumericCharacterSet characterIsMember:key]) 
	{
		// only add to buffer if there are any tags, otherwise do nothing
		NSMutableString *tmpBuffer = [buffer mutableCopy];
		[tmpBuffer appendString:[event charactersIgnoringModifiers]];
		
		if ([typeAheadFind hasTagsForPrefix:tmpBuffer])
		{
			[self setBuffer:tmpBuffer];
		}
		else
		{
			[[self nextResponder] keyDown:event];
		}
		
		[tmpBuffer release];
	}
	else
	{
		// forward unhandled events
		[[self nextResponder] keyDown:event];
	}
}

- (void)bufferHasChanged
{
	// if buffer has any content, display tags with corresponding prefix
	// else display all tags
	if ([buffer length] > 0)
	{
		if ([typeAheadView isHidden])
		{
			[self showTypeAheadView];
		}
		[self setVisibleTags:[typeAheadFind tagsForPrefix:buffer]];
		[tagCloud selectUpperLeftButton];
	}
	else
	{
		if (![typeAheadView isHidden])
		{
			[self hideTypeAheadView];
			[self setVisibleTags:[typeAheadFind activeTags]];
			[[tagCloud window] makeFirstResponder:tagCloud];
		}
	}
}

- (void)tagsHaveChanged:(NSNotification*)notification
{
	NSString *changeOperation = [[notification userInfo] objectForKey:NNTagOperation];
	
	if ([self state] == PABrowserViewControllerNormalState)
	{
		if ([changeOperation isEqualToString:NNTagUseChangeOperation])
		{
			[NSObject cancelPreviousPerformRequestsWithTarget:self
													 selector:@selector(setVisibleTags:)
													   object:[tags tags]];
			[self performSelector:@selector(setVisibleTags:)
					   withObject:[tags tags]
					   afterDelay:0.2];
		}
		else
		{
			[self setVisibleTags:[tags tags]];
		}
	}
}

- (void)controlledViewHasChanged
{	
	// resize controlledView to content subview
	NSView *subview = [[controlledView subviews] objectAtIndex:0];
	NSRect subviewFrame = [subview frame];
	NSRect oldFrame = [controlledView frame];
	[subview setFrame:NSMakeRect(0.0,0.0,oldFrame.size.width,oldFrame.size.height)];
	[controlledView setFrame:NSMakeRect(0.0,0.0,oldFrame.size.width,subviewFrame.size.height)];
	[splitView adjustSubviews];
}

#pragma mark actions
- (void)searchForTag:(NNTag*)aTag
{
	[[self mainController] handleTagActivation:aTag];
}

- (void)manageTags
{
	if ([[self mainController] isKindOfClass:[PATagManagementViewController class]])
	{
		return;
	}
	else
	{
		PATagManagementViewController *tmvController = [[PATagManagementViewController alloc] init];
		[self switchMainControllerTo:tmvController];
		[tmvController release];
	}
}

- (void)showResults
{
	if ([[self mainController] isKindOfClass:[PAResultsViewController class]])
	{
		return;
	}
	else
	{
		PAResultsViewController *rvController = [[PAResultsViewController alloc] init];
		[self switchMainControllerTo:rvController];
		[rvController release];
	}
}

- (void)switchMainControllerTo:(PABrowserViewMainController*)controller
{
	[self resetBuffer];
	[[[self view] window] makeFirstResponder:tagCloud];
	[self setMainController:controller];
}

- (void)reset
{
	[self showResults];
	[mainController reset];
}

- (void)unbindAll
{
	[self removeObserver:tagCloud forKeyPath:@"visibleTags"];
	[self removeObserver:self forKeyPath:@"buffer"];
	[searchField unbind:@"value"];
}

- (void)makeControlledViewFirstResponder
{
	[[[self view] window] makeFirstResponder:[mainController dedicatedFirstResponder]];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	NSDictionary *userInfo = [aNotification userInfo];
	NSText *fieldEditor = [userInfo objectForKey:@"NSFieldEditor"];
	NSString *currentString = [fieldEditor string];
	
	if ([currentString isNotEqualTo:@""] && ![typeAheadFind hasTagsForPrefix:currentString])
	{
		NSString *newString = [currentString substringToIndex:[currentString length]-1];
		[fieldEditor setString:newString];
	}
}

#pragma mark drag & drop stuff
- (void)taggableObjectsHaveBeenDropped:(NSArray*)objects
{
	TaggerController *taggerController = [[TaggerController alloc] init];
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	NSWindow *taggerWindow = [taggerController window];
	[taggerWindow makeKeyAndOrderFront:nil];
	[taggerController addTaggableObjects:objects];
}


#pragma mark Split View
- (float)splitView:(NSSplitView *)sender constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)offset
{
	return SPLITVIEW_PANEL_MIN_HEIGHT;
}

- (float)splitView:(NSSplitView *)sender constrainMaxCoordinate:(float)proposedMax ofSubviewAt:(int)offset
{
	NSRect frame = [sender frame];
	return frame.size.height - SPLITVIEW_PANEL_MIN_HEIGHT;
}

#pragma mark sorting
- (void)updateSortDescriptor
{
	[sortDescriptor release];
	
	// sort otherTags accorings to userDefaults
	if (sortKey == PATagCloudNameSortKey)
	{
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	}
	else if (sortKey == PATagCloudRatingSortKey)
	{
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"absoluteRating" ascending:NO];
	}
	else
	{
		// default to name
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	}
}

#pragma mark temp
- (NNTags*)tags
{
	return tags;
}

@end
