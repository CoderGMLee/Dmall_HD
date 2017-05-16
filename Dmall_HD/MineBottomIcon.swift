//
//  MineBottomIcon.swift
//  Dmall_HD
//
//  Created by GM on 2017/5/16.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit
import ObjectMapper
class MineBottomIcon: Mappable {

    var action : String?
    var icon : String?
    var needLogin : Bool?
    var smallIcon : String?
    var specialIcon : String?
    var statisticsEvent : String?
    var subtitle : String?
    var title : String?

    required init?(map: Map) {

    }
    func mapping(map: Map) {
        action <- map["action"]
        icon <- map["icon"]
        needLogin <- map["needLogin"]
        smallIcon <- map["smallIcon"]
        specialIcon <- map["specialIcon"]
        statisticsEvent <- map["statisticsEvent"]
        subtitle <- map["subtitle"]
        title <- map["title"]
    }
}
