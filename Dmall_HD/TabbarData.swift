//
//  TabbarData.swift
//  Dmall_HD
//
//  Created by GM on 17/2/10.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit

class TabbarData: BaseObject {

    var venderId : String?
    var erpStoreId : String?
    var showBgImg : Bool = false
    var bgImgUrl : String?
    var showSplitLine : Bool = false
    var titleSelectedColor : String?
    var titleUnselectedColor : String?
    var menuList : [TabbarItemData]?
}
