//
//  ViewController.swift
//  PGImagePicker
//
//  Created by gongyupeng on 2017/9/25.
//  Copyright © 2017年 piggybear. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! PhotoViewController
        let identifier: NSString = NSString(string: segue.identifier!)
        controller.index = Int(identifier.intValue)
    }
}


