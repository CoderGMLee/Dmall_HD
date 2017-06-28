//
//  TabbarRequest.swift
//  Dmall_HD
//
//  Created by GM on 2017/6/21.
//  Copyright © 2017年 dmall. All rights reserved.
//

import Foundation
import Alamofire
class TabbarRequest : Requestable {
    var path: String {
        return "web/json/bottomNav/1/230"
    }
    var method : HTTPMethod {
        return .get
    }
    var url: String {
        return CMSURL(path: path)
    }
}
