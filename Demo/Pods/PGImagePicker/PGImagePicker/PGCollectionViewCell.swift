//
//  PGCollectionViewCell.swift
//  PGImagePicker
//
//  Created by piggybear on 2017/9/29.
//  Copyright © 2017年 piggybear. All rights reserved.
//

import UIKit

public class PGCollectionViewCell: UICollectionViewCell {
    
    public lazy var scrollView: PGScrollView! = {
        let scrollView = PGScrollView(frame: self.contentView.bounds)
        self.contentView.addSubview(scrollView)
        return scrollView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView.frame = self.bounds
    }
}
