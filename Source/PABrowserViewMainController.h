//
//  PABrowserViewMainController.h
//  punakea
//
//  Created by Johannes Hoffart on 24.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATag.h"
#import "PAViewController.h"

@interface PABrowserViewMainController : PAViewController {
	IBOutlet NSView *currentView;
	
	id delegate;
	BOOL working;
}

- (NSView*)mainView;
- (NSView*)currentView;
- (void)setCurrentView:(NSView*)aView;

- (void)handleTagActivation:(PATag*)tag;
- (id)delegate;
- (void)setDelegate:(id)anObject;
- (BOOL)isWorking;
- (void)setWorking:(BOOL)flag;

/** is called when reset is needed
	(handle escape key reset here)
	default does nothing
	*/
- (void)reset; 

@end