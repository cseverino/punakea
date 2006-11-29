//
//  PAControlledView.h
//  punakea
//
//  Created by Johannes Hoffart on 17.10.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSObject (PAControlledViewAdditions)

- (void)controlledViewHasChanged;

@end


@interface PAControlledView : NSView {
	id delegate;
}

@end
