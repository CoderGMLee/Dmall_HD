//
//  EmptyView.swift
//  Dmall_HD
//
//  Created by GM on 17/2/28.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit

enum EmptyViewType : Int {
    case networkError
    case noBookmark
    case noOrder
    case noWaitPayOrder
    case noWaitSendOrder
    case noWaitReceiveOrder
    case noDoneOrder
    case noThreeMonthOrder
    case noAddress
    case noLoginNoAddress
    case noBindNoAddress
    case noCouponsNow
    case noSearchGoods
    case cartNoGoods
    case noWareEvaluate
    case locationFail
    case noMessage
    case homePageEmpty
    case memberCardEmpty
    case cardDetailEmpty
    case balanceDetailEmpty
    case storedCardEmpty
}


protocol EmptyViewDelegate {
    func emptyViewDidAction(emptyView: EmptyView)
}

class EmptyView: UIView {

    //MARK:- IBOutlet
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var iconViewXConstraint: NSLayoutConstraint!
    @IBOutlet weak var actionButtonWidthContraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewCenterY: NSLayoutConstraint!

    //MARK:- Property - Public
    var emptyType : EmptyViewType = .networkError {
        didSet {
            let imageName = icons[emptyType.rawValue]
            self.iconView.image = UIImage(named: imageName)
            self.infoLabel.text = infos[emptyType.rawValue]
            self.subLabel.text = subLabels[emptyType.rawValue]
            if let text = subLabel.text {
                if text.characters.count > 0 {
                    self.infoLabel.textColor = UIColor.app20TextBlackColor
                } else {
                    self.infoLabel.textColor = UIColor.app30RecommedTitleColor
                }
            }

            self.subLabel.isHidden = self.subLabel.text?.characters.count == 0
            let actionString = actionBs[emptyType.rawValue]
            self.actionButton.setTitle(actionString, for: .normal)
            if actionString.characters.count == 0 {
                self.iconViewXConstraint.constant = 60
                self.actionButton.isHidden = true
            } else {
                self.iconViewXConstraint.constant = 0
                self.actionButton.isHidden = false
                let attributes = [NSFontAttributeName : UIFont.systemFont(ofSize: 14)]
                let rect = actionString.boundingRect(with: CGSize(width: 160, height: 320),
                                                             options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                             attributes: attributes,
                                                             context: nil)
                self.actionButtonWidthContraint.constant = rect.size.width + 64
            }
        }
    }
    var delegate : EmptyViewDelegate?


    //MARK:- Property - Private
    private lazy var icons : [String] = {
        return ["refreshEmpty",
                "myCollectionEmpty",
                "myOrderEmpty",
                "myOrderEmpty",
                "myOrderEmpty",
                "myOrderEmpty",
                "myOrderEmpty",
                "myOrderEmpty",
                "noAddressEmpty",
                "unloginAddresseEmpty",
                "unloginAddresseEmpty",
                "couponEmpty",
                "searchEmpty",
                "shopCartEmpty",
                "noCommentEmpty",
                "locationAddressEmpty",
                "messageEmpty",
                "storeEmpty",
                "memberCardEmpty",
                "cardDetailEmpty",
                "cardDetailEmpty",
                "storedCardEmpty"];
    }()
    private var infos : [String] = {
        return ["啊哦，网络不太顺畅哦~",
                "把感兴趣的商品都收进来吧",
                "虽然没有订单，生活依然美好~",
                "虽然没有订单，生活依然美好~",
                "当前没有待发货的订单",
                "当前没有待收货的订单",
                "当前没有已完成的订单",
                "近三个月内无订单记录",
                "您还没有收货地址哦！",
                "您还没有登录，请登录哦~",
                "绑定手机后，就能轻松管理收货地址啦～",
                "您暂时没有优惠券",
                "咦~没有找到相关商品",
                "辛苦忙碌一天，还是买买买最开心~",
                "暂时木有此类评论哦~",
                "获取定位失败！",
                "您没有相关消息",
                "咦~门店正在升级维护",
                "您还没有任何商家会员卡！",
                "您还没有消费记录哦！",
                "您还没有余额记录哦！",
                "您还没有添加储蓄卡！"]
    }()
    private var subLabels : [String] = {
        return ["",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "请调整关键词进行搜索",
                "",
                "",
                "",
                "享受悠闲惬意的一天~",
                "",
                "",
                "",
                "",
                ""];
    }()

    private var actionBs : [String] = {
        return ["重新加载试试",
                "添加收藏",
                "散散步，购购物",
                "快去挑选商品吧",
                "快去挑选商品吧",
                "快去挑选商品吧",
                "快去挑选商品吧",
                "",
                "新增收货地址",
                "",
                "",
                "",
                "",
                "去逛逛",
                "",
                "",
                "",
                "换个地址，逛逛其他门店",
                "去绑定",
                "",
                "",
                "去添加"];
    }()

    //MARK:- Method - Public
    override func awakeFromNib() {
        super.awakeFromNib()
        self.actionButton.setBackgroundImage(UIImage.imageWithColor(color: UIColor.colorWithString(string: "e5e5e5")), for: .highlighted)
        self.actionButton.layer.borderColor = UIColor.app20CommonColor.cgColor
        self.actionButton.layer.borderWidth = 2
        self.actionButton.layer.masksToBounds = true
        self.actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.actionButton.setTitleColor(UIColor.app20CommonColor, for: .normal)

        self.infoLabel.font = UIFont.systemFont(ofSize: 14)
        self.infoLabel.textColor = UIColor.app30RecommedTitleColor

        self.subLabel.font = UIFont.systemFont(ofSize: 14)
        self.subLabel.textColor = UIColor.app30RecommedTitleColor
        self.subLabel.isHidden = true

        if UIConfig.screenWid == 480 {
            self.containerViewCenterY.constant = -30;
        } else {
            self.containerViewCenterY.constant = -55;
        }


    }
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        if let delegate = self.delegate {
            delegate.emptyViewDidAction(emptyView: self)
        }
    }

}
