//
//  AppConfigure.swift
//  Dmall_HD
//
//  Created by GM on 17/2/13.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit


enum AppUpdateType {
    case none, force, normal
}

class AppConfigure: NSObject {

    //MARK:- Property
    var clientId : String?
    var appId : String?
    var taskId : String?
//    var lastReachabilityStatus 
    var ioQueue : DispatchQueue?

    static let shared = AppConfigure()
    private override init() {
        super.init()
    }

    //MARK:- Method
    func checkVersion(isManual: Bool) {

    }

    func popupScan() {

    }

    func extraSetup() {

    }

    func startGeTuiSdkWithAppId(_ appId: String, appKey: String, appSecret: String) {

    }

    func loadCartData() {

    }

    func commonConfig() {

    }

    func setGeTuiTags() {

    }

    func reportAppStarted() {

    }

    func systemMaintenance() {

    }

    func startMonitorNet() {

    }

    func getMapKey() -> String {
        return ""
    }

    func  appUpdateType() -> AppUpdateType {
        return .normal
    }


}
