

//
//  UserDefaultManager.swift
//  Dmall_HD
//
//  Created by GM on 17/2/8.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit
import Foundation

let key_store           = "store"
let key_accessToken     = "accessToken"
let key_userpwd         = "userpwd"
let key_userInfo        = "personuserInfo"
let key_loginChannel    = "loginChannel"
let key_userOnline      = "userOnline"
let key_userPhoto       = "userphoto"
let key_photokey        = "photoKey"
let key_openAppAgain    = "openAppFirstTime"
let key_isSpeed         = "isSpeed"
let key_isPayPassword   = "isPayPassword"
let key_isSetPassword   = "isSetPassword"
let key_orderTime       = "ordertime"

let key_category_timestamp     = "category_timestamp"
let key_trackPoint             = "trackPoint"
let key_isBadPop               = "isBadPop"
let key_isShowDetailGuide      = "isShowDetailGuide"
let key_isShowInvoice          = "isShowInvoice"

let key_cid                    = "cid"
let key_userAddress            = "personuserAddress"
let key_cartId                 = "cartId"
let key_tempCodeInfoData       = "codeInfoDataKey"
let key_mineMainHeadImage      = "mineMainHeadImage"

let key_wareDetaiScanType      = "wareDetailScanType"
let key_wechatToken            = "wechatToken"
let key_wechatUserInfo         = "wechatUserInfo"
let key_isOpenSpeed            = "isOpenSpeed"

let key_personInfo             = "personbaseinfo"
let key_gatewayCache           = "gatewayCache"

let key_categoryStoreData      = "categoryStoreData"

let key_cookieId                    = "cookie_id" 
let kStoreInfoChangedNotification   = "StoreInfoChangedNotification" 
let kUserAddressChangedNotification = "UserAddressChangedNotification" 
let kTabbarDataUpdateNotification   = "TabbarDataUpdateNotification" 
let kCallNativeGatewayNotification  = "CallNativeGatewayNotification" 
let kOrderListEvaluateNotification  = "OrderListEvaluateNotification" 
let kAppStartEveryTimeNotificaiton = "AppStartEveryTimeNotificaiton" 
let KHomeBusinessDataShouldRequest = "KHomeBusinessDataShouldRequest" 
let KHomeBusinessDataShouldReload = "KHomeBusinessDataShouldReload" 
let KHomeScanIndicatorShouldShow = "KHomeScanIndicatorShouldShow" 
let KHomeScanIndicatorShow = "KHomeScanIndicatorShow" 

let KAppCodeLoginExpiredNotification = "KAppCodeLoginExpiredNotification" 


let key_isShowOffLineCouponNotice = "isShowOffLineCouponNotice" 
let key_threeDTouchAccessApp = "threeDTouchAccessApp" 
let k3DTouchTypeOffLineScan = "3DTouchTypeOffLineScan" 
let KActivityDismiss = "KActivityDismiss" 
let kVideoShownKey = "StartVideoShown" 

enum LoginChannel {
    case nomal,quick,wechat,wechatLocal
}


class UserDefaultManager: NSObject {
    //MARK:- Property
    private let userDefaults : UserDefaults

    static let shared = UserDefaultManager()
    private override init() {
        userDefaults = UserDefaults()
    }

    //!@brief 是否再次打开app
    var openAppAgain : Bool? {
        set {
            userDefaults.set(newValue, forKey: key_openAppAgain)
            userDefaults.synchronize()
        }
        get {
            return userDefaults.object(forKey: key_openAppAgain) as? Bool
        }
    }

    //!@brief 用户登录后服务器返回的token
    var accessToken : String? {
        set {
            userDefaults.set(newValue, forKey: key_accessToken)
            userDefaults.synchronize()
        }
        get {
            return userDefaults.object(forKey: key_accessToken) as? String
        }
    }

    //!@brief 用户选择的商店信息
    var curStoreInfo : StoreInfo? {
        set {
            if newValue != nil {
                let data = NSKeyedArchiver.archivedData(withRootObject: newValue as Any)
                userDefaults.set(data, forKey: key_store)
                userDefaults.synchronize()
            }
        }
        get {
            if let storeData = userDefaults.object(forKey: key_store) as? Data {
                if let storeInfo = NSKeyedUnarchiver.unarchiveObject(with: storeData) as? StoreInfo {
                    return storeInfo
                }
            }
            return nil
        }
    }

