//
//  DMHttpClient.swift
//  Dmall_HD
//
//  Created by GM on 17/1/18.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AdSupport
import AlamofireObjectMapper
import ObjectMapper


enum ResponseCode : String {
    case success = "0000"
    case expired = "0011"
    case wareStatusChanged = "1113"
    case shipTimeExpired = "1114"
    case couponInvalid = "1119"
    case kcouponError = "1131"

    case phoneExist             = "103004"
    case phoneExistNopassword   = "113004"
    case needGraphicCode        = "100405"
    case invalidGraphicCode     = "100402"
    case errorGraphCode         = "100403"
    case graphCodeExceedMax     = "100404"
    case authCodeExceedMax      = "100204"
}

typealias ResultSuccessHandler = (String?) -> ()
typealias ResultFailureHandler = (String?) -> ()
typealias ResultErrorHandler = (Error) -> ()

class HttpClient: NSObject {

    //MARK:-单例对象
    static let shared = HttpClient();

    var basicHeader = HTTPHeaders()

    private override init() {
        super.init()
        configCommonBasicHeader()
    }

    //MARK:- 请求函数
    func connectWithRequest<T : BaseResponse>(request: Requestable, successHandle: @escaping (_ response : T) -> (), failHandle: @escaping ResultFailureHandler, errorHandle: @escaping ResultErrorHandler) {

        if request.method == .post {

            postRequest(request: request, successHandle: successHandle, failHandle: failHandle, errorHandle: errorHandle)

        } else if request.method == .get {

            getRequest(request: request, successHandle: successHandle, failHandle: failHandle, errorHandle: errorHandle)
        }
    }

    func cancelAllRequest() {

    }

    //POST
    func postRequest<T : BaseResponse>(request:Requestable, successHandle: @escaping (_ response : T) -> (), failHandle: @escaping ResultFailureHandler, errorHandle: @escaping ResultErrorHandler) {

        configRealTimeHeader(request: request);
        let dataRequest = Alamofire.request(request.url, method: .post, parameters: request.customParameters(), encoding: JSONEncoding.default, headers: basicHeader)

        printRequest(request: dataRequest)

        dataRequest.responseObject { (response : DataResponse<T>) in
            let result = response.result
            switch result {
            case let .success(resp) :
                if resp.code == ResponseCode.success.rawValue {
                    successHandle(resp)
                } else {
                    failHandle(resp.result)
                }
            case let .failure(error) :
                errorHandle(error)
            }
        }
    }

    //GET
    private func getRequest<T : BaseResponse>(request:Requestable, successHandle: @escaping (_ response : T) -> (), failHandle: @escaping ResultFailureHandler, errorHandle: @escaping ResultErrorHandler) {

        configRealTimeHeader(request: request);
        let dataRequest = Alamofire.request(request.url, method: .get, parameters: request.customParameters(), encoding: JSONEncoding.default, headers: basicHeader)

        printRequest(request: dataRequest)

        dataRequest.responseObject { (response : DataResponse<T>) in
            let result = response.result
            switch result {
            case let .success(resp) :
                if resp.code == ResponseCode.success.rawValue {
                    successHandle(resp)
                } else {
                    failHandle(resp.result)
                }
            case let .failure(error) :
                errorHandle(error)
            }
        }
    }

    //设置请求头
    private func configCommonBasicHeader() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
//        let device = 
        let systemVersion = UIDevice.current.systemVersion
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier");
        let screenSize = UIScreen.main.bounds.size
        let screenStr = "\(screenSize.height) + \(screenSize.width)"
//        let uuid = 
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString

        if idfa.characters.count > 0 {
            basicHeader["idfa"] = idfa
        }

        if let version = version as? String {
            basicHeader["apiVersion"] = "3.6.0"
            basicHeader["version"] = version
        }

        basicHeader["platform"] = "IOS"
        basicHeader["channelId"] = "APPSTORE"
        basicHeader["sysVersion"] = systemVersion
//        basicHeader["device"] = device
        basicHeader["sysVersion"] = systemVersion
        if let appName = appName as? String {
            basicHeader["appName"] = appName
        }
        basicHeader["screen"] = screenStr
        basicHeader["xyz"] = "ac"
//        basicHeader["uuid"] = uuid
    }


    private func configRealTimeHeader(request: Requestable) {
        if let accessToken = UserDefaultManager.shared.accessToken {
            basicHeader["token"] = accessToken
        }
        if let storeId = request.erpStoreId {
            basicHeader["storeId"] = storeId
        } else if let storeInfo = UserDefaultManager.shared.curStoreInfo {
            if let storeId = storeInfo.storeId {
                basicHeader["storeId"] = storeId
            }
        }
        if let vendorId = request.venderId {
            basicHeader["venderId"] = vendorId
        } else if let storeInfo = UserDefaultManager.shared.curStoreInfo {
            if let venderId = storeInfo.venderId {
                basicHeader["venderId"] = venderId
            }
        }

//        let netType = 
//        let currentTime = 
//        let storeGroup = 
//        let bigDataParaStr = 
        if let isSpeed = UserDefaultManager.shared.isSpeed {
            if isSpeed {
                basicHeader["smartLoading"] = "1"
            } else {
                basicHeader["smartLoading"] = "0"
            }
        }
        basicHeader["networkType"] = ""
        basicHeader["currentTime"] = ""
        basicHeader["lat"] = ""
        basicHeader["lng"] = ""
        basicHeader["gatewayCache"] = ""
        basicHeader["storeGroup"] = ""
        basicHeader["bigdata"] = ""
    }


    //MARK:- Log
    func printRequest(request: DataRequest) {
        print("请求地址:\(String(describing: request.request?.url))")
        print("请求头信息:\(String(describing: request.request?.allHTTPHeaderFields))")
        print("请求类型:\(request.request?.httpMethod ?? "nil")")
    }

    func printResponse<T>(response: DataResponse<T>) {
        if let value = response.result.value {
            print("响应内容:\(value)")
        }
    }
}
