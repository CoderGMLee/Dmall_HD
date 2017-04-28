//
//  NavigationBar.swift
//  Dmall_HD
//
//  Created by GM on 17/2/28.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit

class NavigationBar: UINavigationBar {


    //Property - Public
    var titleLabel : UILabel!
    var title : String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }
    var leftView : UIView? {
        willSet {
            leftView?.removeFromSuperview()
            guard newValue != nil else {
                print("left view can not be nil")
                return
            }
            self.addSubview(newValue!)
        }
    }
    var rightView : UIView? {
        willSet {
            guard newValue != nil else {
                print("right view can not be nil")
                return
            }
            rightView?.removeFromSuperview()
            var rect = titleLabel.frame
            if let newValue = newValue {
                rect.size.width = newValue.x - 50 - 40
            } else {
                rect = CGRect(x: 50, y: 20, width: self.width - 100, height: 44)
            }
            titleLabel.frame = rect
            if titleLabel.centerX != UIConfig.screenWid / 2 {
                titleLabel.centerX = UIConfig.screenWid / 2
            }
            self.addSubview(newValue!)
        }
    }

    //Property - private
    private(set) var visable = false


    //Method - Private
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.barTintColor = UIColor.white
        self.titleLabel = UILabel(frame: CGRect(x: 50, y: 20, width: self.width - 100, height: 44))
        self.titleLabel.backgroundColor = UIColor.clear
        self.titleLabel.font = UIFont.systemFont(ofSize: 17)
        self.titleLabel.textAlignment = .center
        self.titleLabel.textColor = UIColor.colorWithString(string: "0x222222")
        self.addSubview(titleLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    //Method - Public
    func setVisable(visable: Bool, animated: Bool) {
        self.visable = visable
        guard self.isHidden == visable else {
            return
        }
        guard animated == true else {
            self.isHidden = !visable
            return
        }

        if visable {
            var tmpFrame = self.frame
            tmpFrame.origin.y = -tmpFrame.size.height
            self.frame = tmpFrame
            self.isHidden = false

            UIView.animate(withDuration: 0.4, animations: { 
                var targetFrame = tmpFrame
                targetFrame.origin.y = 0
                self.frame = targetFrame
            })
        } else {
            var tmpFrame = frame
            tmpFrame.origin.y = 0
            self.frame = tmpFrame
            self.isHidden = false

            UIView.animate(withDuration: 0.4, animations: { 
                var targetFrame = tmpFrame
                targetFrame.origin.y = -tmpFrame.size.height
                self.frame = targetFrame
            }, completion: { (finish) in
                self.isHidden = true
            })
        }
    }
}
