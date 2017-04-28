//
//  MinePage.swift
//  Dmall_HD
//
//  Created by GM on 17/2/13.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit

enum MineJumpUrlType : String {
    case orderPage = ""
    case loginPage = "app://LoginPage?@animate=pushtop"
}

class MinePage: CommonViewController {

    private var mainView : MineMainView!
    override func viewDidLoad() {
//        self.hideCustomNavigationBar = true
        super.viewDidLoad()
        configNav()
        self.view.backgroundColor = UIColor.white
    }

    override func loadView() {
        mainView = MineMainView(frame: UIConfig.screenRect)
        mainView.delegate = self
        self.view = mainView
    }


    //MARK:- Method - private

    private func configNav() {

        let buttonCenterY = ( UIConfig.navigationBarHei - 20 ) / 2
        func configRightView() {
            let setButton = UIButton(type: .custom)
            setButton.frame = CGRect(x: 10, y: buttonCenterY, width: 30, height: 30)
            setButton.setImage(UIImage(named: "mineSettingNormal"), for: .normal)
            setButton.addTarget(self, action: .leftNavButtonAction, for: .touchUpInside)
            self.navigationBar.leftView = setButton
        }

        func configLeftView() {
            let messageButton = UIButton(type: .custom)
            messageButton.frame = CGRect(x: UIConfig.screenWid - 40, y: buttonCenterY, width: 30, height: 30)
            messageButton.setImage(UIImage(named: "mineMessageNormal"), for: .normal)
            messageButton.addTarget(self, action: .rightNavButtonAction, for: .touchUpInside)
            self.navigationBar.rightView = messageButton
        }

        self.navigationBar.title = "我的多点"
        configLeftView()
        configRightView()
    }


    func leftNavButtonAction(button: UIButton) {

    }

    func rightNavButtonAction(button: UIButton) {

    }


    private func fetchTabelData () {
        let request = MineRequest()
        HttpClient.shared.connectWithRequest(request: request, successHandle: { (responseStr) in

        }, failHandle: { (responseStr) in

        }) { (error) in

        }
    }
}

extension MinePage : MineMainViewDelegate {
    func actionForType(type: MineJumpUrlType) {
        MainController.shared.forward(type.rawValue)
    }
}

// MARK: - Selector
private extension Selector {
    static let leftNavButtonAction = #selector(MinePage.leftNavButtonAction(button:))
    static let rightNavButtonAction = #selector(MinePage.rightNavButtonAction(button:))
}