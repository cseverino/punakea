//
//  PASidebarTableView.m
//  punakea
//
//  Created by Johannes Hoffart on 26.08.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PASidebarTableView.h"


@implementation PASidebarTableView

- (void)awakeFromNib
{
	[self setBackgroundColor:[NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:0.85]];
}

#pragma mark drag'n'drop
/**
only works if parent window is a PASidebar
 */
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender 
{
	[[self window] mouseEvent];
	return NSDragOperationNone;
}

/**
only works if parent window is a PASidebar
 */
- (void)draggingExited:(id <NSDraggingInfo>)sender 
{
	[[self window] mouseEvent];
}

#pragma mark drawing
// do not use default highlight on clicking
-(id)_highlightColorForCell:(NSCell *)cell
{
	return [NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:0.85];
}

// draw black border on drop TODO
-(void)_drawDropHighlightOnRow:(NSInteger)rowIndex 
{
	NSRect cellFrame = [self frameOfCellAtColumn:0 row:rowIndex];
	
	NSBezierPath *bezel = [NSBezierPath bezierPathWithRoundRectInRect:cellFrame radius:20.0];
	[bezel setLineWidth:1.1];
	[[NSColor blackColor] set];
	[bezel stroke];
}

@end
