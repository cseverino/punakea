//
//  PASelectedTagsView.h
//  punakea
//
//  Created by Johannes Hoffart on 31.03.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAFilterSlice.h"
#import "PAResultsOutlineView.h"
#import "PAResultsViewController.h"
#import "NNTagging/NNTag.h"
#import "NNTagging/NNSelectedTags.h"
#import "PAButton.h"
#import "PAImageButton.h"

extern NSSize const PADDING;
extern NSSize const INTERCELL_SPACING;
extern NSInteger const PADDING_TO_RIGHT;

@interface PASelectedTagsView : NSView {
	
	IBOutlet PAResultsOutlineView		*outlineView;
	IBOutlet PAFilterSlice				*filterSlice;
	IBOutlet PAResultsViewController	*controller;
	NNSelectedTags						*selectedTags;
	
	NSMutableDictionary					*tagButtons;
	
	BOOL								ignoreFrameDidChange;
	
	PAImageButton						*homeButton;
	
}

- (void)updateTagButtons:(NSNotification *)notification;

- (void)tagClicked:(id)sender;
- (void)tagClosed:(id)sender;

@end
