//
//  TabbarData.swift
//  Dmall_HD
//
//  Created by GM on 17/2/10.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit
import ObjectMapper
struct TabbarData : Mappable{
    /// This function can be used to validate JSON prior to mapping. Return nil to cancel mapping at this point
    init?(map: Map) {

    }

    var venderId : String?
    var erpStoreId : String?
    var showBgImg : Bool = false
    var bgImgUrl : String?
    var showSplitLine : Bool = false
    var titleSelectedColor : String?
    var titleUnselectedColor : String?
    var menuList : [TabbarItemData]?

    mutating func mapping(map: Map) {
        venderId <- map["venderId"]
        erpStoreId <- map["erpStoreId"]
        showBgImg <- map["showBgImg"]
        bgImgUrl <- map["bgImgUrl"]
        showSplitLine <- map["showSplitLine"]
        titleSelectedColor <- map["titleSelectedColor"]
        titleUnselectedColor <- map["titleUnselectedColor"]
        menuList <- map["menuList"]
    }
}
