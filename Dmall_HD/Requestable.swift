//
//  Requestable.swift
//  Dmall_HD
//
//  Created by GM on 17/3/1.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit
import Alamofire
protocol Requestable {

    var url : String {get}
    var path : String {get}
    var method : HTTPMethod {get}
    var timeoutInterval : Double{get}
    var erpStoreId : String? {get}
    var venderId : String? {get}
    var customParamStr : String? {get}

    func customParameters() -> [String : String]?
}

extension Requestable {

    var url : String {
        return URL(path: path)
    }

    var method : HTTPMethod {
        return .post
    }

    var timeoutInterval : Double {
        return 10
    }

    var erpStoreId : String? {
        return nil
    }

    var venderId : String? {
        return nil
    }

    var customParamStr : String? {
        return nil
    }

    func customParameters() -> [String : String]? {
        guard customParamStr != nil else {
            return nil
        }
        return ["param" : customParamStr!]
    }
}
