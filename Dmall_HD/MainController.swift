//
//  MainController.swift
//  Dmall_HD
//
//  Created by GM on 17/2/9.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit

class MainController: DMNibController {

    //MARK:- Property
    var navigatorViewContainer : UIView?
    let navigator = DMNavigator()
    var tabbarItemSrc = [TabbarItemData]()
    ////用来判断是否第一次进页面，之后点击tabar进行数据上报
    var isFirstIn = true
    var tabbarData : TabbarData?
    var tabbar : Tabbar?
    var tabbarView : TabbarView?
    var actionSheetActions : [AnyClass]?
    static var _DMMainController_webPageClasses = [AnyClass]()

    static let shared = MainController()
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        registAppPages()
        registBridges()
        registWebPageClasses()
        NotificationCenter.default.addObserver(self, selector: .actionForCodeLoginExpired, name: NSNotification.Name(rawValue: KAppCodeLoginExpiredNotification), object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    //MARK:- Function

    func updateTabbarVisable(url: String, animated: Bool) {
        tabbar?.setVisable(visable: isMainUrl(url: url), animated: animated)
    }


    func isMainPage(url: String) -> Bool {
        if url.contains("isMainPage=false") {
            return false
        }
        return isMainUrl(url: url)
    }

    func tabbarVisable() -> Bool{
        if let visable = tabbar?.visable {
            return visable
        }
        return false
    }

    func isMainUrl(url: String) -> Bool {

        for itemData in tabbarItemSrc {
            if let resource = itemData.resource {
                if urlMatch(str: url, strPrefix: resource) {
                    return true
                }
            }
        }
        return false
    }

    func urlMatch(str: String, strPrefix: String) -> Bool {

        var left = str
        var right = strPrefix

        if let range = left.range(of: "?") {
            if range.isEmpty == false {
                left = left.substring(to: range.lowerBound)
            }
        }

        if let range = right.range(of: "?") {
            if range.isEmpty == false {
                right = right.substring(to: range.lowerBound)
            }
        }
        return left == right
    }

    //MARK:- life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        navigatorViewContainer = UIView(frame: self.view.bounds)
        self.view.addSubview(navigatorViewContainer!)
        setDefaultTabbarData()
        navigator?.view.frame = UIScreen.main.bounds
        navigatorViewContainer?.addSubview((self.navigator?.view)!)
        checkAndShowStartVideo()
    }

    func actionForCodeLoginExpired(noti: Notification) {
        if ((topPage() as? LoginPage) != nil) {
            return
        }
        UserDefaultManager.shared.clearLoggedUser()
        MainController.shared.pushFlow()
        MainController.shared.forward("app://LoginPage?@animate=pushtop")

    }

    func registAppPages() {
        DMNavigator.registAppPage("home", pageClass: HomePage.self)
        DMNavigator.registAppPage("category", pageClass: CategoryPage.self)
        DMNavigator.registAppPage("presale", pageClass: WebPresaleListViewController.self)
        DMNavigator.registAppPage("shopcart", pageClass: ShopCartPage.self)
        DMNavigator.registAppPage("mine", pageClass: MinePage.self)
        DMNavigator.registAppPage("DMOrderListPage", pageClass: OrderListPage.self)
        DMNavigator.registAppPage("GlobalSelectDetailPage", pageClass: GlobalSelectDetailPage.self)
    }

    func registBridges() {
        DMBridgeHelper.getInstance().registBridge(WebBridgeObject())
    }

    func registWebPageClasses() {

        MainController._DMMainController_webPageClasses.append(PresaleOrderConfirmVC.self)
        MainController._DMMainController_webPageClasses.append(WebPresaleListViewController.self)
        MainController._DMMainController_webPageClasses.append(WebDetailOfActivity.self)
        MainController._DMMainController_webPageClasses.append(PresaleMiaoshaOrderconfirmVcViewController.self)
        MainController._DMMainController_webPageClasses.append(BaseWebVC.self)
    }


