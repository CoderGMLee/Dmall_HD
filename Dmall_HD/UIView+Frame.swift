//
//  UIView+Frame.swift
//  swift-UI
//
//  Created by GM on 15/1/4.
//  Copyright © 2015年 LGM. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    var x : CGFloat {
        set{
            self.frame = CGRect(x: newValue, y: self.y, width: self.width, height: self.height)
        }
        get{
            return self.frame.origin.x
        }
    }

    var y : CGFloat {
        set{
            self.frame = CGRect(x: self.x, y: newValue, width: self.width, height: self.height)
        }
        get{
            return self.frame.origin.y;
        }
    }

    var width : CGFloat{

        set {
            self.frame = CGRect(x: self.x, y: self.y, width: newValue, height: self.height)
        }
        get{
            return self.frame.size.width
        }
    }

    var height : CGFloat{
        set{
            self.frame = CGRect(x: self.x, y: self.y, width: self.width, height: newValue)
        }
        get{
            return self.frame.size.height
        }
    }

    var left : CGFloat{
        set{
            self.x = newValue
        }
        get{
            return self.x
        }
    }

    var right : CGFloat{
        set{
            self.x = newValue - self.width
        }
        get{
            return self.x + self.width
        }
    }
    var top : CGFloat{
        set{
            self.y = newValue;
        }
        get{
            return self.y
        }
    }
    var bottom : CGFloat{
        set{
            self.y = newValue - self.height
        }
        get{
            return self.y + self.height
        }
    }

    var centerX : CGFloat {
        set{
            self.center = CGPoint(x: newValue, y: self.center.y)
        }
        get{
            return self.center.x
        }
    }

    var centerY : CGFloat {

        set{
            self.center = CGPoint(x: self.center.x, y: newValue)
        }
        get{
            return self.center.y
        }
    }

    var size : CGSize {
        set {
            self.frame = CGRect(x: self.x, y: self.y, width:newValue.width, height: newValue.height)
        }
        get {
            return self.frame.size
        }
    }

    var origin : CGPoint {
        set {
            self.frame = CGRect(x: newValue.x, y: newValue.y, width: self.width, height: self.height)
        }
        get {
            return self.frame.origin
        }
    }
}
