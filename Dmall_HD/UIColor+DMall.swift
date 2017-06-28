//
//  UIColor+DMall.swift
//  Dmall_HD
//
//  Created by GM on 17/2/14.
//  Copyright © 2017年 dmall. All rights reserved.
//

import Foundation

extension UIColor {

    class func color(withR r: Float, withG g: Float, withB b: Float) -> UIColor {
        return UIColor.init(colorLiteralRed: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
    }

    class func colorWithString(string: String) -> UIColor {
        var colorString = string
        if colorString.hasPrefix("#") {
            if colorString.characters.count > 1 {
                let index = colorString.index(colorString.startIndex, offsetBy: 1)
                colorString = colorString.substring(from: index)
            }
        }
        let scanner =  Scanner(string: colorString)
        scanner.charactersToBeSkipped = CharacterSet.symbols

        var hex : UInt64 = 0
        let success = scanner.scanHexInt64(&hex)
        guard success else {
            print("颜色转换失败")
            return UIColor.white
        }
        let red = Float((hex & 0xFF0000) >> 16) / Float(255.0)
        let green = Float((hex & 0x00FF00) >> 8) / Float(255.0)
        let blue = Float((hex & 0x0000FF)) / Float(255.0)
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
    }

    static let appTextColor = UIColor.colorWithString(string: "0x666666")

    static let app30IndicatorColor = UIColor.colorWithString(string: "0xffeaba")

    static let app20BorderColor = UIColor.colorWithString(string: "0xeeeeee")

    static let app20CartBarColor = UIColor.colorWithString(string: "0xf43000")

    static let appBackgroundColor = UIColor.colorWithString(string: "f5f5f5")
    
    static let app20CommonColor = UIColor.colorWithString(string: "0xf46c18")

    static let app30RecommedTitleColor = UIColor.colorWithString(string: "0x999999")

    static let app20TextBlackColor = UIColor.colorWithString(string: "0x36383f")

    static let app20MainColor = UIColor.colorWithString(string: "0xf46c18")
}
