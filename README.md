# XLImageViewer

仿照今日头条的图片浏览工具。

### 功能:

| 左右切换 | 加载网络图片 | 捏合、双击 | 下滑隐藏 | 保存到相册 |
| ---- | ---- | ---- | ---- | ---- |
| ![image](https://github.com/mengxianliang/XLImageViewer/blob/master/GIF/1-1.gif) |![image](https://github.com/mengxianliang/XLImageViewer/blob/master/GIF/2-1.gif) |![image](https://github.com/mengxianliang/XLImageViewer/blob/master/GIF/3-1.gif) |![image](https://github.com/mengxianliang/XLImageViewer/blob/master/GIF/4-1.gif) |![image](https://github.com/mengxianliang/XLImageViewer/blob/master/GIF/5-1.gif) |

### 说明:

* 支持Gif图片显示
* 支持本地、网络图片显示
* 依赖两个框架[SDWebImage](https://github.com/rs/SDWebImage)、[FLAnimatedImage](https://github.com/Flipboard/FLAnimatedImage)


### 使用:

**查看网络图片：**

```objc
[[XLImageViewer shareInstanse] showNetImages:[self imageUrls] index:indexPath.row fromImageContainer:[collectionView cellForItemAtIndexPath:indexPath]];
```

**查看本地图片：**

```objc
[[XLImageViewer shareInstanse] showLocalImages:[self imagePathes] index:indexPath.row fromImageContainer:[collectionView cellForItemAtIndexPath:indexPath]];
```

### 其他:

**之前利用ScrollView实现切换的版本:[戳这里](http://download.csdn.net/detail/u013282507/9820283)**

### 个人开发过的UI工具集合 [XLUIKit](https://github.com/mengxianliang/XLUIKit)
