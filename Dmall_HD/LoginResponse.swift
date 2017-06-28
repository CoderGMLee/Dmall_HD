//
//  LoginResponse.swift
//  Dmall_HD
//
//  Created by GM on 2017/6/1.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit
import ObjectMapper
class LoginResponse: BaseResponse {
    var data : LoginData?
    override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }
}