    //!@brief 用户在线状态
    var isUserOnLine : Bool? {
        set {
            userDefaults.set(newValue, forKey: key_userOnline)
            userDefaults.synchronize()
        }
        get {
            return userDefaults.object(forKey: key_userOnline) as? Bool
        }
    }

    //!@brief 用户信息
    var userInfor : User? {
        set {
            if let jsonStr = newValue?.toJSONString() {
                userDefaults.set(jsonStr, forKey: key_userInfo)
                userDefaults.synchronize()
            }
        }
        get {
            if let jsonStr = userDefaults.object(forKey: key_userInfo) as? String {
                return User(JSONString:jsonStr)
            }
            return nil
        }
    }

    //!@brief 密码
    var pwd : String? {
        set {
            userDefaults.set(newValue, forKey: key_userpwd)
            userDefaults.synchronize()
        }
        get {
            return userDefaults.object(forKey: key_userpwd) as? String
        }
    }

    //!@brief 登陆类型
    var loginChannel : LoginChannel? {
        set {
            userDefaults.set(newValue, forKey: key_loginChannel)
            userDefaults.synchronize()
        }
        get {
            return userDefaults.object(forKey: key_loginChannel) as? LoginChannel
        }
    }

    //!@brief 分类页面列表路径
    var categoryListPath : String? {
        get {
            let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            return NSURL(fileURLWithPath:docPath).appendingPathComponent("categorylist.dat")?.absoluteString
        }
    }

    //!@brief cid
    var cid : String? {
        set {
            userDefaults.set(newValue, forKey: key_cid)
            userDefaults.synchronize()
        }
        get {
            return userDefaults.object(forKey: key_cid) as? String
        }
    }

    //!@brief userAddress
    var userAddress : UserAddress? {
        set {
            if let jsonStr = newValue?.toJSONString() {
                userDefaults.set(jsonStr, forKey: key_userAddress)
                userDefaults.synchronize()
            }
        }
        get {
            if let jsonStr = userDefaults.object(forKey: key_userAddress) as? String {
                return UserAddress(JSONString: jsonStr)
            }
            return nil
        }
    }

    //!@brief 用户未登录时的购物车cartId
    var cartId : String? {
        set {
            userDefaults.set(newValue, forKey: key_cartId)
            userDefaults.synchronize()
        }
        get {
            return userDefaults.object(forKey: key_cartId) as? String
        }
    }

    //!@brief 门店海报信息
    var tempCodeInfoData : PosterData? {
        set {
            if let jsonStr = newValue?.toJSONString() {
                userDefaults.set(jsonStr, forKey: key_tempCodeInfoData)
                userDefaults.synchronize()
            }
        }
        get {
            if let jsonStr = userDefaults.object(forKey: key_tempCodeInfoData) as? String {
                return PosterData(JSONString: jsonStr)
            }
            return nil
        }
    }

    //!@brief我的主页头部背景图片
    var mineMainHeadImage : String? {
        set {
            userDefaults.set(newValue, forKey: key_mineMainHeadImage)
            userDefaults.synchronize()
        }
        get {
            return userDefaults.object(forKey: key_mineMainHeadImage) as? String
        }
    }

    //!@brief是否智能加速
    var isSpeed : Bool? {
        set {
            userDefaults.set(newValue, forKey: key_isSpeed)
            userDefaults.synchronize()
        }
        get {
            return userDefaults.object(forKey: key_isSpeed) as? Bool
        }
    }

    //!@brief网络从wifi 变为 移动网络后 在首页或者大商详提示没有
    var isShowNetworkChange : Bool?


    //!@brief是否设置了支付密码
    var isPayPassword : Bool? {
        set {
            userDefaults.set(newValue, forKey: key_isPayPassword)
            userDefaults.synchronize()
        }
        get {
            return userDefaults.object(forKey: key_isPayPassword) as? Bool
        }
    }

