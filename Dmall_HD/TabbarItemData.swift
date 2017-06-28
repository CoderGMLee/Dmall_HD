//
//  TabbarItemData.swift
//  Dmall_HD
//
//  Created by GM on 17/2/9.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit
import ObjectMapper
enum ItemType {
    case home, category, featured, shopCart, mine
}

struct TabbarItemData : Mappable{

    var type : ItemType?
    var showName : Bool?
    var resource : String?
    var name : String?
    var titleColor : String?
    var selectTitleColor : String?
    var unselectedImgUrl : String?
    var selectedImgUrl : String?
    var originUnselectSrc : String?
    var originSelectSrc : String?

    init?(map: Map) {

    }
    init() {

    }

    mutating func mapping(map: Map) {
        type <- map["type"]
        showName <- map["showName"]
        resource <- map["resource"]
        name <- map["name"]
        titleColor <- map["titleColor"]
        selectTitleColor <- map["selectTitleColor"]
        unselectedImgUrl <- map["unselectedImgUrl"]
        selectedImgUrl <- map["selectedImgUrl"]
        originUnselectSrc <- map["selectedImgUrl"]
        originSelectSrc <- map["originSelectSrc"]
    }
}
