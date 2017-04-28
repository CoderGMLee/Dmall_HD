//
//  ItemView.swift
//  Dmall_HD
//
//  Created by GM on 17/2/13.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit

class ItemView: UIView {

    var shopCart = false {
        willSet {
            if newValue {
               itemUpView?.vMark = "shopcartView"
            } else {
                itemUpView?.vMark = nil
            }
        }
    }
    var showTitle = false
    var title : String? {
        willSet {
            titleLabel?.text = newValue
            if newValue != nil && newValue != "" && showTitle {
                itemUpView?.haveTitle = true
            } else {
                itemUpView?.haveTitle = false
            }
        }
    }
    private var proTitleColor : String?
    var titleColor : String? {
        set {
            proTitleColor = newValue
            if selectTitleColor == nil || selectTitleColor == "" {
                selectTitleColor = "#555555"
            }
        }
        get {
            return proTitleColor
        }
    }
    private var proSelectTitleColor : String?
    var selectTitleColor : String? {
        set {
            proSelectTitleColor = newValue
            if proSelectTitleColor == nil || proSelectTitleColor == "" {
                proSelectTitleColor = "e96113"
            }
        }
        get {
            return proSelectTitleColor
        }
    }
    var titleSelected : Bool = false {
        willSet {
            itemUpView?.selected = newValue
            if newValue {
                titleLabel?.textColor = UIColor.colorWithString(string: selectTitleColor ?? "")
            } else {
                titleLabel?.textColor = UIColor.colorWithString(string: titleColor ?? "")
            }
        }
    }

    var imgSrc : String?
    var count : Int?
    var tabSize = CGSize.zero {
        willSet {
            tabWidth = newValue.width
            tabHeight = newValue.height
            itemUpView?.tabSize = newValue
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    private var titleLabel : UILabel?
    private var itemUpView : ItemUpView?
    private var tabWidth : CGFloat = 0
    private var tabHeight : CGFloat = 0

    override init(frame: CGRect) {
        tabWidth = frame.width
        tabHeight = frame.height
        super.init(frame: frame)
        addItemUpView()
        addTitleLabel()
//        backgroundColor = UIColor.white
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    func setPng(_ pngUrl: String, pngDefault pngName: String, gif gifUrl: String, gifDefault gifName: String) {
        itemUpView?.setPng(pngUrl: pngUrl, pngDefault: pngName, gif: gifUrl, gifDefault: gifName)
    }

    func showPngImageView(isShow: Bool) {
        itemUpView?.showPngImageView(isShow: isShow)
    }

    func showGifView(isShow: Bool) {
        itemUpView?.showGifView(isShow: isShow)
    }

    func setTitleSelect(isSelect: Bool) {
        itemUpView?.selected = isSelect
        if isSelect {
            titleLabel?.textColor = UIColor.colorWithString(string: selectTitleColor ?? "")
        } else {
            titleLabel?.textColor = UIColor.colorWithString(string: titleColor ?? "")
        }
    }

    func setItemCount(count: Int) {
        self.count = count
        itemUpView?.setItemCount(count: count)
        setNeedsLayout()
        layoutIfNeeded()
    }

    func playOnce() {
        itemUpView?.playOnce()
    }

    func playLoop() {
        itemUpView?.playLoop()
    }

    //Private
    override func layoutSubviews() {
        super.layoutSubviews()
        size = tabSize
        titleLabel?.size = CGSize(width: tabSize.width, height: 10)
    }

    func addItemUpView() {
        //frame = (0 0; 93.75 48)
        itemUpView = ItemUpView(frame: self.frame)
        addSubview(itemUpView!)
    }

    func addTitleLabel() {
        titleLabel = UILabel(frame: CGRect(x: 0, y: tabHeight - 15, width: tabWidth, height: 10))
        titleLabel?.textAlignment = NSTextAlignment.center
        titleLabel?.font = UIFont.systemFont(ofSize: 10)
        addSubview(titleLabel!)
    }
}
