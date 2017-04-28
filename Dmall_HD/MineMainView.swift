//
//  MineMainView.swift
//  Dmall_HD
//
//  Created by GM on 17/2/28.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit

protocol MineMainViewDelegate {
    func actionForType(type: MineJumpUrlType)
}

class MineMainView: UIView {

    var tableView : UITableView!
    var delegate : MineMainViewDelegate?
    var isLogin : Bool {
        return UserDefaultManager.shared.checkIsTrueLogin()
    }
//    var sourceArr :

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        configTableView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    //MARK:- Method - Private
    func configTableView() {
        tableView = UITableView(frame: CGRect(x: 0, y: UIConfig.navigationBarHei, width: UIConfig.screenWid, height: UIConfig.screenHei - UIConfig.navigationBarHei), style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        self.addSubview(tableView)
        registCell()
    }

    func registCell() {
        tableView.register(UINib(nibName: .MineNotLoginHeaderCell, bundle: Bundle.main), forCellReuseIdentifier: .MineNotLoginHeaderCell)
        tableView.register(UINib(nibName: .MineOrderCell, bundle: Bundle.main), forCellReuseIdentifier: .MineOrderCell)
        tableView.register(UINib(nibName: .MineBalanceCell, bundle: Bundle.main), forCellReuseIdentifier: .MineBalanceCell)
    }
    

}

// MARK: - UITableViewDelegate
extension MineMainView : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 200
        } else if indexPath.section == 1 {
            return 60
        } else if indexPath.section == 2 {
            return 100
        }
        return 10
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let delegate = delegate {
                delegate.actionForType(type: .loginPage)
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension MineMainView : UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {

            if let headerCell = (tableView.dequeueReusableCell(withIdentifier: .MineNotLoginHeaderCell, for: indexPath) as? MineNotLoginHeaderCell) {
                headerCell.selectionStyle = .none
                return headerCell
            }

        } else if indexPath.section == 1 {

            if let orderCell = tableView.dequeueReusableCell(withIdentifier: .MineOrderCell, for: indexPath) as? MineOrderCell {
                orderCell.selectionStyle = .none
                return orderCell
            }

        } else if indexPath.section == 2 {
            if let balanceCell = tableView.dequeueReusableCell(withIdentifier: .MineBalanceCell, for: indexPath) as? MineBalanceCell {
                balanceCell.selectionStyle = .none
                return balanceCell
            }
        }

        return UITableViewCell()
    }
}



private extension String {
    static let MineNotLoginHeaderCell = "MineNotLoginHeaderCell"
    static let MineOrderCell = "MineOrderCell"
    static let MineBalanceCell = "MineBalanceCell"
}
