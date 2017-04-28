//
//  TabbarView.swift
//  Dmall_HD
//
//  Created by GM on 17/2/10.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit

protocol TabbarDelegate {
    func tabbar(_ tabbar: TabbarView, didSelectTab index: Int)
}


class TabbarView: UIView {

    private var selectedTabIndex = Int.max
    private var visable = true

    var proSelected = false
    var delegate : TabbarDelegate?
    var selectedTab : Int {
        return selectedTabIndex
    }

    //Public Method
    required override init(frame: CGRect) {
        super.init(frame: frame)
        initSelf()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initSelf() {
        backgroundColor = UIColor.clear
    }

    func getShopcartIcon() -> UIView?{
        for subview in self.subviews {
            if let itemUpView = getItemUpView(view: subview) {
                return itemUpView
            }
        }
        return nil
    }



    func selectTab(index: Int, isClick: Bool) {
        if index == selectedTabIndex {
            return
        }
        selectedTabIndex = index
        for (i, subView) in subviews.enumerated() {
            if var subview = subView as? Selectable, i == index {
                subview.selected = true
            } else if var subview = subView as? Selectable{
                subview.selected = false
            }
        }
        if let delegate = delegate {
            delegate.tabbar(self, didSelectTab: index)
        }
    }

    func setShopCartCount(count: Int) {
        for subview in subviews {
            if let subview = subview as? TabbarItem {
                if subview.vMark == "shopcartIcon" {
                    subview.setTabCount(count: count)
                }
            }
        }
    }

    func setMineCount(count: Int) {
        for subview in subviews {
            if let subview = subview as? TabbarItem {
                if subview.vMark == "mineIcon" {
                    subview.setTabCount(count: count)
                }
            }
        }
    }


    //Private Method
    func getItemUpView(view: UIView) -> ItemUpView? {
        for subview in subviews {
            if let subview = subview as? ItemUpView {
                if subview.vMark == "shopcartView" {
                    return subview
                }
            }
            if subview.subviews.count > 0 {
                return getItemUpView(view: subview)
            }
        }
        return nil
    }

    override func didAddSubview(_ subview: UIView) {
        let singleRecognizer = UITapGestureRecognizer(target: self,action: .singleTap)
        singleRecognizer.numberOfTapsRequired = 1
        subview.addGestureRecognizer(singleRecognizer)

        let doubleRecognizer = UITapGestureRecognizer(target: self, action: .doubleTap)
        doubleRecognizer.numberOfTouchesRequired = 2
        subview.addGestureRecognizer(doubleRecognizer)
    }

    func singleTap(sender: UITapGestureRecognizer) {
        didTab(sender: sender)
    }
    func doubleTap(sender: UITapGestureRecognizer) {
        didTab(sender: sender)
        MainController.shared.rollup()
    }
    func didTab(sender: UITapGestureRecognizer) {
        for (index, subview) in subviews.enumerated() {
            if let view = sender.view {
                if view == subview {
                    selectTab(index: index, isClick: true)
                    break
                }
            }
        }
    }
}


// MARK: - Selector
extension Selector {
    static let singleTap = #selector(TabbarView.singleTap(sender:))
    static let doubleTap = #selector(TabbarView.doubleTap(sender:))
}

// MARK: - Selectable
extension TabbarView : Selectable {
    var selected : Bool {
        set {
            proSelected = newValue
        }
        get {
            return proSelected
        }
    }
}
