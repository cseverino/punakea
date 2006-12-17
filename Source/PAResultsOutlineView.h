/* PAResultsOutlineView */

#import <Cocoa/Cocoa.h>
#import "PAResultsGroupCell.h"
#import "PAResultsItemCell.h"
#import "PAResultsBookmarkCell.h"
#import "PAResultsMultiItemCell.h"
#import "PAResultsMultiItemThumbnailCell.h"
#import "PAQuery.h"


typedef enum _PAResultsDisplayMode
{
	PAListMode = 0,
	PAThumbnailMode = 1
} PAResultsDisplayMode;


@interface NSObject (PAResultsOutlineViewDelegate)

- (void)deleteDraggedItems;

@end


@interface PAResultsOutlineView : NSOutlineView
{
	PAQuery					*query;
	PAResultsDisplayMode	displayMode;
	
	// Stores the last up or down arrow function key to get the direction of key navigation
	unsigned int			lastUpDownArrowFunctionKey;
	
	// If not nil, forward keyboard events to responder
	NSView					*responder;
	
	// A collection of selected PAQueryItems. OutlineView stores them for various responders,
	// so that they are able to restore their selection if necessary.
	NSMutableArray			*selectedItems;
}

- (PAQuery *)query;
- (void)setQuery:(PAQuery *)aQuery;

- (unsigned int)lastUpDownArrowFunctionKey;
- (void)setLastUpDownArrowFunctionKey:(unsigned int)key;
- (NSResponder *)responder;
- (void)setResponder:(NSResponder *)aResponder;
- (PAResultsDisplayMode)displayMode;
- (void)setDisplayMode:(PAResultsDisplayMode)mode;

- (void)saveSelection;
- (void)restoreSelection;
- (NSArray *)visibleSelectedItems;

- (NSMutableArray *)selectedItems;
- (void)setSelectedItems:(NSMutableArray *)theItems;

@end
