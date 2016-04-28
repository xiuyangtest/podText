## 关于 MGJToolkit
MGJToolkit 包含了一些蘑菇街各个 App 都会用到的基础服务。

### MGJAnalytics
这个是统计相关的类，一般不需要直接使用这个类，而是继承「MGJAnalyticsViewController」，然后在 VC 的 `viewDidLoad` 里设定一下 `requestURLForAnalytics` 即可。具体可参考主客的代码。

### MGJPTP
这是啄木鸟项目的 iOS 端实现，[啄木鸟项目](http://gitlab.mogujie.org/fst_platform/woodpecker)是一个为精确分析蘑菇街/小店用户行为链，提供日志数据的项目，涉及用户行为日志埋点，配置，采集，展示相关框架流程的实现。

因为跟统计关系比较紧密，所以已经在统计里包含了，一般不需要手动调用。具体可以参考主客代码。

#### MGJCrashManager
Crash 相关的处理类。
