//
//  MGJMasonryCollectionView.m
//  
//
//  Created by limboy on 2/2/15.
//
//

#import "MGJMasonryCollectionView.h"
#import <CHTCollectionViewWaterfallLayout/CHTCollectionViewWaterfallLayout.h>
#import <objc/runtime.h>

@interface MGJMasonryCollectionView () <UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout>
@property (nonatomic) NSDictionary *cellIdentifiersAndClasses;
@property (nonatomic, copy) CellCountBlock cellCountBlock;
@property (nonatomic, copy) CellSizeBlock cellSizeBlock;
@property (nonatomic, copy) CellForItemAtIndexPathBlock cellForItemAtIndexPathBlock;
@property (nonatomic, copy) CellDidSelectedBlock cellDidSelectedBlock;
@end

@implementation MGJMasonryCollectionViewBuilder

- (MGJMasonryCollectionView *)build
{
    NSAssert(self.cellIdentifiersAndClasses, @"cellIdentifiersAndClasses 不能少哦");
    NSAssert(self.cellCountBlock, @"cellCountBlock 不能少哦");
    NSAssert(self.cellSizeBlock, @"cellSizeBlock 不能少哦");
    NSAssert(self.cellForItemAtIndexPathBlock, @"cellForItemAtIndexPathBlock 不能少哦");
    
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    if (self.minimumColumnSpacing) {
        layout.minimumColumnSpacing = self.minimumColumnSpacing;
    }
    if (self.minimumInteritemSpacing) {
        layout.minimumInteritemSpacing = self.minimumInteritemSpacing;
    }
    if (self.columnCount) {
        layout.columnCount = self.columnCount;
    }
    if (self.headerHeight) {
        layout.headerHeight = self.headerHeight;
    }
    if (self.footerHeight) {
        layout.footerHeight = self.footerHeight;
    }
    if (self.sectionInset.top || self.sectionInset.right || self.sectionInset.left || self.sectionInset.bottom) {
        layout.sectionInset = self.sectionInset;
    }
    
    Class collectionViewClass = [MGJMasonryCollectionView class];
    if (self.collectionViewClass && [self.collectionViewClass isSubclassOfClass:[MGJMasonryCollectionView class]]) {
        collectionViewClass = self.collectionViewClass;
    }
    
    MGJMasonryCollectionView *collectionView = [[collectionViewClass alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.alwaysBounceVertical = YES;
    collectionView.delegate = collectionView;
    collectionView.dataSource = collectionView;
    
    [self.cellIdentifiersAndClasses enumerateKeysAndObjectsUsingBlock:^(NSString *key, Class klass, BOOL *stop) {
        NSAssert(class_isMetaClass(object_getClass(klass)), @"value 的类型必须是 Class");
        [collectionView registerClass:klass forCellWithReuseIdentifier:key];
    }];
    
    collectionView.cellCountBlock = self.cellCountBlock;
    collectionView.cellSizeBlock = self.cellSizeBlock;
    collectionView.cellForItemAtIndexPathBlock = self.cellForItemAtIndexPathBlock;
    if (self.cellDidSelectedBlock) {
        collectionView.cellDidSelectedBlock = self.cellDidSelectedBlock;
    }
    return collectionView;
}

@end

@implementation MGJMasonryCollectionView

+ (instancetype)collectionViewWithBuilder:(void (^)(MGJMasonryCollectionViewBuilder *builder))block
{
    NSParameterAssert(block);
    
    MGJMasonryCollectionViewBuilder *builder = [[MGJMasonryCollectionViewBuilder alloc] init];
    block(builder);
    return [builder build];
}

#pragma mark - Synthesizer

- (void)setItems:(NSArray *)items
{
    if (_items != items) {
        _items = items;
        [self reloadData];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.cellCountBlock(collectionView, self.items);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellForItemAtIndexPathBlock(collectionView, indexPath, self.items);
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellSizeBlock(collectionView, indexPath, self.items);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDidSelectedBlock) {
        self.cellDidSelectedBlock(collectionView, indexPath, self.items);
    }
}

@end
