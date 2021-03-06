/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: (null)
 */

#import "UITableViewDelegate.h"
#import "UITableViewDataSource.h"
#import "Music~ipad-Structs.h"
#import <UIKit/UITableView.h>

@class UITapGestureRecognizer;
@protocol MusicGridViewDataSource, MusicGridViewDelegate;

__attribute__((visibility("hidden")))
@interface MusicGridView : UITableView <UITableViewDataSource, UITableViewDelegate> {
	float _gridRowHeight;
	id<MusicGridViewDataSource> _gridViewDataSource;
	id<MusicGridViewDelegate> _gridViewDelegate;
	unsigned _numberOfColumns;
	unsigned _numberOfItems;
	unsigned _lastRowRequested;
	UITapGestureRecognizer *_tapGestureRecognizer;
}
@property(assign, nonatomic) float gridRowHeight;
@property(assign, nonatomic) id<MusicGridViewDataSource> gridViewDataSource;
@property(assign, nonatomic) id<MusicGridViewDelegate> gridViewDelegate;
- (id)initWithFrame:(CGRect)frame style:(int)style;
- (void)_updateGridViewsForTableCell:(id)tableCell atIndexPath:(id)indexPath animated:(BOOL)animated;
- (void)_viewWasTapped:(id)tapped;
- (void)dealloc;
- (unsigned)globalIndexOfViewForIndexPath:(id)indexPath;
- (id)indexPathOfViewForGlobalIndex:(unsigned)globalIndex;
- (int)numberOfSectionsInTableView:(id)tableView;
- (void)reloadData;
- (void)scrollViewWillBeginDragging:(id)scrollView;
- (id)sectionIndexTitlesForTableView:(id)tableView;
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;
- (id)tableView:(id)view cellForRowAtIndexPath:(id)indexPath;
- (CGRect)tableView:(id)view frameForSectionIndexGivenProposedFrame:(CGRect)sectionIndexGivenProposedFrame;
- (int)tableView:(id)view numberOfRowsInSection:(int)section;
- (int)tableView:(id)view sectionForSectionIndexTitle:(id)sectionIndexTitle atIndex:(int)index;
- (id)viewForIndexPath:(id)indexPath;
@end

