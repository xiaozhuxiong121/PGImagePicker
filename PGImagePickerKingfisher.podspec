Pod::Spec.new do |s|
  s.name         = "PGImagePickerKingfisher"
  s.version      = "1.0.3"
  s.summary      = "多图浏览"
  s.homepage     = "https://github.com/xiaozhuxiong121/PGImagePicker"
  s.license      = "MIT"
  s.author       = { "piggybear" => "piggybear_net@163.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/xiaozhuxiong121/PGImagePicker.git", :tag => s.version }
  s.source_files = "PGImagePickerKingfisher", "PGImagePickerKingfisher/**/*.swift"
  s.frameworks   = "UIKit"
  s.requires_arc = true

  s.dependency 'PGImagePicker'
  s.dependency 'Kingfisher'
end
 
