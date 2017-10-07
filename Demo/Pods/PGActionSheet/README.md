![PGActionSheet](PGActionSheet.gif)
# PGActionSheet
>1、 PGActionSheet使用了UITableView进行复用  
>2、为了更好的融合当前的界面，PGActionSheet默认的弹出框的透明度是
0.7

# CocoaPods安装
```
pod 'PGActionSheet'
```
# 使用
```
let actionSheet = PGActionSheet(cancelButton: true, buttonList: ["收藏", "保存", "编辑"])
present(actionSheet, animated: false, completion: nil)
```
有两种方式监听点击事件  

1、闭包  

```
actionSheet.handler = {index in
	print("index = ", index)
}
```
2、代理  

```
func actionSheet(_ actionSheet: PGActionSheet, clickedButtonAt index: Int) {
    print("index = ", index)
}
```
设置title  

```
actionSheet.actionSheetTitle = "PGActionSheet"
```
取消弹出框的透明度  

```
actionSheet.actionSheetTranslucent = false
```
取消背景的半透明  

```
actionSheet.translucent = false
```
自定义显示字的样式  

```
actionSheet.textFont = UIFont.boldSystemFont(ofSize: 20)
actionSheet.textColor = UIColor.orange
```
自定义取消按钮的样式  

```
actionSheet.cancelTextColor = UIColor.blue
actionSheet.cancelTextFont = UIFont.systemFont(ofSize: 20)
```
自定义title的样式  

```
actionSheet.actionSheetTitleFont = UIFont.boldSystemFont(ofSize: 22)
actionSheet.actionSheetTitleColor = UIColor.red
```





