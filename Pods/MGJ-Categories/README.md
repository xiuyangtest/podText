### 更新时间
15 / 12 / 24

### 这是什么
mgj-shell 是一个为蘑菇街客户端服务的一个命令行工具，由于平时的开发过程中经常会遇到需要工具化的场景，因此就有了这个工具

### 如何使用

#### 安装
```
brew tap mgj/shell http://gitlab.mogujie.org/wireless-tool/mgj-shell.git && brew upgrade mgj
```

#### 升级
```
brew untap mgj/shell && brew tap mgj/shell http://gitlab.mogujie.org/wireless-tool/mgj-shell.git && brew upgrade mgj
```

### 如何反馈
在群里或论坛里都可以，竭诚为您服务~

### To Dev

如果要更新版本的话，需要做这么几件事

0. 升级版本号（修改 Formula/mgj.rb / mgj / package.json 文件）
1. 把 mgj-shell 目录下的文件打成一个 zip 包
2. 把这个文件上传到一个通过 http 可以访问的地方（比如小黄瓜）
3. 使用命令 `curl http://122.225.59.254:8089/xxx.zip | shasum -a 256` 得到 sha256 的值
4. 修改 `Formula/mgj.rb` 文件里的 sha256 值
5. push to remote
