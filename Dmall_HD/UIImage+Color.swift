
//
//  UIImage+Color.swift
//  Dmall_HD
//
//  Created by GM on 17/2/28.
//  Copyright © 2017年 dmall. All rights reserved.
//

import Foundation

extension UIImage {

    class func imageWithRGB(R: Float, G: Float, B: Float) -> UIImage? {
        return self.imageWithColor(color: UIColor.color(withR: R, withG: G, withB: B))
    }

    class func imageWithColor(color: UIColor) -> UIImage? {
        let image = self.imageWithColor(color: color, size: CGSize(width: 500, height: 500))
        return image
    }

    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size,false,0);
        let context = UIGraphicsGetCurrentContext()
        if let context = context {
            context.setFillColor(color.cgColor)
            context.fill(rect)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        return image
    }

    class func imageWithColor(color: UIColor, size: CGSize, cornerRadius: CGFloat) -> UIImage? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        view.layer.cornerRadius = cornerRadius
        view.layer.masksToBounds = true
        view.backgroundColor = color

        UIGraphicsBeginImageContextWithOptions(size,false,0);
        let context = UIGraphicsGetCurrentContext()
        guard context != nil else {
            return nil
        }
        view.layer.render(in: context!)
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        return image
    }
}
