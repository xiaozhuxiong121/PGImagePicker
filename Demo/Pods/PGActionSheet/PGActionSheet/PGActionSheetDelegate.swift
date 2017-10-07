//
//  PGActionSheetDelegate.swift
//  PGActionSheet
//
//  Created by piggybear on 2017/10/2.
//  Copyright © 2017年 piggybear. All rights reserved.
//

import Foundation

@objc public protocol PGActionSheetDelegate {
   @objc optional func actionSheet(_ actionSheet: PGActionSheet, clickedButtonAt index: Int)
}
