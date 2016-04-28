## 关于 MGJFoundation

MGJFoundation 提供了一些方便使用的 Category 和 Class，可以提高开发效率。

### Macro

MGJMacro.h 提供了一些常用的宏定义，如检查是否为空的 `MGJ_IS_EMPTY`, 检查系统版本 `SYSTEM_VERSION_EQUAL_TO`，获取屏幕宽度的 `MGJ_SCREENWIDTH` 等。


### Categories

Categories 对系统原有的类做了些增强，主要是一些经常会用到，又跟业务没什么关系的方法

#### NSObject+MGJKit

主要方法

```
- (void)mgj_associateValue:(id)value withKey:(void *)key;
- (id)mgj_associatedValueForKey:(void *)key;
```

#### NSObject+MGJSingleton

这个 Category 可以让单例写起来更加方便，只要声明实现 `<Singleton>` 协议，然后调用 `[YourClass mgj_sharedInstance]` 即可。

#### NSDate+MGJKit

这个 Category，提供了很多处理日期相关的方法，比如日期的比较、加减，是否是今天等等。

#### NSString+MGJKit

这个 Category 包含的东西会多一点，毕竟 `NSString` 平时用的也会比较多。有 加密/解密，获取各种路径(如 Documents / Cache) ，生成 UUID 等等。

#### UIApplication+MGJKit

这个 Category 可以获取 app 的版本号和 build 号。

#### UIDevice+MGJKit

设备相关，如是否越狱、获取设备id、运营商等。

#### NSMutableArray+MGJKit

对 nil 做了一些处理，避免异常。

#### NSDictionary+MGJKit

对于 C Struct 做了些封装，可以直接获取 CGPoint / CGRect / CGSize，当然要配合 NSMutableDictionary 的相应方法一起使用。

#### NSMutableDictionary+MGJKit

可以插入 C Struct，不用再手动做一次转换，获取时，调用 `NSDictionary+MGJKit` 里的对应的方法即可。


### Classes

#### MGJApplicationStateMonitor

这个类可以监听系统生命周期的各种通知，然后调用 Delegate 对应的方法，Delegate 的这些方法跟 `AppDelegate` 里的方法完全一致。

#### MGJBatchRequesterStore

这个类可以批量存储数据，并提供消费数据的接口，消费完后，这批数据就会被清除。

#### MGJHangDetector

这个类可以检测主线程是否处于卡主的状态，原理是每隔一定时间（如 1 秒）去 Ping 一下主线程，如果主线程没有响应，则处于卡住状态。

#### MGJLog

这个 Logger 可以记录任意类型的值，而且会自动带上名字，比如

```
MGJLog(self.view); // self.view = ...
MGJLog(rect);
```

#### MGJRequestManager

这是一个非常灵活和方便的 HTTP 管理类，其他 App 的 HTTP 层都是基于它做的。

#### MGJRouter

一个路由类，使用方便，无耦合。

#### MGJEntity

JSONModel Lite
