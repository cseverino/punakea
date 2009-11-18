/* PAResultsOutlineView */

#import <Cocoa/Cocoa.h>
#import "PAResultsGroupCell.h"
#import "PAResultsItemCell.h"
#import "PAResultsBookmarkCell.h"
#import "PAResultsMultiItemCell.h"
#import "PAResultsMultiItemThumbnailCell.h"
#import "NNTagging/NNQuery.h"
#import "QuickLook.h";


@class PAResultsMultiItemMatrix;


/** Notification is posted when the selection changed.
	userInfo dictionary: Key "SelectedItems" contains the current selection */
extern NSString *PAResultsOutlineViewSelectionDidChangeNotification;


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
	NNQuery							*query;
	PAResultsDisplayMode			displayMode;
			
	// Stores the last up or down arrow function key to get the direction of key navigation
	NSUInteger					lastUpDownArrowFunctionKey;
	
	// If not nil, forward keyboard events to responder
	PAResultsMultiItemMatrix		*responder;
	
	// A collection of selected NNTaggableObjects. OutlineView stores them for various responders,
	// so that they are able to restore their selection if necessary.
	NSMutableArray					*selectedItems;
	
	BOOL							skipSaveSelection;				/**< Indicates that OutlineView should not save its selection. */
}

- (NNQuery *)query;
- (void)setQuery:(NNQuery *)aQuery;

- (NSUInteger)lastUpDownArrowFunctionKey;
- (void)setLastUpDownArrowFunctionKey:(NSUInteger)key;
- (NSResponder *)responder;
- (void)setResponder:(NSResponder *)aResponder;
- (PAResultsDisplayMode)displayMode;
- (void)setDisplayMode:(PAResultsDisplayMode)mode;

- (void)saveSelection;
- (void)restoreSelection;

- (void)addSelectedItem:(NNTaggableObject *)item;
- (void)removeSelectedItem:(NNTaggableObject *)item;

- (NSUInteger)numberOfSelectedItems;

- (NSArray *)selectedItems;
- (void)setSelectedItems:(NSArray *)theItems;

- (BOOL)isEditingRow:(NSInteger)row;

@end
