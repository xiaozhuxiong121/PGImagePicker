//
//  PGImagePicker.swift
//  PGImagePicker
//
//  Created by piggybear on 2017/9/25.
//  Copyright © 2017年 piggybear. All rights reserved.
//

import UIKit
import PGActionSheet

public enum PageControlType: Int {
    case type1
    case type2
    case type3
}

open class PGImagePicker: UIViewController {
    
    //MARK: - pulic property
    public var delegate: PGImagePickerDelegate?
    public var albumName: String = ""
    
    //MARK: - private property
    fileprivate var flowLayout: UICollectionViewFlowLayout!
    fileprivate var countLabel: UILabel!
    fileprivate var pageControl: UIPageControl!
    fileprivate let pageControlType: PageControlType
    fileprivate var isAnimated: Bool = false
    fileprivate var collectionView: UICollectionView!
    fileprivate let windowLevel: UIWindowLevel!
    fileprivate let imageViews: [UIImageView]!
    fileprivate let currentImageView: UIImageView!
    fileprivate let imageViewSpace: CGFloat = 25
    fileprivate var currentIndex: Int = 0
    fileprivate var lastOffsetX: CGFloat = 0
    fileprivate let cellWithReuseIdentifier  = "PGCollectionViewCell"
    fileprivate var deviceOrientationCompleted: Bool = true
    //MARK: - system cycle
    required public init(currentImageView: UIImageView!,  pageControlType: PageControlType = .type1, imageViews: [UIImageView]? = nil) {
        self.pageControlType = pageControlType
        self.currentImageView = currentImageView
        self.imageViews = imageViews
        self.windowLevel = UIApplication.shared.keyWindow?.windowLevel
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .custom
        self.view.backgroundColor = UIColor.black
        self.view.isUserInteractionEnabled = true
        self.view.isMultipleTouchEnabled = false
        guard imageViews != nil else {
            setupCollectionView()
            return
        }
        for (index, value) in (imageViews?.enumerated())! {
            if currentImageView == value {
                currentIndex = index
                break
            }
        }
        switch pageControlType {
        case .type1:
            setupPageControl()
        case .type2, .type3:
            setupCountLabel()
        }
        setupCollectionView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isAnimated = true
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.delegate != nil  {
            var imageView: UIImageView = self.currentImageView
            if hasImageViews() {
                imageView = self.imageViews[currentIndex]
            }
            self.delegate?.imagePicker?(imagePicker: self, didSelectImageView: imageView, didSelectImageViewAt: currentIndex)
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler))
        self.view.addGestureRecognizer(longPress)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (self.pageControl != nil) {
            self.view.bringSubview(toFront: self.pageControl)
        }
        if (countLabel != nil) {
            self.view.bringSubview(toFront: self.countLabel)
        }
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.view.isUserInteractionEnabled = false
        deviceOrientationCompleted = false
        self.flowLayout.itemSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        var bounds = self.view.bounds
        bounds.size.width += imageViewSpace
        self.collectionView.frame = bounds
        bounds.origin.x += CGFloat(self.currentIndex) * bounds.size.width
        self.collectionView.bounds = bounds
        if (pageControl != nil) {
            let width: CGFloat = CGFloat(13 * self.imageViews.count)
            let height: CGFloat = 37.0
            let x: CGFloat = (UIScreen.main.bounds.size.width - width) / 2
            let y: CGFloat = UIScreen.main.bounds.size.height - 20 - height / 2
            let frame = CGRect(x: x, y: y, width: width, height: height)
            self.pageControl.frame = frame
        }
        if (countLabel != nil) {
            let width: CGFloat = 100
            let height: CGFloat = 30.0
            let x: CGFloat = (UIScreen.main.bounds.size.width - width) / 2
            var y: CGFloat = UIScreen.main.bounds.size.height - 30 - height / 2
            if self.pageControlType == .type3 {
                y = 30
            }
            let frame = CGRect(x: x, y: y, width: width, height: height)
            self.countLabel.frame = frame
        }
        deviceOrientationCompleted = true
        self.view.isUserInteractionEnabled = true
    }
    
    //MARK: - open method
    open func setupImageView(cell: PGCollectionViewCell, indexPath: IndexPath, imageView: UIImageView){
        cell.scrollView.imageView.image = imageView.image
    }
    
    //MARK: - private method
    @objc private func longPressHandler(_ sender: UIGestureRecognizer) {
        guard sender.state == .began else {
            return
        }
        let actionSheet = PGActionSheet(cancelButton: true, buttonList: ["保存图片"])
        actionSheet.actionSheetTranslucent = false
        actionSheet.delegate = self
        present(actionSheet, animated: false, completion: nil)
    }
    
    private func setupCollectionView() {
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = imageViewSpace
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, imageViewSpace)
        var bounds = self.view.bounds
        bounds.size.width += imageViewSpace
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        self.view.addSubview(collectionView)
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = true
        collectionView.register(PGCollectionViewCell.self, forCellWithReuseIdentifier: cellWithReuseIdentifier)
        collectionView.contentOffset = CGPoint(x: collectionView.bounds.size.width * CGFloat(currentIndex), y: 0)
    }
    
    private func setupPageControl() {
        let width: CGFloat = CGFloat(13 * self.imageViews.count)
        let height: CGFloat = 37.0
        let x: CGFloat = (UIScreen.main.bounds.size.width - width) / 2
        let y: CGFloat = UIScreen.main.bounds.size.height - 20 - height / 2
        let frame = CGRect(x: x, y: y, width: width, height: height)
        pageControl = UIPageControl(frame: frame)
        pageControl.numberOfPages = (imageViews?.count)!
        pageControl.currentPage = currentIndex
        self.view.addSubview(pageControl)
    }
    
    private func setupCountLabel() {
        let width: CGFloat = 100
        let height: CGFloat = 30.0
        let x: CGFloat = (UIScreen.main.bounds.size.width - width) / 2
        var y: CGFloat = UIScreen.main.bounds.size.height - 30 - height / 2
        if self.pageControlType == .type3 {
            y = 30
        }
        let frame = CGRect(x: x, y: y, width: width, height: height)
        countLabel = UILabel(frame: frame)
        countLabel.font = UIFont.boldSystemFont(ofSize: 20)
        countLabel.textColor = UIColor.white
        countLabel.textAlignment = .center 
        countLabel.text = String(currentIndex + 1) + "/" + String(imageViews.count)
        self.view.addSubview(countLabel)
    }
}

