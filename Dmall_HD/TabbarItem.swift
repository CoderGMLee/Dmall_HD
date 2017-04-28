//
//  TabbarItem.swift
//  Dmall_HD
//
//  Created by GM on 17/2/13.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit

class TabbarItem: UIView {

    var proSelected : Bool = false
    var vMark : String?

    var itemData : TabbarItemData? {
        didSet {
            if let unwrapedItemData = itemData {
                if let type = unwrapedItemData.type {
                    setItemType(itemType: type)
                }
                if let itemView = subviews[0] as? ItemView {
                    itemView.tabSize = (itemRect?.size)!
                    itemView.title = itemData?.name
                    itemView.titleColor = itemData?.titleColor
                    itemView.selectTitleColor = itemData?.selectTitleColor
                    itemView.setTitleSelect(isSelect: selected)
                    itemView.setPng(itemData?.unselectedImgUrl ?? "", pngDefault: itemData?.originSelectSrc ?? "", gif: itemData?.selectedImgUrl ?? "", gifDefault: itemData?.originSelectSrc ?? "")
                }
            }
        }
    }
    var itemRect : CGRect? {
        didSet {
            if let unwrapedItemRect = itemRect {
                self.frame = unwrapedItemRect
            }
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    func setItemType(itemType: ItemType) {
        switch itemType {
        case .home:
            vMark = "homeIcon"
        case .category:
            vMark = "categoryIcon"
        case .featured:
            vMark = "featureedIcon"
        case .shopCart:
            vMark = "shopcartIcon"
        case .mine:
            vMark = "mineIcon"
        }
    }

    func setTabCount(count: Int) {
        if let itemView = subviews[0] as? ItemView {
            itemView.setItemCount(count: count)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setItemView()
    }

    func setItemView() {
        if let itemView = self.subviews[0] as? ItemView {
            itemView.tabSize = frame.size
        }
    }

}

// MARK: - Selectable
extension TabbarItem : Selectable {
    var selected : Bool {
        set {
            self.proSelected = newValue
            if let itemView = subviews[0] as? ItemView {
                if proSelected {
                    itemView.setTitleSelect(isSelect: true)
                    itemView.showPngImageView(isShow: false)
                    itemView.showGifView(isShow: true)
                    itemView.playOnce()
                } else {
                    itemView.setTitleSelect(isSelect: false)
                    itemView.showPngImageView(isShow: true)
                    itemView.showGifView(isShow: false)
                }
            }
        }
        get {
            return proSelected
        }
    }
}
