//
//  MineMainData.swift
//  Dmall_HD
//
//  Created by GM on 2017/5/16.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit
import ObjectMapper
struct MineMainData: Mappable {

    var levelIcon : String?
    var levelName : String?
    var cardSum : Int?
    var couponCount : Int?
    var couponWillOverdue : Int?
    var score : Float?
    var level : Int?
    var bottomIcons : [MineBottomIcon]?
    var activityIcon : MineActivityIcon?

    init?(map: Map) {

    }
    
    mutating func mapping(map: Map) {
        levelIcon <- map["levelIcon"]
        levelName <- map["levelName"]
        cardSum <- map["cardSum"]
        couponCount <- map["couponCount"]
        couponWillOverdue <- map["couponWillOverdue"]
        score <- map["score"]
        level <- map["level"]
        bottomIcons <- map["bottomIcons"]
        activityIcon <- map["activityIcon"]
    }

}
