### 更新时间
2016-1-6

### 这是什么
网络图片加载相关。

### 如何使用
#### 如何安装
```ruby
pod 'MGJImage', '~> 0.2.10'
```
#### 依赖项
```
spec.dependency 'MGJFoundation'
spec.dependency 'MGJ-Categories'
spec.dependency 'SDWebImage/WebP', '~> 3.7.3'
```
### 详细文档
#### MGJImageAdapter
1. 图片规则格式
```json
[
  {
    "size":320,//规则尺寸
    "wwan"://运营商网络
    {
      "extention":"webp",//图片格式
      "quality":70,//质量参数
    },
    "wifi":
    {
      "extention":"webp",
      "quality":81
    }
  }，
  ...
]
```

`size` 字段表示图片规则对应的尺寸。每个尺寸存在方图以及按比例缩放两种图片。匹配时根据目标大小，找到规则中最相近的一条，然后根据网络情况，拼接出相应的图片地址。

2. 设置图片规则
```objective-c
[[MGJImageAdapter sharedInstance] updateRules:imageRules];
```
3. 获取匹配图片规则后的 URL

```objective-c

//此时会根据传入的尺寸、网络情况去计算
[[MGJImageAdapter sharedInstance] adaptImageURL:@"http://s11.mogucdn.com/p1/151015/1h9455_ie2domjxmq2wimbugqzdambqgiyde_640x960.jpg_220x220.webp" toSize:220 needCrop:YES];

```

#### UIImageView+MGJImage/UIButton+MGJImage
**传入目标尺寸、切图方式**

前后端分离项目以后，接口返回的图片地址不会带缩略图尺寸，必须使用以下方法。

```objective-c
- (void)mgj_setImageWithURL:(NSString *)url expectedSize:(NSInteger)expectedSize needCrop:(BOOL)needCrop placeholderImage:(UIImage *)placeholder;
- (void)mgj_setBackgroundImageWithURL:(NSURL *)url expectedSize:(NSInteger)expectedSize needCrop:(BOOL)needCrop forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock;
- (void)mgj_setImageWithURL:(NSURL *)url expectedSize:(NSInteger)expectedSize needCrop:(BOOL)needCrop forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock;

```
当传入目标尺寸和切图方式时，会忽略 URL 中的缩略图尺寸，直接使用传入的值进行匹配。needCrop 为 `YES` 则匹配方图，`NO` 匹配根据宽自适应的图。

#### 调试模式
图片尺寸需要 CDN 添加后才能使用，因此提供了测试模式，会将 URL 替换为测试服务器地址。

```objective-c
[MGJImageConfigManager enableDebugModeForImageAdapter:YES];
```
### 如何反馈
@昆卡
