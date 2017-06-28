//
//  UserInfo.swift
//  Dmall_HD
//
//  Created by GM on 2017/6/1.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit
import ObjectMapper

class UserInfo: BaseObject {
    var loginId : String?
    var token : String?
    var iconImage : String?
    var phone : String?
    var nickName : String?
    var gender : Int?
    var birthday : String?
    var realName : String?
    var email : String?
    var userId : String?
    var ticketName : String?
    var weChatId : String?
    var levelIcon : String?
    var otpToken : String?
    var newUser : Bool?

    override func mapping(map: Map) {
        super.mapping(map: map)
        loginId <- map["loginId"]
        token <- map["token"]
        iconImage <- map["iconImage"]
        phone <- map["phone"]
        nickName <- map["nickName"]
        gender <- map["gender"]
        birthday <- map["birthday"]
        realName <- map["realName"]
        email <- map["email"]
        userId <- map["userId"]
        ticketName <- map["ticketName"]
        weChatId <- map["weChatId"]
        levelIcon <- map["levelIcon"]
        otpToken <- map["otpToken"]
        newUser <- map["newUser"]
    }
}
