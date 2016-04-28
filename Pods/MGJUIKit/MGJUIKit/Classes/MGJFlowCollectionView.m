//
//  MGJFlowCollectionView.m
//  Example
//
//  Created by limboy on 2/2/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import "MGJFlowCollectionView.h"
#import <BlocksKit/NSObject+A2DynamicDelegate.h>

@interface MGJHorizontalCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, assign) CGSize itemSize;

@end

@implementation MGJHorizontalCollectionViewLayout
{
    NSInteger _cellCount;
    CGSize _boundsSize;
}

- (void)prepareLayout
{
    // Get the number of cells and the bounds size
    _cellCount = [self.collectionView numberOfItemsInSection:0];
    _boundsSize = self.collectionView.bounds.size;
}

- (CGSize)collectionViewContentSize
{
    // We should return the content size. Lets do some math:
    
    NSInteger verticalItemsCount = (NSInteger)floorf(_boundsSize.height / _itemSize.height);
    NSInteger horizontalItemsCount = (NSInteger)floorf(_boundsSize.width / _itemSize.width);
    
    NSInteger itemsPerPage = verticalItemsCount * horizontalItemsCount;
    NSInteger numberOfItems = _cellCount;
    NSInteger numberOfPages = (NSInteger)ceilf((CGFloat)numberOfItems / (CGFloat)itemsPerPage);
    
    CGSize size = _boundsSize;
    size.width = numberOfPages * _boundsSize.width;
    return size;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    // This method requires to return the attributes of those cells that intsersect with the given rect.
    // In this implementation we just return all the attributes.
    // In a better implementation we could compute only those attributes that intersect with the given rect.
    
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:_cellCount];
    
    for (NSUInteger i=0; i<_cellCount; ++i)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UICollectionViewLayoutAttributes *attr = [self _layoutForAttributesForCellAtIndexPath:indexPath];
        
        [allAttributes addObject:attr];
    }
    
    return allAttributes;
}

- (UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self _layoutForAttributesForCellAtIndexPath:indexPath];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    // We should do some math here, but we are lazy.
    return YES;
}

- (UICollectionViewLayoutAttributes*)_layoutForAttributesForCellAtIndexPath:(NSIndexPath*)indexPath
{
    // Here we have the magic of the layout.
    
    NSInteger row = indexPath.row;
    
    CGRect bounds = self.collectionView.bounds;
    CGSize itemSize = self.itemSize;
    
    // Get some info:
    NSInteger verticalItemsCount = (NSInteger)floorf(bounds.size.height / itemSize.height);
    NSInteger horizontalItemsCount = (NSInteger)floorf(bounds.size.width / itemSize.width);
    NSInteger itemsPerPage = verticalItemsCount * horizontalItemsCount;
    
    // Compute the column & row position, as well as the page of the cell.
    NSInteger columnPosition = row%horizontalItemsCount;
    NSInteger rowPosition = (row/horizontalItemsCount)%verticalItemsCount;
    NSInteger itemPage = floorf(row/itemsPerPage);
    
    // Creating an empty attribute
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGRect frame = CGRectZero;
    
    // And finally, we assign the positions of the cells
    frame.origin.x = itemPage * bounds.size.width + columnPosition * itemSize.width;
    frame.origin.y = rowPosition * itemSize.height;
    frame.size = _itemSize;
    
    attr.frame = frame;
    
    return attr;
}

#pragma mark Properties

- (void)setItemSize:(CGSize)itemSize
{
    _itemSize = itemSize;
    [self invalidateLayout];
}

@end

@implementation MGJFlowCollectionViewBuilder

- (MGJFlowCollectionView *)build
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    // 这里有一个 trick，如果是横向滚动的话，minimumLineSpacing 其实是 minimumInteritemSpacing
    if (self.minimumLineSpacing) {
        layout.minimumLineSpacing = self.scrollDirection == UICollectionViewScrollDirectionHorizontal ? self.minimumInteritemSpacing: self.minimumLineSpacing;
    }
    if (self.minimumInteritemSpacing) {
        layout.minimumInteritemSpacing = self.scrollDirection == UICollectionViewScrollDirectionHorizontal ? self.minimumLineSpacing : self.minimumInteritemSpacing;
    }
    layout.scrollDirection = self.scrollDirection;
    layout.itemSize = self.itemSize;
    layout.sectionInset = self.sectionInset;
    layout.headerReferenceSize = self.headerReferenceSize;
    layout.footerReferenceSize = self.footerReferenceSize;
    Class collectionViewClass = [MGJFlowCollectionView class];
    if (self.collectionViewClass && [self.collectionViewClass isSubclassOfClass:[MGJFlowCollectionView class]]) {
        collectionViewClass = self.collectionViewClass;
    }
    MGJFlowCollectionView *collectionView = [[collectionViewClass alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    
    if (self.dataSource) {
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        
        [collectionView.bk_dynamicDelegate implementMethod:@selector(collectionView:didSelectItemAtIndexPath:) withBlock:^(UICollectionView *collectionView, NSIndexPath *indexPath){
            if (self.cellTapHandler) {
                self.cellTapHandler(indexPath);
            }
        }];
        
        [collectionView.bk_dynamicDataSource implementMethod:@selector(collectionView:numberOfItemsInSection:) withBlock:^NSInteger (UICollectionView *collectionView, NSInteger section){
            return self.dataSource.count;
        }];
        
        [collectionView.bk_dynamicDataSource implementMethod:@selector(collectionView:cellForItemAtIndexPath:) withBlock:^UICollectionViewCell *(UICollectionView *collectionView, NSIndexPath *indexPath){
            UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
            if (self.cellBuilder) {
                [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                [cell.contentView addSubview:self.cellBuilder(self.dataSource[indexPath.row])];
            }
            return cell;
        }];
        
        if (!collectionView.delegate) {
            collectionView.delegate = collectionView.bk_dynamicDelegate;
        }
        if (!collectionView.dataSource) {
            collectionView.dataSource = collectionView.bk_dynamicDataSource;
        }
    }
    
    collectionView.builder = self;
    
    return collectionView;
}

@end

@implementation MGJFlowCollectionView

+ (instancetype)collectionViewWithBuilder:(void (^)(MGJFlowCollectionViewBuilder *builder))block
{
    NSParameterAssert(block);
    
    MGJFlowCollectionViewBuilder *builder = [[MGJFlowCollectionViewBuilder alloc] init];
    block(builder);
    return [builder build];
}

@end
