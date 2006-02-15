//
//  PATagSet.m
//  punakea
//
//  Created by Johannes Hoffart on 15.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATagSet.h"


@implementation PATagSet

-(id)init {
	return [self initWithTags:nil name:nil];
}

-(id)initWithTags:(NSArray*)newTags {
	return [self initWithTags:newTags name:nil];
}

-(id)initWithName:(NSString*)aName {
	return [self initWithTags:nil name:aName];
}

//designated initializer
-(id)initWithTags:(NSArray*)newTags name:(NSString*)aName {
	self = [super init];
	if (self) {
		if (!newTags) newTags = [NSMutableArray arrayWithObject:nil];
		if (!aName) aName = NSLocalizedString(@"default tagset name","new TagSet");

		tags = [NSArray arrayWithArray:newTags];
		name = [aName copy];
	}
	return self;
}

-(void)dealloc {
	[tags release];
	[name release];
	[super dealloc];
}

@end