    /// 检查是否需要展示开场视频
    func checkAndShowStartVideo() {
        let videoShownKey = "/Main/StartVideoShown"
        let videoShown = DMCache.getInstance().data(forKey: videoShownKey) != nil
        if videoShown {
            onEnterMainPage()
            return
        }
        DMCache.getInstance().setData("true".data(using: String.Encoding.utf8), forKey: videoShownKey)
        navigator?.forward("app://DMStartVideoPage?@animate=null&@jump=true", callback: { [weak self](param) in
            self?.onEnterMainPage()
        })
    }

    func onEnterMainPage() {
        self.navigator?.delegate = self
        AppConfigure.shared.startMonitorNet()
        addTabBar()
        AppConfigure.shared.checkVersion(isManual: false)
        AppConfigure.shared.reportAppStarted()
    }

    func addTabBar() {

        func setTabbarItem(curSelect: Int) {
            let count = tabbarItemSrc.count
            let width = UIConfig.screenWid / CGFloat(count)
            for index in tabbarItemSrc.indices {
                tabbarView?.addSubview(addTabbarItem(width: width, index: index))
            }
            tabbarView?.selectTab(index: curSelect, isClick: true)
        }

        if tabbarView == nil {
            tabbar = Tabbar()
            tabbarDecorate()
            tabbarView = TabbarView(frame: CGRect(x:0, y:1, width:UIScreen.main.bounds.width, height:48))
            tabbarView?.delegate = self
            setTabbarItem(curSelect: 0)
            if let tabbarView = tabbarView {
                tabbar?.addSubview(tabbarView)
            }
            if let tabbar = tabbar {
                view.addSubview(tabbar)
            }
        } else {
            tabbarDecorate()
            tabbarReset()

            let selectInt = tabbarView?.selectedTab
            if let select = selectInt {
                tabbarView?.selectTab(index: select, isClick: true)
            }
            tabbarView?.isHidden = false
        }
    }

    func tabbarReset() {

        func setItem(item: TabbarItem, data: TabbarItemData) {
            item.itemData = data
        }

        if tabbarView?.subviews.count == 5 {
            tabbarView?.subviews[2].removeFromSuperview()
        }

        if tabbarItemSrc.count == 5 {
            let width = UIScreen.main.bounds.width / 5
            let item = addTabbarItem(width: width, index: 2)
            tabbarView?.insertSubview(item, at: 2)
            let count = tabbarView?.subviews.count ?? 0
            for index in 0...count {
                if let item = tabbarView?.subviews[index] as? TabbarItem {
                    item.itemRect = CGRect(x: width * CGFloat(index), y: 0, width: width, height: 48)
                    setItem(item: item, data: tabbarItemSrc[index])
                }
            }
        } else if tabbarItemSrc.count == 4 {
            let width = UIScreen.main.bounds.width / 4
            let count = tabbarView?.subviews.count ?? 0
            for index in 0...count {
                if let item = tabbarView?.subviews[index] as? TabbarItem {
                    item.itemRect = CGRect(x: width * CGFloat(index), y: 0, width: width, height: 48)
                    setItem(item: item, data: tabbarItemSrc[index])
                }
            }
        }
    }

    func addTabbarItem(width: CGFloat, index: Int) -> TabbarItem {

        func setItemView(width: CGFloat, data:TabbarItemData) -> ItemView {
            let itemView = ItemView(frame: CGRect(x: 0, y: 0, width: width, height: tabbarView?.height ?? 0))
            itemView.showTitle = data.showName ?? false
            itemView.title = data.name ?? ""
            itemView.titleColor = data.titleColor ?? ""
            itemView.selectTitleColor = data.selectTitleColor ?? ""
            if data.type == .shopCart {
                itemView.shopCart = true
            } else {
                itemView.shopCart = false
            }
            itemView.setPng(data.unselectedImgUrl ?? "", pngDefault: data.originSelectSrc ?? "", gif: data.selectedImgUrl ?? "", gifDefault: data.originSelectSrc ?? "")
            return itemView
        }

        let item = TabbarItem(frame: CGRect(x: (width * CGFloat(index)), y:0, width: width, height: tabbarView?.height ?? 0))
        let data = tabbarItemSrc[index]
        item.addSubview(setItemView(width: width, data: data))
        return item
    }

