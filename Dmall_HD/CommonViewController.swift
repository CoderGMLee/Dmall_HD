//
//  CommonViewController.swift
//  Dmall_HD
//
//  Created by GM on 17/2/10.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol CommonVCProperty {
    var pageStoreId : String? {set get}
    var pageVenderId : String? {set get}
    var pageReferer : String? {set get}
}

class CommonViewController: DMPage{

    //MARK:- Property - Public
    var _pageStoreId : String?
    var _pageVenderId : String?
    var _pageReferer : String?
    var prevController : CommonViewController?
    var callbackObject : Any?
    var hideCustomNavigationBar = false
    var networkErrorView : EmptyView?
    var emptyView : EmptyView?

    //MARK:- Property - Private
    private(set) var navigationBar: NavigationBar!


    //MARK:- Method - Public
    override func backward() {
        self.navigator.backward()
    }

    /// 自动登录 completion块返回登录情况，成功/失败
    ///
    /// - Parameter completion: 结束回调
    func autoLoginWithCompletion(completion: @escaping (Bool) -> ()) {
        UserDefaultManager.shared.autoLoginWithCompletion { (finish) in
            completion(finish)
        }
    }

    /// 去登录界面
    func toLoginInterface() {
        if let userOnline = UserDefaultManager.shared.isUserOnLine {
            if userOnline {
                self.forWardNextPage(pageUrl: "app://loginpage")
            }
        }
    }

    func handleFailure(response: BaseResponse) {

        let infoImage = UIImage(named: "info")
        SVProgressHUD.setInfoImage(infoImage)
        SVProgressHUD.showInfo(withStatus: response.result)
        SVProgressHUD.dismiss()
    }

    func handleError(error: Error, frame: CGRect) {
        SVProgressHUD.dismiss()
        if self.networkErrorView == nil {
            self.networkErrorView = Bundle.main.loadNibNamed("EmptyView", owner: self, options: nil)?[0] as? EmptyView
            var rect = frame
            if rect == CGRect.zero {
                rect = UIConfig.navFrame
            }
            self.networkErrorView?.frame = rect
            self.networkErrorView?.emptyType = .networkError
            self.networkErrorView?.delegate = self
            if let networkErrorView = self.networkErrorView {
                self.view.addSubview(networkErrorView)
            }
        }
    }

    func handleEmptyView(emptyType: EmptyViewType, frame: CGRect) {

        SVProgressHUD.dismiss()
        var rect = frame
        if rect == CGRect.zero {
            rect = UIConfig.navFrame
        }

        if self.emptyView == nil {
            self.emptyView = Bundle.main.loadNibNamed("EmptyView", owner: self, options: nil)?[0] as? EmptyView
            self.emptyView?.delegate = self
            if let emptyView = self.emptyView {
                self.view.addSubview(emptyView)
            }
        }
        self.emptyView?.frame = rect
        self.emptyView?.emptyType = emptyType
        self.emptyView?.isHidden = false
    }

    func processErrorAction() {

    }

    func processEmptyAction() {

    }

    func forWardNextPage(pageUrl: String, pageStoreId: String, pageVenderId: String) {
        if pageUrl.characters.count > 0 {
            let url = self.UrlAttachPageStore(url: pageUrl, storeId: pageStoreId, venderId: pageVenderId)
            self.navigator.forward(url)
        }
    }

    func forWardNextPage(pageUrl: String, pageStoreId: String, pageVenderId: String, callback: @escaping ([AnyHashable : Any]?) -> ()) {
        if pageUrl.characters.count > 0 {
            let url = self.UrlAttachPageStore(url: pageUrl, storeId: pageStoreId, venderId: pageVenderId)
            self.navigator.forward(url, callback: callback)
        }
    }

    func forWardNextPage(pageUrl: String) {
        if pageUrl.characters.count > 0 {
            let url = self.UrlAttachPageStore(url: pageUrl, storeId: nil, venderId: nil)
            self.navigator.forward(url)
        }
    }

    func forWardNextPage( url: String, callback:  @escaping ([AnyHashable : Any]?) -> () ) {
        if pageUrl.characters.count > 0 {
            let url = self.UrlAttachPageStore(url: pageUrl, storeId: nil, venderId: nil)
            self.navigator.forward(url, callback: callback)
        }
    }

