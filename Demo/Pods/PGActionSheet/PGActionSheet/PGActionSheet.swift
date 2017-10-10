//
//  PGActionSheet.swift
//  PGActionSheet
//
//  Created by piggybear on 2017/10/2.
//  Copyright © 2017年 piggybear. All rights reserved.
//

import Foundation
import UIKit

public typealias handlerAction = (Int)->()
public class PGActionSheet: UIViewController {
    //MARK: - public property
    public var handler: handlerAction?
    public var delegate: PGActionSheetDelegate?
    public var textColor: UIColor?
    public var textFont: UIFont?
    public var cancelTextColor: UIColor?
    public var cancelTextFont: UIFont?
    public var actionSheetTitle: String?
    public var actionSheetTitleFont: UIFont?
    public var actionSheetTitleColor: UIColor?
    /// 为了更好的融合到当前视图中，弹出框默认alpha是0.7，默认是true，如果你不想要半透明，可以设置为false
    public var actionSheetTranslucent: Bool = true {
        didSet {
            if !actionSheetTranslucent {
                self.tableView.alpha = 1.0
            }
        }
    }
    
    /// 弹出后，背景是半透明，默认是true，设置为false，则去掉半透明
    public var translucent: Bool = true {
        didSet{
            if !translucent {
                self.overlayView.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0)
            }
        }
    }
    
    //MARK: - private property
    fileprivate let hasCancelButton: Bool
    fileprivate let screenWidth = UIScreen.main.bounds.size.width
    fileprivate let screenHeight = UIScreen.main.bounds.size.height
    fileprivate let buttonList: [String]!
    fileprivate var overlayView: UIView!
    fileprivate var tableView: UITableView!
    fileprivate let headerHeight: CGFloat = 5
    fileprivate let overlayBackgroundColor = UIColor(red:0, green:0, blue:0, alpha:0.5)
    fileprivate let reuseIdentifier = "PGTableViewCell"
    fileprivate let reuseIdentifier1 = "PGTableViewTitleCell"
    
    //MARK: - system cycle
    required public init(cancelButton: Bool = false, buttonList:[String]!){
        self.buttonList = buttonList
        self.hasCancelButton = cancelButton
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = UIColor.clear
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle = .custom
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var height: CGFloat = 44
        var index: Int = 0
        if actionSheetTitle != nil && actionSheetTitle?.characters.count != 0 {
            if hasCancelButton {
                index = 2
            }else {
                index = 1
            }
        }else if hasCancelButton {
            index = 1
        }
        if buttonList != nil && buttonList.count != 0 {
            if hasCancelButton {
                height = CGFloat(buttonList.count + index) * height + headerHeight
            }else {
                height = CGFloat(buttonList.count + index) * height
            }
        }
        let frame = CGRect(x: 0, y: screenHeight - height, width: screenWidth, height: height)
        UIView.animate(withDuration: 0.2) {
            self.tableView.frame = frame
            self.overlayView.alpha = 1.0
        }
    }
    
    //MARK: - private method
    fileprivate func setup() {
        overlayView = UIView(frame: self.view.bounds)
        overlayView.backgroundColor = overlayBackgroundColor
        overlayView.alpha = 0
        self.view.addSubview(overlayView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(overlayViewTapHandler))
        overlayView.addGestureRecognizer(tap)
        
        var frame = self.view.frame
        frame.origin.y = self.screenHeight
        tableView = UITableView(frame: frame, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.alpha = 0.7
        tableView.register(PGTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.register(PGTableViewTitleCell.self, forCellReuseIdentifier: reuseIdentifier1)
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.tableFooterView = UIView()
        self.view.addSubview(tableView)
    }
    
    @objc fileprivate func overlayViewTapHandler() {
        UIView.animate(withDuration: 0.2, animations: {
            var frame = self.tableView.frame
            frame.origin.y = self.view.bounds.size.height
            self.tableView.frame = frame
            self.overlayView.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0)
        }) { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @objc fileprivate func deviceOrientationDidChange() {
        let height = self.tableView.bounds.size.height
        let width = self.view.bounds.size.width
        let y = self.view.bounds.size.height - height
        let frame = CGRect(x: 0, y: y, width: width, height: height)
        UIView.animate(withDuration: 0.2) {
            self.overlayView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2));
            self.tableView.frame = frame
            self.overlayView.frame = self.view.bounds
        }
    }
}