    //!@brief是否设置了密码
    var isSetPassword : Bool? {
        set {
            userDefaults.set(newValue, forKey: key_isSetPassword)
            userDefaults.synchronize()
        }
        get {
            return userDefaults.object(forKey: key_isSetPassword) as? Bool
        }
    }

    //!@brief是否绑定了微信
    var isWeiXin : Bool? {
        get {
            if let count = self.userInfor?.weChatId?.characters.count {
                if count > 0 {
                    return true
                }
            }
            return false
        }
    }

    //!@brief小红点类
    var trackPoint : TrackPoint? {
        set {
            if let jsonStr = newValue?.toJSONString() {
                userDefaults.set(jsonStr, forKey: key_trackPoint)
                userDefaults.synchronize()
            }
        }
        get {
            if let jsonStr = userDefaults.object(forKey: key_trackPoint) as? String {
                return TrackPoint(JSONString:jsonStr)
            }
            return nil
        }
    }

    //!@brief 浏览模式
    var scanType : ScanType? {
        set {
            if let jsonStr = newValue?.toJSONString() {
                userDefaults.set(jsonStr, forKey: key_wareDetaiScanType)
                userDefaults.synchronize()
            }
        }
        get {
            if let jsonStr = userDefaults.object(forKey: key_wareDetaiScanType) as? String {
                return ScanType(JSONString : jsonStr)
            }
            return nil
        }
    }

    //!@brief 是否记录弹出订单的时间
    var orderTime : String? {
        set {
            userDefaults.set(newValue, forKey: key_orderTime)
            userDefaults.synchronize()
        }
        get {
            return userDefaults.object(forKey: key_orderTime) as? String
        }
    }

    //!@bried 是否设置过智能加载模式
    var hasOpenSpeed : Bool? {
        set {
            userDefaults.set(newValue, forKey: key_isOpenSpeed)
            userDefaults.synchronize()
        }
        get {
            return userDefaults.object(forKey: key_isOpenSpeed) as? Bool
        }
    }

    //!@bried cookie_id
    var cookieId : String? {
        set {
            userDefaults.set(newValue, forKey: key_cookieId)
            userDefaults.synchronize()
        }
        get {
            return userDefaults.object(forKey: key_cookieId) as? String
        }
    }

    var wechatToken : WechatAccessToken? {
        set {
            if let jsonStr = newValue?.toJSONString() {
                userDefaults.set(jsonStr, forKey: key_wechatToken)
                userDefaults.synchronize()
            }
        }
        get {
            if let jsonStr = userDefaults.object(forKey: key_wechatToken) as? String {
                return WechatAccessToken(JSONString: jsonStr)
            }
            return nil
        }
    }

    var wechatUserInfo : WechatUserInfo? {
        set {
            if let jsonStr = newValue?.toJSONString() {
                userDefaults.set(jsonStr, forKey: key_wechatUserInfo)
                userDefaults.synchronize()
            }
        }
        get {
            if let jsonStr = userDefaults.object(forKey: key_wechatUserInfo) as? String {
                return WechatUserInfo(JSONString: jsonStr)
            }
            return nil
        }
    }

    //!@brief 个人基本信息
    var personInfo : PersonInfoData? {
        set {
            if let jsonStr = newValue?.toJSONString() {
                userDefaults.set(jsonStr, forKey: key_personInfo)
                userDefaults.synchronize()
            }
        }
        get {
            if let jsonStr = userDefaults.object(forKey: key_personInfo) as? String{
                return PersonInfoData(JSONString : jsonStr)
            }
            return nil
        }
    }

    //!@brief 属性时间戳
    var category_timestamp : String? {
        set {
            userDefaults.set(newValue, forKey: key_category_timestamp)
            userDefaults.synchronize()
        }
        get {
            return userDefaults.object(forKey: key_category_timestamp) as? String
        }
    }

    //!@brief 差评弹窗
    var isBadPop : Bool? {
        set {
            userDefaults.set(newValue, forKey: key_isBadPop)
            userDefaults.synchronize()
        }
        get {
            return userDefaults.object(forKey: key_isBadPop) as? Bool
        }
    }