extension PGImagePicker {
    
    fileprivate func hasImageViews() ->Bool {
        if self.imageViews != nil {
            if self.currentIndex < self.imageViews.count {
                return true
            }
        }
        return false
    }
    
    fileprivate func hud() {
        DispatchQueue.main.sync {
            let width: CGFloat = 150
            let height: CGFloat = 30
            let view = UIView(frame: CGRect(x: self.view.bounds.size.width / 2 - width / 2, y: self.view.bounds.size.height / 2 - height / 2, width: width, height: height))
            view.backgroundColor = UIColor.black
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 5
            self.view.addSubview(view)
            let label = UILabel()
            label.text = "保存成功"
            label.textColor = UIColor.white
            label.font = UIFont.systemFont(ofSize: 15)
            view.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            let centerX = NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0)
            let centerY = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0)
            view.addConstraints([centerX, centerY])
            UIView.animate(withDuration: 1.0, animations: {
                view.alpha = 0
            }, completion: { _ in
                view.removeFromSuperview()
            })
        }
    }
    
    fileprivate func alertController() {
        var message = "请您前去打开照片权限在操作"
        if #available(iOS 11.0, *) {
            message = "请您将照片权限修改为【读取和写入】然后在操作"
        }
        let alertController = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: { _ in
            let url: URL = URL(string: UIApplicationOpenSettingsURLString)!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: false, completion: nil)
    }
}

extension PGImagePicker: PGActionSheetDelegate {
    public func actionSheet(_ actionSheet: PGActionSheet, clickedButtonAt index: Int) {
        self.dismiss(animated: false, completion: nil)
        var image: UIImage = self.currentImageView.image!
        if hasImageViews() {
            image = self.imageViews[self.currentIndex].image!
        }
        PGPhotoAlbumUtil.saveImageInAlbum(image: image, albumName: self.albumName, completion: { (result) in
            switch result{
            case .success:
                self.hud()
            case .denied:
                self.alertController()
            case .error:
                print("保存错误")
            }
        })
    }
}

extension PGImagePicker: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if imageViews == nil {
            return 1
        }
        return imageViews.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PGCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellWithReuseIdentifier, for: indexPath) as! PGCollectionViewCell
        var imageView: UIImageView  = self.currentImageView
        if (imageViews != nil) {
            imageView = self.imageViews[indexPath.row]
        }
        if isAnimated {
            isAnimated = false
            cell.scrollView.doAnimation(imageView: imageView)
        }
        cell.scrollView.tapImageView = imageView
        setupImageView(cell: cell, indexPath: indexPath, imageView: imageView)
        cell.scrollView.tapCallback = {[unowned self] imageView in
            UIApplication.shared.keyWindow?.windowLevel = self.windowLevel
            self.dismiss(animated: false, completion: nil)
        }
        return cell
    }
}

extension PGImagePicker: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let collectionViewCell = cell as! PGCollectionViewCell
        collectionViewCell.scrollView.setupImageViewFrame()
    }
}

extension PGImagePicker: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard deviceOrientationCompleted else {
            return
        }
        var page = Int(floor(scrollView.contentOffset.x / scrollView.bounds.size.width))
        if lastOffsetX >= scrollView.contentOffset.x {
            page = Int(ceil(scrollView.contentOffset.x / scrollView.bounds.size.width))
        }
        if page <= 0 {
            page = 0
        }
        if page >= imageViews.count - 1 {
            page = imageViews.count - 1
        }
        if (pageControl != nil) {
            self.pageControl.currentPage = page
        }
        if (countLabel != nil) {
            countLabel.text = String(page + 1) + "/" + String(imageViews.count)
        }
        if self.currentIndex != page {
            self.currentIndex = page
            if self.delegate != nil  {
                self.delegate?.imagePicker?(imagePicker: self, didSelectImageView: self.imageViews[page], didSelectImageViewAt: page)
            }
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastOffsetX = scrollView.contentOffset.x
    }
}

