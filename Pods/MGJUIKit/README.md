## 关于 MGJUIKIT

MGJUIKit 是对 UIKit 的一些增强，方便对 UI 的处理

### Categories

#### SVPullToRefresh
MGJUIKit 内置了 SVPullToRefresh，原有的接口保持不变，添加了新的接口，可以对处于 loading 状态的 indicator 做一些动画效果。

#### UIImageView+MGJKit
添加 image 时，可以加个动画效果 (fadeIn)。

#### UIButton+MGJKit
可以像使用 UIImage 一样，使用图片名来初始化 Button。

#### UIColor+MGJKit
可以使用 16 进制的色值来生成 Color，以及生成随机的颜色。

#### UIImage+MGJKit
可以根据某种颜色生成 UIImage，并指定尺寸。

#### UIView+MGJKit
可以遍历 subviews 来找到符合条件的 subview。

### Classes

#### MGJFlowCollectionView
可以生成横向的或纵向的包含某种特定 Item 的 CollectionView，比如主客的「买买买」页面的「当季爆款」。
使用起来也很方便哦。

#### MGJMasonryCollectionView
可以生成高度不一致的一列或多列瀑布流。
使用起来也很方便哦。
