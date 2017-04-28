//
//  TabbarItemData.swift
//  Dmall_HD
//
//  Created by GM on 17/2/9.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit

enum ItemType {
    case home, category, featured, shopCart, mine
}

class TabbarItemData: BaseObject {

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
}