    func tabbarDecorate() {
        if tabbarData != nil {
            tabbar?.showSplitLine = tabbarData?.showSplitLine
            tabbar?.showBgImg = (tabbarData?.showBgImg)!
            tabbar?.bgUrl = tabbarData?.bgImgUrl
        } else {
            tabbar?.showSplitLine = true
            tabbar?.showBgImg = false
            tabbar?.bgUrl = nil
        }
    }

    func setDefaultTabbarData() {
        if tabbarItemSrc.count > 0 {
            tabbarItemSrc.removeAll()
        }

        let tab0 = TabbarItemData()
        tab0.type = .home
        tab0.name = "首页"
        tab0.showName = true
        tab0.titleColor = "#666666"
        tab0.selectTitleColor = "#e96113"
        tab0.resource = "app://home?@animate=null&@jump=true"
        tab0.unselectedImgUrl = "icon_tab_home.png"
        tab0.selectedImgUrl = "icon_tab_home_active.png"
        tab0.originUnselectSrc = "icon_tab_home.png"
        tab0.originSelectSrc = "icon_tab_home_active.png"

        let tab1 = TabbarItemData()
        tab1.type = .category
        tab1.name = "分类"
        tab1.showName = true
        tab1.titleColor = "#666666"
        tab1.selectTitleColor = "#e96113"
        tab1.resource = "app://category?selectedBusinessCode=0&@animate=null&@jump=true"
        tab1.unselectedImgUrl = "icon_tab_category.png"
        tab1.selectedImgUrl = "icon_tab_category_active.png"
        tab1.originUnselectSrc = "icon_tab_category.png"
        tab1.originSelectSrc = "icon_tab_category_active.png"

        let tab2 = TabbarItemData()
        tab2.type = .shopCart
        tab2.name = "购物车"
        tab2.showName = true
        tab2.titleColor = "#666666"
        tab2.selectTitleColor = "#e96113"
        tab2.resource = "app://shopcart?@animate=null&@jump=true"
        tab2.unselectedImgUrl = "icon_tab_shopcart.png"
        tab2.selectedImgUrl = "icon_tab_shopcart_active.png"
        tab2.originUnselectSrc = "icon_tab_shopcart.png"
        tab2.originSelectSrc = "icon_tab_shopcart_active.png"

        let tab4 = TabbarItemData()
        tab4.type = .mine;
        tab4.name = "我";
        tab4.showName = true;
        tab4.titleColor = "#666666";
        tab4.selectTitleColor = "#e96113";
        tab4.resource = "app://mine?@animate=null&@jump=true";
        tab4.unselectedImgUrl = "icon_tab_mine.png";
        tab4.selectedImgUrl = "icon_tab_mine_active.png";
        tab4.originUnselectSrc = "icon_tab_mine.png";
        tab4.originSelectSrc = "icon_tab_mine_active.png";

        tabbarItemSrc.append(tab0)
        tabbarItemSrc.append(tab1)
        tabbarItemSrc.append(tab2)
        tabbarItemSrc.append(tab4)
    }