    //!@brief 展示分类页右滑引导图
    var isShowDetailGuide : Bool? {
        set {
            userDefaults.set(newValue, forKey: key_isShowDetailGuide)
            userDefaults.synchronize()
        }
        get {
            return userDefaults.object(forKey: key_isShowDetailGuide) as? Bool
        }
    }

    var gatewayCache : String? {
        set {
            userDefaults.set(newValue, forKey: key_gatewayCache)
            userDefaults.synchronize()
        }
        get {
            return userDefaults.object(forKey: key_gatewayCache) as? String
        }
    }

    var isShowInvoice : String? {
        set {
            userDefaults.set(newValue, forKey: key_isShowInvoice)
            userDefaults.synchronize()
        }
        get {
            return userDefaults.object(forKey: key_isShowInvoice) as? String
        }
    }

    //!@brief 展示线下优惠券公告
    var isShowOffLineCouponNotice : Bool? {
        set {
            userDefaults.set(newValue, forKey: key_isShowOffLineCouponNotice)
            userDefaults.synchronize()
        }
        get {
            return userDefaults.object(forKey: key_isShowOffLineCouponNotice) as? Bool
        }
    }

    //!@brief 记录分类页中用户上次选择的商店信息
    var categoryStoreData : CategoryStoreData? {
        set {
            if let jsonStr = newValue?.toJSONString() {
                userDefaults.set(jsonStr, forKey: key_categoryStoreData)
                userDefaults.synchronize()
            }
        }
        get {
            if let jsonStr = userDefaults.object(forKey: key_categoryStoreData) as? String {
                return CategoryStoreData(JSONString: jsonStr)
            }
            return nil
        }
    }

    //!@brief 3DTouch进入App
    var threeDTouchAccessApp : Bool? {
        set {
            userDefaults.set(newValue, forKey: key_threeDTouchAccessApp)
            userDefaults.synchronize()
        }
        get {
            return userDefaults.object(forKey: key_threeDTouchAccessApp) as? Bool
        }
    }



    //MARK:- Public Function
    //!@brief 自动登录 completion块返回登录情况，成功/失败
    func checkLoginWithCompletion(completion: @escaping (Bool) -> ()) {
        checkLoginAndRegister(type: 1) { (success) in
                completion(success)
        }
    }

    func checkLoginWithRegisterCompletion(completion: (Bool) -> () ) {

    }

    func autoLoginWithCompletion(completion: (Bool) -> () ) {

    }

    func updateAddressInterval() {

    }

    func needCheckLocation() -> (Bool) {

        return false
    }

    func saveLoggedUser(user: User, channel: LoginChannel, storeId: String, venderId: String) {

    }

    func clearLoggedUser() {

    }

    //!@brief 判断是否是真正登录了？true 是 No 不是
    func checkIsTrueLogin() -> Bool{
        return false
    }

    //!@brief 网络从wifi变为移动网络后调用方法
    func networkChangeShowMessage() {

    }


    //MARK:- Private
    private func checkLoginAndRegister(type: Int, completion:(Bool) -> ()) {

        if let isOnline = self.isUserOnLine {
            if isOnline && self.loginChannel != LoginChannel.wechatLocal {
                completion(true)
            }
        } else {
            if self.loginChannel == LoginChannel.wechatLocal {

                let alertVC = UIAlertController(title:"绑定手机购物更安心", message:"",preferredStyle:UIAlertControllerStyle.alert)
                let doneAct = UIAlertAction(title:"确定",style:UIAlertActionStyle.default,handler:{(alertAciton) in
                    alertVC.dismiss(animated: true, completion: nil)
                })
                let cancelAct = UIAlertAction(title:"取消",style:UIAlertActionStyle.default,handler:{(alertAciton) in
                    alertVC.dismiss(animated: true, completion: nil)
                })

                alertVC.addAction(doneAct)
                alertVC.addAction(cancelAct)

                //TODO:-
//                alertVC.show(<#T##vc: UIViewController##UIViewController#>, sender: <#T##Any?#>)

            } else if self.loginChannel == LoginChannel.nomal {

            } else if self.loginChannel == LoginChannel.quick {

            }
        }
    }

    


}
