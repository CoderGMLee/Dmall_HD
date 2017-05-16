//
//  MineActivityIcon.swift
//  Dmall_HD
//
//  Created by GM on 2017/5/16.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit
import ObjectMapper
class MineActivityIcon: Mappable {

    var icon : String?
    var action : String?
    var needLogin : Bool?
    var smallIcon : String?
    var specialIcon : String?
    var subtitle : String?
    var title : String?

    required init?(map: Map) {

    }
    func mapping(map: Map) {
        icon <- map["icon"]
        action <- map["action"]
        needLogin <- map["needLogin"]
        smallIcon <- map["smallIcon"]
        specialIcon <- map["specialIcon"]
        subtitle <- map["subtitle"]
        title <- map["title"]
    }
}
