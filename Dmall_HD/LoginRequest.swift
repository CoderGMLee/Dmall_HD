//
//  LoginRequest.swift
//  Dmall_HD
//
//  Created by GM on 2017/6/1.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit

class LoginRequest: Requestable {

    var phone : String?
    var pwd : String?
    var cid : String?
    var authCode : String?
    var setPwd : Int?
    var loginType : Int?

    var customParamStr: String? {
        get {
            let paramDic = ["phone":phone,"pwd":pwd,"cid":cid,"loginType":String(describing: loginType)]
            let data = try? JSONSerialization.data(withJSONObject: paramDic, options: JSONSerialization.WritingOptions.prettyPrinted)

            let strJson = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
            return strJson
        }
    }

    var customParam: [String : String?]? {
        get {
            return ["phone":phone,"pwd":pwd,"cid":cid,"loginType":String(describing: loginType)]
        }
    }

    var path : String {
        get {
            return "passport/login"
        }
    }
}
