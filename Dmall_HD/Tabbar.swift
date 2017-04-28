//
//  Tabbar.swift
//  Dmall_HD
//
//  Created by GM on 17/2/10.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit

class Tabbar: UIView {

    //MARK:- Property

    var proSelected : Bool = false

    static let kMainTabBarHeight : CGFloat = 49.0
    var showSplitLine : Bool? {
        didSet {
            if showSplitLine == true {
                self.sepLine?.isHidden = false
            } else {
                self.sepLine?.isHidden = true
            }
        }
    }
    var showBgImg : Bool = false
    var bgUrl : String? {
        didSet {
            if let unwrapedBgUrl = bgUrl {
                if !showBgImg {
                    self.bgImageView?.isHidden = true
                    return
                }
                downloadImg(imgSrc: unwrapedBgUrl)
            }
        }
    }

    private(set) var visable : Bool = false
    private var sepLine : UIView?
    /// tabbar背景图
    private var bgImageView : UIImageView?

    //MARK:- Function

    init() {
        super.init(frame: CGRect(x: 0, y: UIConfig.screenHei - Tabbar.kMainTabBarHeight, width: UIConfig.screenWid, height: Tabbar.kMainTabBarHeight))
        backgroundColor = UIColor.white
        alpha = 0.95
        sepLine = UIView(frame: CGRect(x: 0, y: 0, width: UIConfig.screenWid, height: 0.5))
        sepLine?.backgroundColor = UIColor.app20BorderColor
        addSubview(sepLine!)
        addBgImageView()
        print("12")
    }

    func addBgImageView() {
        bgImageView = UIImageView(frame: self.bounds)
        bgImageView?.isUserInteractionEnabled = true
        bgImageView?.isHidden = true
        addSubview(bgImageView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func downloadImg(imgSrc: String) {
        //TODO:- 下载图片
    }

    func setVisable(visable: Bool, animated: Bool) {
        self.visable = visable
        if self.isHidden == !visable {
            return
        }

        if !animated {
            self.isHidden = !visable
            return
        }

        if visable {
            tabbarVisible()
        } else {
            tabbarHidden()
        }
    }

    func tabbarVisible() {
        if let unwrapedsuperView = self.superview {
            var frame = self.frame
            let superFrame = unwrapedsuperView.frame
            frame.origin.y = superFrame.size.height
            self.frame = frame
            self.isHidden = false

            UIView.animate(withDuration: 0.4, animations: { 
                var targetFrame = frame
                targetFrame.origin.y = superFrame.size.height - frame.size.height
                self.frame = targetFrame
            })
        }
    }

    func tabbarHidden() {
        if let unwrapedSuperView = self.superview {
            var frame = self.frame
            let superFrame = unwrapedSuperView.frame
            frame.origin.y = superFrame.size.height - frame.size.height
            self.frame = frame
            self.isHidden = true

            var targetFrame = frame
            targetFrame.origin.y = superFrame.size.height
            self.frame = targetFrame
        }
    }

}


// MARK: - Selectable
extension Tabbar: Selectable {
    var selected : Bool {
        set {
            self.proSelected = newValue
        }
        get {
            return self.proSelected
        }
    }
}
