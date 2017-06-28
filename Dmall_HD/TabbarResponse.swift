//
//  TabbarResponse.swift
//  Dmall_HD
//
//  Created by GM on 2017/6/21.
//  Copyright © 2017年 dmall. All rights reserved.
//

import Foundation
import ObjectMapper
class TabbarResponse: BaseResponse {

    var data : TabbarData?
    override func mapping(map: Map) {
        super.mapping(map: map)
        data <- map["data"]
    }
}
