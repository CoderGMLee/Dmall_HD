//
//  BaseResponse.swift
//  Dmall_HD
//
//  Created by GM on 17/2/8.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit
import ObjectMapper

class BaseResponse: Mappable {

    var code : String?
    var result : String?

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        code <- map["code"]
        result <- map["result"]
    }
}
