//
//  BrowserController.m
//  punakea
//
//  Created by Johannes Hoffart on 04.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BrowserController.h"


@implementation BrowserController

- (id)init
{
	self = [super initWithWindowNibName:@"Browser"];
	return self;
}

- (void)awakeFromNib
{
	[[self window] setFrameAutosaveName:@"punakea.browser"];
	
	browserViewController = [[BrowserViewController alloc] initWithNibName:@"BrowserView"];
	[[self window] setContentView:[browserViewController mainView]];
	
	// insert browserViewController in the responder chain
	[browserViewController setNextResponder:[self window]];
	[[[self window] contentView] setNextResponder:browserViewController];
}

- (BOOL)windowShouldClose:(id)sender
{
	[browserViewController resetBuffer];
	[browserViewController clearSelectedTags:self];
	//TODO waterjoe add reset for your stuff here
}

@end
