//
//  PGScrollView.swift
//  PGImagePicker
//
//  Created by piggybear on 2017/9/25.
//  Copyright © 2017年 piggybear. All rights reserved.
//

import UIKit

public typealias tapCallback = (UIImageView)->()
open class PGScrollView: UIScrollView, UIScrollViewDelegate {
    //MARK: - public property
    public var tapCallback: tapCallback!
    public var imageView: UIImageView!
    public var tapImageView: UIImageView!
    //MARK: - private property
    fileprivate var isTapTouch: Bool = false
    //MARK: - system cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imageView = UIImageView(frame: self.frame)
        self.imageView.isUserInteractionEnabled = true
        self.isScrollEnabled = false
        self.imageView.contentMode = .scaleAspectFit
        addSubview(self.imageView)
        logic()
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        self.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: 0)
    }
    
    fileprivate func convertRect(for view: UIView?) -> CGRect {
        let rootView = UIApplication.shared.keyWindow?.rootViewController?.view
        if view != nil &&  view?.superview != nil {
            let rect = view?.superview?.convert((view?.frame)!, to: rootView)
            return rect!
        }
        return CGRect.zero
    }
    
    fileprivate func zoomRect(for scale: CGFloat, center: CGPoint) -> CGRect {
        let width = UIScreen.main.bounds.size.width / scale
        let height = UIScreen.main.bounds.size.height / scale
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
    
    @objc fileprivate func deviceOrientationDidChange() {
        let orientation: UIDeviceOrientation = UIDevice.current.orientation
        guard orientation == .portrait || orientation == .landscapeLeft || orientation == .landscapeRight  else {
            return
        }
        self.imageView.frame = frameLogic()
        self.imageView.center = self.center
    }
}

extension PGScrollView {
    fileprivate func frameLogic() ->CGRect{
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        let imageWidth = (self.tapImageView.image?.size.width)!
        let imageHeight = (self.tapImageView.image?.size.height)!
        var width: CGFloat = 1.0
        var height: CGFloat = 1.0
        var scale: CGFloat = 1.0
        if screenWidth > screenHeight && imageHeight != 0 {//以高度为基准，等比例宽度
            scale = screenHeight / imageHeight
        }else if imageWidth != 0 { //以宽度为基准，等比例高度
            scale = screenWidth / imageWidth
        }
        width = scale * imageWidth
        height = scale * imageHeight
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        return frame
    }
    
    public func setupImageViewFrame() {
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
    
    func animationOfOpacityAndScale() {
        let duration: CFTimeInterval = 0.3
        let opacityAnimation = CABasicAnimation.init(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0
        opacityAnimation.duration = duration
        opacityAnimation.isRemovedOnCompletion = false
        opacityAnimation.fillMode = kCAFillModeForwards
        
        let scaleAnimation = CABasicAnimation.init(keyPath: "transform.scale")
        scaleAnimation.fromValue = self.zoomScale
        scaleAnimation.toValue = 3.5
        scaleAnimation.duration = duration
        scaleAnimation.delegate = self
        scaleAnimation.isRemovedOnCompletion = false
        scaleAnimation.fillMode = kCAFillModeForwards
        
        self.imageView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.superview?.superview?.superview?.superview?.layer.add(opacityAnimation, forKey: "opacity")
        self.imageView.layer.add(scaleAnimation, forKey: "scale")
    }
    
    @objc fileprivate func tapHandler(_ touch: UITouch) {
        isTapTouch = true
        self.isUserInteractionEnabled = false
        self.bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        guard self.tapImageView.superview != nil else { //tapImageView.superview没有渲染出来
            animationOfOpacityAndScale()
            return
        }
        
        let frame = self.convertRect(for: self.tapImageView)
        guard frame.origin.x > 0 && frame.origin.x < UIScreen.main.bounds.size.width && frame.origin.y > 0 && frame.origin.y < UIScreen.main.bounds.size.height else { //tapImageView不在屏幕内
            animationOfOpacityAndScale()
            return
        }
        var duration = 0.0
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        if screenWidth > screenHeight {
            duration = Double(0.20 / screenHeight * self.imageView.frame.size.height)
        }else {
            duration = Double(0.20 / screenWidth * self.imageView.frame.size.width)
        }
        self.superview?.superview?.superview?.superview?.backgroundColor = UIColor.clear
        UIView.animate(withDuration:  TimeInterval(duration), delay: 0, options: .curveLinear, animations: {
            self.imageView.frame = frame
        }) { _ in
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

extension PGScrollView: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if (self.tapCallback != nil) {
            self.tapCallback(self.imageView)
        }
    }
}

extension PGScrollView {
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
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

