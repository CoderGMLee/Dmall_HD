//
//  MineResponse.swift
//  Dmall_HD
//
//  Created by GM on 2017/5/16.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit
import ObjectMapper
class MineResponse: BaseResponse {
    var data : MineMainData?
    var msg : String?
    var action : String?
    override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
        msg <- map["msg"]
        action <- map["action"]
    }
}
