//
//  MGJFlowCollectionView.h
//  Example
//
//  Created by limboy on 2/2/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CHTCollectionViewWaterfallLayout/CHTCollectionViewWaterfallLayout.h>

@class MGJFlowCollectionView;

@interface MGJFlowCollectionViewBuilder : NSObject
@property (nonatomic) UICollectionViewScrollDirection scrollDirection;
@property (nonatomic) CGFloat minimumLineSpacing;
@property (nonatomic) CGFloat minimumInteritemSpacing;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) UIEdgeInsets sectionInset;
@property (nonatomic) CGSize headerReferenceSize;
@property (nonatomic) CGSize footerReferenceSize;
@property (nonatomic) NSArray *dataSource;
@property (nonatomic, copy) UIView * (^cellBuilder)(id cellData);
@property (nonatomic, copy) void (^cellTapHandler)(NSIndexPath *indexPath);
@property (nonatomic, assign) Class collectionViewClass;

- (MGJFlowCollectionView *)build;
@end

@interface MGJFlowCollectionView : UICollectionView

+ (instancetype)collectionViewWithBuilder:(void (^)(MGJFlowCollectionViewBuilder *builder))block;

@property (nonatomic) MGJFlowCollectionViewBuilder *builder;

@end
