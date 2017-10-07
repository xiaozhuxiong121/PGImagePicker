//
//  PhotoViewController.swift
//  Demo
//
//  Created by piggybear on 2017/10/7.
//  Copyright © 2017年 piggybear. All rights reserved.
//

import UIKit
import PGImagePickerKingfisher
import PGImagePicker

class PhotoViewController: UIViewController {
    
    public var index: Int = 0
    @IBOutlet var imageViews: [UIImageView]!
    let imageUrls: [String] = [
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1507044553408&di=0351ff7e9b27eb6c97440b73ed1a56e3&imgtype=0&src=http%3A%2F%2Fatt.x2.hiapk.com%2Fforum%2F201604%2F20%2F194923ddgsdcg2peg9odtd.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1507639288&di=5dac32d08558c6ef24b0971fb53483e5&imgtype=jpg&er=1&src=http%3A%2F%2Fatt.x2.hiapk.com%2Fforum%2F201604%2F20%2F1949337xfizdiggcn5xgcc.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1507639309&di=be701d022e14c7fee9af6f009bc90c26&imgtype=jpg&er=1&src=http%3A%2F%2Fpic.5442.com%2F2012%2F0924%2F06%2F81.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1507639320&di=05f96fa15f367d78e0808f9b62ca4e50&imgtype=jpg&er=1&src=http%3A%2F%2Fatt.bbs.duowan.com%2Fforum%2F201309%2F21%2F125721loczzel7ocxomy32.jpg",
        "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1507044960165&di=140b60b88c857865fbd832349b445a1d&imgtype=0&src=http%3A%2F%2Fpic4.zhongsou.com%2Fimg%3Fid%3D5221f5938467e4ecf57"
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard self.index == 3 else {
            return
        }
        for (index, value) in imageViews.enumerated() {
            let image = UIImage(named: "projectlist_06")
            let url = URL(string: imageUrls[index])!
            value.kf.indicatorType = .activity
            value.kf.setImage(with: url, placeholder: image)
        }
        let documentPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documnetPath = documentPaths[0]
        print("documnetPath = ", documnetPath)
    }
    
    @IBAction func imageViewTap(_ sender: UITapGestureRecognizer) {
        let tapView = sender.view as! UIImageView
        if self.index == 3 {
            let imagePicker = PGImagePickerKingfisher(currentImageView: tapView, imageViews: imageViews)
            imagePicker.albumName = "PGImagePicker"
            imagePicker.imageUrls = self.imageUrls
            imagePicker.indicatorType = .activity
            imagePicker.placeholder = UIImage(named: "projectlist_06")
            present(imagePicker, animated: false, completion: nil)
            return
        }
        let imagePicker = PGImagePicker(currentImageView: tapView, pageControlType: PageControlType(rawValue: index)!, imageViews: imageViews)
        imagePicker.albumName = "PGImagePicker"
        imagePicker.delegate = self
        present(imagePicker, animated: false, completion: nil)
    }
}

extension PhotoViewController: PGImagePickerDelegate {
    func imagePicker(imagePicker: PGImagePicker, didSelectImageView imageView: UIImageView, didSelectImageViewAt index: Int) {
        print("index = ", index)
    }
}
