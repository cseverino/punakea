//
//  PATags.m
//  punakea
//
//  Created by Johannes Hoffart on 18.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATags.h"


@implementation PATags

#pragma mark init + dealloc
- (id)init
{
	if (self = [super init])
	{
		[self setTags:[[NSMutableArray alloc] init]];
		simpleTagFactory = [[PASimpleTagFactory alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[simpleTagFactory release];
	[tags release];
	[super dealloc];
}

#pragma mark accessors
- (NSMutableArray*)tags
{
	return tags;
}

- (void)setTags:(NSMutableArray*)otherTags
{
	[otherTags retain];
	[tags release];
	tags = otherTags;
}

- (void)insertObject:(PATag *)tag inTagsAtIndex:(unsigned int)i
{
	[tags insertObject:tag atIndex:i];
}

- (void)removeObjectFromTagsAtIndex:(unsigned int)i
{
	[tags removeObjectAtIndex:i];
}

#pragma mark additional
- (void)addTag:(PATag*)aTag
{
	[self insertObject:aTag inTagsAtIndex:[tags count]];
}

- (NSEnumerator*)objectEnumerator
{
	return [tags objectEnumerator];
}

- (PASimpleTag*)simpleTagForName:(NSString*)name
{
	BOOL found = NO;
	PASimpleTag *newTag;
	
	//first look through all tags for the specified one
	NSEnumerator *e = [self objectEnumerator];
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		if ([tag isKindOfClass:[PASimpleTag class]] && [name isEqualToString:[tag name]])
		{
			//the tag was found
			found = YES;
			newTag = tag;
		}
	}

	//if the tag wasn't found, create a new one
	if (!found)
	{
		newTag = [simpleTagFactory createTagWithName:name];
		[self addTag:newTag];
	}
	
	return newTag;
}

- (NSArray*)simpleTagsForNames:(NSArray*)names
{
	NSMutableArray *resultArray = [NSMutableArray array];
	
	NSEnumerator *e = [names objectEnumerator];
	NSString *name;
	
	while (name = [e nextObject])
	{
		[resultArray addObject:[self simpleTagForName:name]];
	}
	
	return resultArray;
}

@end