extension PGActionSheet {
    fileprivate func hasTitle() -> Bool {
        return actionSheetTitle != nil && actionSheetTitle!.characters.count != 0
    }
    
    fileprivate func hasButtonList() -> Bool {
        return buttonList != nil && buttonList.count != 0
    }
    
    fileprivate func setCancelButtonTextColorAndTextFont(cell: PGTableViewCell) {
        if cancelTextColor != nil {
            cell.signlabel.textColor = cancelTextColor
        }else {
            cell.signlabel.textColor = UIColor.black
        }
        if cancelTextFont != nil {
            cell.signlabel.font = cancelTextFont
        }else {
            cell.signlabel.font = UIFont.systemFont(ofSize: 17)
        }
    }
    
    fileprivate func setTextButtonTextColorAndTextFont(cell: PGTableViewCell) {
        if textColor != nil {
            cell.signlabel.textColor = textColor
        }else {
            cell.signlabel.textColor = UIColor.black
        }
        if textFont != nil {
            cell.signlabel.font = textFont
        }else {
            cell.signlabel.font = UIFont.systemFont(ofSize: 17)
        }
    }
    
    fileprivate func setTitleColorAndTextFont(cell: PGTableViewTitleCell) {
        if actionSheetTitleFont != nil {
            cell.titlelabel.font = actionSheetTitleFont
        }else {
            cell.titlelabel.font = UIFont.boldSystemFont(ofSize: 17)
        }
        if actionSheetTitleColor != nil {
            cell.titlelabel.textColor = actionSheetTitleColor
        }else {
            cell.titlelabel.textColor = UIColor.darkGray
        }
    }
}

extension PGActionSheet: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        if hasButtonList() && hasCancelButton {
            if hasTitle() {
                return 3
            }
            return 2
        }
        
        if hasTitle() {
            return 2
        }
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hasTitle() {
            if section == 0 {
                return 1
            }
            if hasCancelButton && section == 2 {
                return 1
            }
            if hasButtonList() {
                return buttonList.count
            }
        }
        if section == 1 {
            return 1
        }
        if hasButtonList() {
            return buttonList.count
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if hasTitle() {
            if  indexPath.section == 0 {
                let cell: PGTableViewTitleCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier1, for: indexPath) as! PGTableViewTitleCell
                cell.titlelabel.text = self.actionSheetTitle
                setTitleColorAndTextFont(cell: cell)
                return cell
            }
            let cell: PGTableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! PGTableViewCell
            if hasCancelButton && indexPath.section == 2 {
                cell.signlabel.text = "取消"
                self.setCancelButtonTextColorAndTextFont(cell: cell)
            }else {
                cell.signlabel.text = buttonList[indexPath.row]
                self.setTextButtonTextColorAndTextFont(cell: cell)
            }
            return cell
        }
        
        let cell: PGTableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! PGTableViewCell
        if indexPath.section == 1 {
            cell.signlabel.text = "取消"
            self.setCancelButtonTextColorAndTextFont(cell: cell)
            return cell
        }
        if hasButtonList() {
            cell.signlabel.text = buttonList[indexPath.row]
            self.setTextButtonTextColorAndTextFont(cell: cell)
        }
        return cell
    }
}

extension PGActionSheet: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if  hasTitle() {
            if indexPath.section == 2 {
                self.overlayViewTapHandler()
                return
            }
            if indexPath.section == 0 {
                return
            }
        }else if hasCancelButton && indexPath.section == 1 {
            self.overlayViewTapHandler()
            return
        }
        if handler != nil {
            handler!(indexPath.row)
        }
        if (delegate != nil) {
            self.delegate?.actionSheet!(self, clickedButtonAt: indexPath.row)
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let reuseIdentifier = "header"
        var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier)
        if (view == nil) {
            view = UITableViewHeaderFooterView(reuseIdentifier: reuseIdentifier)
            view?.contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        }
        return view
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if hasCancelButton && self.buttonList != nil && self.buttonList.count != 0 {
            if actionSheetTitle != nil && actionSheetTitle?.characters.count != 0 {
                if section == 2 {
                    return headerHeight
                }
            }else if section == 1 {
                return headerHeight
            }
        }
        return 0
    }
}
