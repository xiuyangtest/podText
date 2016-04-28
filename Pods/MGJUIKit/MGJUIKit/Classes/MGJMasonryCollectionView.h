//
//  MGJMasonryCollectionView.h
//  
//
//  Created by limboy on 2/2/15.
//
//

#import <UIKit/UIKit.h>

/**
 *  这个 Collection View 有多少个 Cell
 *
 *  @param collectionView 当前这个 CollectionView
 *  @param items          数据源
 *
 *  @return
 */
typedef NSInteger(^CellCountBlock)(UICollectionView *collectionView, NSArray *items);

/**
 *  每个 Cell 的 Size 是多少
 *
 *  @param collectionView 当前这个 CollectionView
 *  @param indexPath      使用 indexPath.row 即可，因为 section 总是为 0
 *  @param items          数据源
 *
 *  @return
 */
typedef CGSize(^CellSizeBlock)(UICollectionView *collectionView, NSIndexPath *indexPath, NSArray *items);

/**
 *  对应 DataSource 的 `collectionView:cellForItemAtIndexPath:`
 *
 *  @param collectionView 当前这个 CollectionView
 *  @param indexPath      使用 indexPath.row 即可，因为 section 总是为 0
 *  @param items          数据源
 *
 *  @return
 */
typedef UICollectionViewCell *(^CellForItemAtIndexPathBlock)(UICollectionView *collectionView, NSIndexPath *indexPath, NSArray *items);

/**
 *  对应 Delegate 的 `collectionView:didSelectItemAtIndexPath:`
 *
 *  @param collectionView 当前这个 CollectionView
 *  @param indexPath      使用 indexPath.row 即可，因为 section 总是为 0
 *  @param items          数据源
 */
typedef void(^CellDidSelectedBlock)(UICollectionView *collectionView, NSIndexPath *indexPath, NSArray *items);

@class MGJMasonryCollectionView;

@interface MGJMasonryCollectionViewBuilder : NSObject
@property (nonatomic, assign) NSInteger columnCount;
@property (nonatomic, assign) CGFloat minimumColumnSpacing;
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat footerHeight;
@property (nonatomic, assign) UIEdgeInsets sectionInset;
@property (nonatomic, assign) Class collectionViewClass;

/**
 *  用来注册 cell class
 *  key 是 identifier，value 是对应的 class，如 @{@"cell", [UIColllectionViewCell class]}
 */
@property (nonatomic) NSDictionary *cellIdentifiersAndClasses;
@property (nonatomic, copy) CellCountBlock cellCountBlock;
@property (nonatomic, copy) CellSizeBlock cellSizeBlock;
@property (nonatomic, copy) CellForItemAtIndexPathBlock cellForItemAtIndexPathBlock;
@property (nonatomic, copy) CellDidSelectedBlock cellDidSelectedBlock;

- (MGJMasonryCollectionView *)build;
@end

@interface MGJMasonryCollectionView : UICollectionView

+ (instancetype)collectionViewWithBuilder:(void (^)(MGJMasonryCollectionViewBuilder *builder))block;

/**
 *  这个 CollectionView 的数据源，只要改变这个值，就会自动 reloadData
 */
@property (nonatomic) NSArray *items;

@end
