//
//  PGScrollView.swift
//  PGImagePicker
//
//  Created by piggybear on 2017/9/25.
//  Copyright © 2017年 piggybear. All rights reserved.
//

import UIKit

struct PGImagePickerScreenSize {
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
}

public typealias tapCallback = (UIImageView)->()
public class PGScrollView: UIScrollView, UIScrollViewDelegate {
    
    //MARK: - public property
    public var tapCallback: tapCallback!
    public var imageView: UIImageView!
    public var tapImageView: UIImageView!
    
    //MARK: - private property
    fileprivate var isTapTouch: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imageView = UIImageView(frame: self.frame)
        self.imageView.isUserInteractionEnabled = true
        self.imageView.contentMode = .scaleAspectFit
        addSubview(self.imageView)
        logic()
    }
    
    //MARK: - system cycle
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - private method
    fileprivate func logic() {
        self.maximumZoomScale = 3.0
        self.minimumZoomScale = 1.0
        backgroundColor = UIColor.clear
        self.isMultipleTouchEnabled = false
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.delegate = self
        self.contentSize = CGSize(width: PGImagePickerScreenSize.width, height: 0)
    }
    
    fileprivate func convertRect(for view: UIView) -> CGRect! {
        let rootView = UIApplication.shared.keyWindow?.rootViewController?.view
        let rect = view.superview?.convert(view.frame, to: rootView)
        return rect!
    }
    
    fileprivate func zoomRect(for scale: CGFloat, center: CGPoint) -> CGRect {
        let width = PGImagePickerScreenSize.width / scale
        let height = PGImagePickerScreenSize.height / scale
        let poX = center.x - (width / 2.0)
        let poY = center.y - (height / 2.0)
        return CGRect(x: poX, y: poY, width: width, height: height)
    }
    
    fileprivate func reset(){
        self.zoomScale = 1.0
        imageView.frame = imageView.bounds
    }
    
    //MARK: - UIScrollViewDelegate
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var xcenter = self.center.x , ycenter = self.center.y;
        xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width / 2 : xcenter;
        ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height / 2 : ycenter;
        imageView.center = CGPoint(x: xcenter, y: ycenter)
    }
}

extension PGScrollView {
    fileprivate func frameLogic() ->CGRect{
        var scale: CGFloat = 1.0
        if ((self.tapImageView.image?.size.width) != nil) {
            scale = PGImagePickerScreenSize.width / (self.tapImageView.image?.size.width)!
        }else {
            scale = PGImagePickerScreenSize.width / self.tapImageView.frame.size.width
        }
        let width = PGImagePickerScreenSize.width
        var height: CGFloat = 1.0
        if self.tapImageView.image?.size.height != nil {
            height = (self.tapImageView.image?.size.height)! * scale
        }else {
            height = self.tapImageView.frame.size.height * scale
        }
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        return frame
    }
    
    public func setupImageViewFrame(){
        self.zoomScale = self.minimumZoomScale
        self.imageView.frame = frameLogic()
        self.imageView.center = self.center
    }
    public func doAnimation(imageView: UIImageView) {
        self.tapImageView = imageView
        self.imageView.frame = self.convertRect(for: self.tapImageView)
        let frame = frameLogic()
        self.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.15, animations: {
            self.imageView.frame = frame
            self.imageView.center = self.center
        }) {_ in
            self.isUserInteractionEnabled = true
        }
    }
    
    @objc fileprivate func tapHandler(_ touch: UITouch) {
        isTapTouch = true
        self.isUserInteractionEnabled = false
        self.bounds = CGRect(x: 0, y: 0, width: PGImagePickerScreenSize.width, height: PGImagePickerScreenSize.height)
        let duration = 0.18 / PGImagePickerScreenSize.width * self.imageView.frame.size.width
        UIView.animate(withDuration: TimeInterval(duration), animations: {
            self.imageView.frame = self.convertRect(for: self.tapImageView)
        }) { (tf) in
            if (self.tapCallback != nil) {
                self.tapCallback(self.imageView)
            }
        }
    }
    
    @objc fileprivate func doubleHandler(_ sender: UITouch) {
        var zoomScale = self.zoomScale
        let minimumZoomScale: CGFloat = 1.0
        let maximumZoomScale: CGFloat = 2.0
        zoomScale = (zoomScale == minimumZoomScale) ? maximumZoomScale : minimumZoomScale
        let zoomRect = self.zoomRect(for: zoomScale, center: sender.location(in: sender.view))
        isTapTouch = false
        self.zoom(to: zoomRect, animated: true)
    }
}

extension PGScrollView {
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch = (touches as NSSet).anyObject() as! UITouch
        if touch.tapCount == 1 {
            self.perform(#selector(tapHandler(_:)), with: nil, afterDelay: 0.2)
        }else {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(tapHandler), object: nil)
            guard isTapTouch == true else {
                doubleHandler(touch)
                return
            }
        }
    }
}

