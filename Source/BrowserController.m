//
//  BrowserController.m
//  punakea
//
//  Created by Johannes Hoffart on 04.07.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "BrowserController.h"

@implementation BrowserController

#pragma mark Init + Dealloc
- (id)init
{
	if (self = [super initWithWindowNibName:@"Browser"])
	{
		// nothing
	}	
	return self;
}

- (void)awakeFromNib
{
	// this keeps the windowcontroller from auto-placing the window
	// - window is always opened where it was closed
	[self setShouldCascadeWindows:NO];
	
	[[self window] setFrameAutosaveName:@"punakea.browser"];
	
	browserViewController = [[BrowserViewController alloc] init];
	[verticalSplitView replaceSubview:mainPlaceholderView with:[browserViewController view]];
	
	// insert browserViewController in the responder chain
	[browserViewController setNextResponder:[self window]];
	[[[self window] contentView] setNextResponder:browserViewController];
	
	// Setup status bar for source panel
	PASimpleStatusBarButton *sbitem = [PASimpleStatusBarButton statusBarButton];
	[sbitem setToolTip:@"Add favorite"];
	[sbitem setImage:[NSImage imageNamed:@"statusbar-button-plus"]];
	[sbitem setAlternateImage:[NSImage imageNamed:@"statusbar-button-gear"]];
	[sourcePanelStatusBar addItem:sbitem];
	
	sbitem = [PASimpleStatusBarButton statusBarButton];
	[sourcePanelStatusBar addItem:sbitem];
}

- (void)dealloc
{
	// unbind stuff for retain count
	[browserViewController release];
	[super dealloc];
}


#pragma mark Events
- (void)flagsChanged:(NSEvent *)theEvent
{
	if ([theEvent modifierFlags] & NSAlternateKeyMask) {
		[sourcePanelStatusBar setAlternateState:YES];
	} else {
		[sourcePanelStatusBar setAlternateState:NO];
	}
}


#pragma mark SplitView Delegate
- (float)splitView:(NSSplitView *)sender constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)offset
{
	if([sender isEqualTo:verticalSplitView])
	{
		if(offset == 0) return 120.0;
	}
	else
	{
		// handle horizontal split view
	}
	
	return nil;
}

- (float)splitView:(NSSplitView *)sender constrainMaxCoordinate:(float)proposedMin ofSubviewAt:(int)offset
{
	if([sender isEqualTo:verticalSplitView])
	{
		if(offset == 0) return [sender frame].size.width - [self splitView:sender constrainMinCoordinate:0.0 ofSubviewAt:0];
	}
	else
	{
		// handle horizontal split view
	}
	
	return nil;
}


#pragma mark Notifications
- (void)windowWillClose:(NSNotification *)aNotification
{
	[browserViewController unbindAll];
	[self autorelease];
}


#pragma mark Accessors
- (BrowserViewController*)browserViewController
{
	return browserViewController;
}

@end
