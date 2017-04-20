# XLImageViewer
仿照今日头条的图片浏览功能，实现的轻量级图片浏览工具。

### 功能

| 缩放动画 | 加载网络图片 | 捏合缩放、双击放大/还原 | 下滑隐藏 | 保存图片到相册 |
| ---- | ---- | ---- | ---- | ---- |
| ![image](https://github.com/mengxianliang/XLImageViewer/blob/master/GIF/1-1.gif) |![image](https://github.com/mengxianliang/XLImageViewer/blob/master/GIF/2-1.gif) |![image](https://github.com/mengxianliang/XLImageViewer/blob/master/GIF/3-1.gif) |![image](https://github.com/mengxianliang/XLImageViewer/blob/master/GIF/4-1.gif) |![image](https://github.com/mengxianliang/XLImageViewer/blob/master/GIF/5-1.gif) |

### 说明

* 加载网络图片的功能时利用SDWebImage实现的，所以在使用XLImageViewer时需要在项目里添加SDWebImage。

### 使用

**查看网络图片：**

```objc
[[XLImageViewer shareInstanse] showNetImages:[self imageUrls] index:indexPath.row fromImageContainer:[collectionView cellForItemAtIndexPath:indexPath]];
```

**查看本地图片：**

```objc
[[XLImageViewer shareInstanse] showLocalImages:[self imagePathes] index:indexPath.row fromImageContainer:[collectionView cellForItemAtIndexPath:indexPath]];
```

