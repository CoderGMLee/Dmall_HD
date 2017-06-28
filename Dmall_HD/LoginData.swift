//
//  LoginData.swift
//  Dmall_HD
//
//  Created by GM on 2017/6/1.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit
import ObjectMapper
class LoginData: BaseObject {

    var registerPrize : String?
    var webUser : [UserInfo]?

    override func mapping(map: Map) {
        super.mapping(map: map)
        registerPrize <- map["registerPrize"]
        webUser <- map["webUser"]
    }
}
