//
//  PGImagePickerDelegate.swift
//  PGImagePicker
//
//  Created by piggybear on 2017/9/26.
//  Copyright © 2017年 piggybear. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol PGImagePickerDelegate {
    @objc optional func imagePicker(imagePicker: PGImagePicker, didSelectImageView imageView: UIImageView, didSelectImageViewAt index: Int)
}