    //MARK:- getRealStoreId and venderId protocol method
    func getRealStoreIdWithStoreId(storeId: String) -> String {
        var ret = storeId
        if let pageStoreId = self.pageStoreId {
            if pageStoreId.characters.count > 0 {
                ret = pageStoreId
                return ret
            }
        }
        if let tmpStoreId = UserDefaultManager.shared.curStoreInfo?.storeId {
            ret = tmpStoreId
            return ret
        }
        return ret
    }

    func getRealVenderIdWithVenderId(venderId: String) -> String {
        var ret = venderId
        if let pageVenderId = self.pageVenderId {
            if pageVenderId.characters.count > 0 {
                ret = pageVenderId
                return ret
            }
        }
        if let tmpVenderId = UserDefaultManager.shared.curStoreInfo?.venderId {
            ret = tmpVenderId
            return ret
        }
        return ret
    }

    //MARK:- Private Method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.appBackgroundColor
        if !self.hideCustomNavigationBar {
            self.navigationBar = NavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.width,height: UIConfig.navigationBarHei))
            self.navigationBar.barTintColor = UIColor.white
            self.view.addSubview(self.navigationBar)

            let backButton = UIButton(type: .custom)
            backButton.setImage(UIImage(named: "navigation_btn_back"), for: .normal)
            backButton.frame = CGRect(x: 0, y: 20, width: 44, height: 44)
            backButton.addTarget(self, action: .actionForBackButton, for: .touchUpInside)
            self.navigationBar.leftView = backButton
        }

        SVProgressHUD.setBackgroundColor(UIColor.black)
        SVProgressHUD.setForegroundColor(UIColor.white)
        self.automaticallyAdjustsScrollViewInsets = false
    }

    override func pageWillBeShown() {
        super.pageWillBeShown()
        UIApplication.shared.statusBarStyle = .default
    }

    override func pageWillBeHidden() {
        super.pageWillBeHidden()
        SVProgressHUD.dismiss()
    }

    func canNotForwardUrl(urlStr: String) {
        if urlStr.characters.count > 0 {
            AppConfigure.shared.checkVersion(isManual: true)
        }
    }


    func actionForBackButton(button: UIButton) {
        self.backward()
    }

    func UrlAttachPageStore(url: String, storeId: String?, venderId: String?) -> String {

        var attachUrl = ""
        if url.characters.count > 0 {
            attachUrl = url
            if url.hasPrefix("http://") || url.hasPrefix("https://"){
                return attachUrl
            }
        }

        var attachStoreId = ""
        var attachVenderId = ""
        if let count = storeId?.characters.count, count > 0 {
            attachStoreId = storeId!
        } else if let pageStoreId = self.pageStoreId {
            attachStoreId = pageStoreId
        }

        if let count = venderId?.characters.count, count > 0 {
            attachVenderId = venderId!
        } else if let venderId = self.pageVenderId {
            attachVenderId = venderId
        }

        if attachStoreId.characters.count > 0 {
            if let urlRange = attachUrl.range(of: "pageStoreId="), urlRange.isEmpty == true {
                if let tmpRange = attachUrl.range(of: "?"), tmpRange.isEmpty == true {
                    attachUrl.append("&")
                    attachUrl.append("pageStoreId=\(attachStoreId)")
                } else {
                    attachUrl.append("?")
                    attachUrl.append("pageStoreId=\(attachStoreId)")
                }
            }
        }

        if attachVenderId.characters.count > 0 {
            if let urlRange = attachUrl.range(of: "pageVenderId="), urlRange.isEmpty == true {
                if let tmpRange = attachUrl.range(of: "?"), tmpRange.isEmpty == true {
                    attachUrl.append("&")
                    attachUrl.append("pageVenderId=\(attachVenderId)")
                } else {
                    attachUrl.append("?")
                    attachUrl.append("pageVenderId=\(attachVenderId)")
                }
            }
        }
        return attachUrl
    }

}




// MARK: - CommonVCProperty
extension CommonViewController : CommonVCProperty {

    var pageStoreId : String? {
        set {
            _pageStoreId = newValue
        }
        get {
            return _pageStoreId
        }
    }

    var pageVenderId: String? {
        set {
            _pageVenderId = newValue
        }
        get {
            return _pageVenderId
        }
    }

    var pageReferer: String? {
        set {
            _pageReferer = newValue
        }
        get {
            return _pageReferer
        }
    }
}

extension CommonViewController : EmptyViewDelegate {

    func emptyViewDidAction(emptyView: EmptyView) {

    }
}


// MARK: - Selector
private extension Selector {
    static let actionForBackButton = #selector( CommonViewController.actionForBackButton(button:) )
}

