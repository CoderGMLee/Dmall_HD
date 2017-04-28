//
//  ItemUpView.swift
//  Dmall_HD
//
//  Created by GM on 17/2/15.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit

class ItemUpView: UIView {

    //MARK:- Public Property
    var vMark : String?
    var haveTitle : Bool = false
    var count : Int?
    var tabSize : CGSize = CGSize.zero {
        willSet {
            tabWidth = newValue.width
            tabHeight = newValue.height
            normalView.tabSize = newValue
            selectView.tabSize = newValue
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    var selected : Bool = false


    //MARK:- Private Property
    private var backgroundImage : UIImage?
    private var normalView : ItemImageView!
    private var selectView : ItemImageView!
    private var countLabel : UILabel!
    private var iconView : UIView!
    private var imageSize = CGSize.zero
    private var playOnceRequest = false
    private var playLoopRequest = false
    private var tabWidth : CGFloat = 0
    private var tabHeight : CGFloat = 0


    //MARK:- Public Method
    override init(frame: CGRect) {
        tabWidth = frame.width
        tabHeight = frame.height
        super.init(frame: frame)
        backgroundColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0)
        tintColor = UIColor.clear
        addNormalView()
        addSelectView()
        addCountLabel()
        addIconView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setPng(pngUrl: String, pngDefault pngName : String, gif gifUrl: String, gifDefault gifName: String) {
        normalView.haveTitle = haveTitle
        selectView.haveTitle = haveTitle

        if pngName == pngUrl {
            normalView.imgSrc = pngName
        } else {
            normalView.imgSrc = pngName
            normalView.imgSrc = pngUrl
        }

        if gifUrl == gifName {
            selectView.imgSrc = gifName
        } else {
            selectView.imgSrc = gifName
            selectView.imgSrc = gifUrl
        }
    }

    func showPngImageView(isShow: Bool) {
        normalView.isHidden = !isShow
    }

    func showGifView(isShow: Bool) {
        selectView.isHidden = !isShow
    }

    func setItemCount(count: Int) {
        self.count = count
        setNeedsLayout()
        layoutIfNeeded()
    }

    func playOnce() {
        playLoopRequest = true
        if selectView != nil {
            selectView.playOnce()
        }
    }

    func playLoop() {
        playLoopRequest = true
        if selectView != nil {
            selectView.playLoop()
        }
    }


    //MARK:- Private Method

    override func layoutSubviews() {
        super.layoutSubviews()
        self.size = tabSize
        if let count = self.count {
            setItemNewCount(count: count)
        }
        showSelectView()
    }

    func addNormalView() {
        normalView = ItemImageView(frame: self.frame)
        addSubview(normalView)
    }

    func addSelectView() {
        selectView = ItemImageView(frame: self.frame)
        addSubview(selectView)
    }

    func addCountLabel() {
        countLabel = UILabel(frame: CGRect.zero)
        countLabel.font = UIFont.systemFont(ofSize: 10)
        countLabel.backgroundColor = UIColor.app20CartBarColor
        countLabel.textColor = UIColor.white
        countLabel.textAlignment = .center
        countLabel.layer.cornerRadius = 9
        countLabel.layer.masksToBounds = true
        addSubview(countLabel)
    }

    func addIconView() {
        iconView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 8))
        iconView.backgroundColor = UIColor.app20CartBarColor
        iconView.layer.cornerRadius = 4
        iconView.layer.masksToBounds = true
        iconView.isHidden = true
        addSubview(iconView)
    }

    func setItemNewCount(count: Int) {
        if count == 0 {
            iconView.isHidden = true
            countLabel.isHidden = true
        }

        if count > 0 {
            iconView.isHidden = true
            countLabel.isHidden = false

            if count < 10 {
                countLabel.origin = makeCountPoint()
                countLabel.size = CGSize(width: 18, height: 18)
                countLabel.text = "\(count)"
                return
            }
            if count < 100 {
                countLabel.origin = makeCountPoint()
                countLabel.size = CGSize(width: 18, height: 18)
                countLabel.text = "\(count)"
                return
            }
            countLabel.origin = makeCountPoint()
            countLabel.size = CGSize(width: 24, height: 18)
            countLabel.text = "99+"
            return
        }
        iconView.origin = makeIconPoint()
        iconView.size = CGSize(width: 8, height: 8)
        iconView.isHidden = false
        countLabel.isHidden = true
    }

    func makeCountPoint() -> CGPoint {
        var point : CGPoint
        if selected {
            point = CGPoint(x: (tabWidth - selectView.width) / 2 + selectView.width - 10, y: 0)
        } else {
            point = CGPoint(x: (tabWidth - normalView.width) / 2 + normalView.width - 10, y: 0)
        }
        return point
    }

    func makeIconPoint() -> CGPoint {

        var point : CGPoint
        if selected {
            point = CGPoint(x: (tabWidth - selectView.width) / 2 + selectView.width - 8, y: 4)
        } else {
            point = CGPoint(x: (tabWidth - normalView.width) / 2 + normalView.width - 8, y: 4)
        }
        return point
    }

    func showSelectView() {
        if selected {
            normalView.isHidden = true
            selectView.isHidden = false
        } else {
            normalView.isHidden = false
            selectView.isHidden = true
        }
    }
}