    func forward(_ url: String, pageStoreId: String? = nil, pageVenderId: String? = nil) {
        var forwardUrl = url

        var storeId : String?
        var venderId : String?

        if let unwrapedStoreId = pageStoreId {
            storeId = unwrapedStoreId
        } else {
            let topPage = navigator?.topPage()
            if let page = topPage {
                if let commonPage = page as? CommonViewController {
                    if let unwrapedStoreId = commonPage.pageStoreId {
                        storeId = unwrapedStoreId
                    }
                }
            }
        }

        if let unwrapedVenderId = pageVenderId {
            venderId = unwrapedVenderId
        } else {
            if let topPage = navigator?.topPage() {
                if let commonPage = topPage as? CommonViewController {
                    if let unwrapedVenderId = commonPage.pageVenderId {
                        venderId = unwrapedVenderId
                    }
                }
            }
        }

        if let unwrapStoreId = storeId {
            if let range = forwardUrl.range(of: "pageStoreId=") {
                if range.isEmpty {
                    forwardUrl = forwardUrl.appending("&pageStoreId=" + unwrapStoreId)
                } else {
                    forwardUrl = forwardUrl.appending("?pageStoreId=" + unwrapStoreId)
                }
            }
        }

        if let unwrapVenderId = venderId {
            if let range = forwardUrl.range(of: "pageVenderId=") {
                if range.isEmpty {
                    forwardUrl = forwardUrl.appending("&pageVenderId=" + unwrapVenderId)
                } else {
                    forwardUrl = forwardUrl.appending("?pageVenderId=" + unwrapVenderId)
                }
            }
        }
        navigator?.forward(forwardUrl)
    }

    func pushFlow() {
        navigator?.pushFlow()
    }

    func backward() {
        navigator?.backward()
    }

    func topPage() -> DMPage?{
        return navigator?.topPage()
    }

    func topPage(deep: Int32) -> DMPage?{
        return navigator?.topPage(deep)
    }

    func popFlow(param: String) {
        navigator?.popFlow(param)
    }

    func rollup() {
        navigator?.rollup()
    }

    func navigatorView() -> UIView? {
        return navigator?.view
    }
}

extension MainController: TabbarDelegate {
    func tabbar(_ tabbar: TabbarView, didSelectTab index: Int) {
        navigator?.forward(tabbarItemSrc[index].resource)
        if index == 0 && isFirstIn == false {
            isFirstIn = true
        } else {
            //TODO:- 上报
        }
    }
}

extension MainController: DMNavigatorDelegate {
    func navigator(_ navigator: DMNavigator, shouldCachePage url: String) -> Bool{
        return isMainUrl(url: url) && !url.hasPrefix("http")
    }

    ////此方法中不应该再有跳转页面的操作
    func navigator(_ navigator: DMNavigator, willChangePageTo url: String) {
        updateTabbarVisable(url: url, animated: true)
        if isMainPage(url: url) {

            for index in tabbarItemSrc.indices {
                let from = tabbarItemSrc[index].resource
                let to = url
                if let from = from{
                    if urlMatch(str: from, strPrefix: to) {
                        if let tabbarView = tabbarView {
                            if tabbarView.selectedTab == index {
                                return
                            }
                            tabbarView.selectTab(index: index, isClick: false)
                        }
                    }
                }
            }
        }
    }

    func navigator(_ navigator: DMNavigator, shouldForwardTo url: String) -> Bool {
        //TODO:- Native 协议 未完成
        return true
    }

    func initPageArguments(_ from: DMPage, to: DMPage) {
        transmitPageParams(from: from, toPage: to)
    }

    func transmitPageParams(from: DMPage, toPage to: DMPage) {
        if from.isKind(of: CommonViewController.self) && to.isKind(of: CommonViewController.self) {
            if let toPage = to as? CommonViewController {
                if let fromPage = from as? CommonViewController {
                    toPage.pageReferer = fromPage.pageUrl
                }
            }
            if from.isKind(of: BaseWebVC.self) || from.isKind(of: CardHelpPage.self) || from.isKind(of: CardWebPage.self) || from.isKind(of: UPPayBindCardVC.self) {
                if let toPage = to as? CommonViewController {
                    if let fromPage = from as? CommonViewController {
                        toPage.pageStoreId = fromPage.pageStoreId
                        toPage.pageVenderId = fromPage.pageVenderId
                    }
                }
            }
        }
    }
}

private extension Selector {
    static let actionForCodeLoginExpired = #selector(MainController.actionForCodeLoginExpired(noti:))
}


