![PGImagePicker](PGImagePicker.gif)
# PGImagePicker
> 1、使用UICollectionView进行复用  
> 2、内置了3种样式，有微博和微信的样式  
> 3、双击放大/还原，单击返回，双指粘合缩放，长按保存图片到相册  
> 4、可以自定义相薄

**长按保存到相册需要在info.plist中加入以下隐私权限**

```
<key>NSPhotoLibraryAddUsageDescription</key>
<string>App需要您的同意,才能访问相册</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>App需要您的同意,才能访问相册</string>
```

> 如果相册权限被用户拒绝了，PGImagePicker已经设置好了引导用户去APP设置页面开启权限

# CocoaPods安装
```
pod 'PGImagePicker'
```
# 使用
```
let imagePicker = PGImagePicker(currentImageView: tapView, imageViews: imageViews)
present(imagePicker, animated: false, completion: nil)
```
总共需要传入两个参数。第一个```currentImageView```是```当前的UIImageView```，第二个参数```imageViews```是```需要浏览的所有图片的UIImageView ```，如果只需要浏览一张图，则参数```imageViews```可以省略

单张图片预览
> 例如点击头像预览

```
let imagePicker = PGImagePicker(currentImageView: tapView)
present(imagePicker, animated: false, completion: nil)
```
设置相薄
> 长按保存到相册，可以自定义相薄，将图片保存到自己定义的相薄里面

```
imagePicker.albumName = "PGImagePicker"  

```
设置样式
> pageControlType共有3种样式
> 样式1是当前微信的样式，样式3是当前微博的样式

```
let imagePicker = PGImagePicker(currentImageView: tapView, pageControlType: .type1, imageViews: imageViews)
present(imagePicker, animated: false, completion: nil)

```
设置代理
>得到当前正在预览的图片

```
imagePicker.delegate = self
func imagePicker(imagePicker: PGImagePicker, didSelectImageView imageView: UIImageView, didSelectImageViewAt index: Int) {
    print("index = ", index)
}
```
# 加载网络图片
>加载网络图片使用的是Kingfisher框架

引入pod

```
pod 'PGImagePickerKingfisher'
```

使用

```
let imagePicker = PGImagePickerKingfisher(currentImageView: tapView, imageViews: imageViews)
imagePicker.imageUrls = self.imageUrls
imagePicker.indicatorType = .activity
imagePicker.placeholder = UIImage(named: "projectlist_06")
present(imagePicker, animated: false, completion: nil)

```
```imageUrls```是图片需要加载的url地址
```indicatorType```、```placeholder```跟当前要预览的图片一致，没有可以不用设置

# 许可证

PGNetworkHelper 使用 MIT 许可证，详情见 [LICENSE](LICENSE) 文件。






