//
//  LoginPage.swift
//  Dmall_HD
//
//  Created by GM on 17/2/14.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit


enum JumpUrl : String {
    case registPage = "app://RegisterPage"
}

class LoginPage: CommonViewController {

    var accessFlag = false
    var accountField : UITextField!
    var passwordField : UITextField!
    var loginButton : UIButton!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        let topPage = MainController.shared.topPage()
        if (topPage?.isKind(of: NSClassFromString("Dmall_HD.RegisterPage")!))! == false {
            MainController.shared.pushFlow()
        } else {
            accessFlag = true
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.appBackgroundColor
        self.configUI()
    }


    func configUI() {
        configNav()
        configField()
        configLoginButton()
    }

    func configLoginButton() {
        loginButton = UIButton(type: .custom)
        loginButton.frame = CGRect(x: 20, y: passwordField.bottom + 50, width: passwordField.width, height: 50)
        loginButton.setTitle("登录", for: .normal)
        loginButton.setTitleColor(UIColor.white, for: .normal)
        loginButton.backgroundColor = UIColor.app20MainColor
        loginButton.addTarget(self, action: .loginAction, for: .touchUpInside)
        self.view.addSubview(loginButton)
    }

    func configField() {

        let fieldHei : CGFloat = 50.0

        accountField = UITextField(frame: CGRect(x: 20, y: UIConfig.navigationBarHei + 20, width: self.view.width - 40, height: fieldHei))
        accountField.backgroundColor = UIColor.white
        accountField.delegate = self
        accountField.font = UIFont.systemFont(ofSize: 14)
        accountField.placeholder = "手机号"
        let accountLeftView = UIImageView(frame: CGRect(x: 0, y: 0, width: fieldHei, height: fieldHei))
        accountLeftView.image = UIImage(named: "login_icon_phone")
        accountLeftView.contentMode = .center
        accountField.leftView = accountLeftView
        accountField.leftViewMode = .always
        self.view.addSubview(accountField)

        let seperateLine = UIView(frame: CGRect(x: 20, y: accountField.bottom, width: accountField.width, height: 1))
        seperateLine.backgroundColor = UIColor.appBackgroundColor
        self.view.addSubview(seperateLine)

        passwordField = UITextField(frame: CGRect(x: 20, y: seperateLine.bottom, width: self.view.width - 40, height: fieldHei))
        passwordField.font = UIFont.systemFont(ofSize: 14)
        passwordField.backgroundColor = UIColor.white
        passwordField.delegate = self
        passwordField.placeholder = "请输入手机号"
        let passwordLeftView = UIImageView(frame: CGRect(x: 0, y: 0, width: fieldHei, height: fieldHei))
        passwordLeftView.image = UIImage(named: "login_icon_code")
        passwordLeftView.contentMode = .center
        passwordField.leftView = passwordLeftView
        passwordField.leftViewMode = .always
        self.view.addSubview(passwordField)
    }

    func configNav() {
        self.navigationBar.title = "欢迎来到多点"
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "login_btn_close_highlight"), for: .normal)
        backButton.frame = CGRect(x: 0, y: 20, width: 44, height: 44)
        backButton.addTarget(self, action: .backWard, for: .touchUpInside)
        self.navigationBar.leftView = backButton

        let registButton = UIButton(type: .custom)
        registButton.frame = CGRect(x: self.view.width - 54, y : 20, width: 44, height: 44)
        registButton.setTitle("注册", for: .normal)
        registButton.setTitleColor(UIColor.black, for: .normal)
        registButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        registButton.addTarget(self, action: .registAction, for: .touchUpInside)
        self.navigationBar.rightView = registButton
    }

    func backButtonAction(button : UIButton) {
        if accessFlag {
            self.navigator.backward()
        } else {
            self.navigator.popFlow("@animate=popbottom")
        }
    }

    func registButtonAction(button: UIButton) {
        self.navigator.forward(JumpUrl.registPage.rawValue)
    }

    func loginButtonAction(button: UIButton) {
        let loginRequest = LoginRequest()
        loginRequest.phone = accountField.text
        if let password = passwordField.text {
            loginRequest.pwd = (password as NSString).md5() as String
        }
        loginRequest.loginType = 1
        loginRequest.cid = UserDefaultManager.shared.cid

        let _ = loginRequest.customParam

        HttpClient.shared.connectWithRequest(request: loginRequest, successHandle: { (response : LoginResponse) in
            print(response.result ?? "")
        }, failHandle: { (resultStr) in
            print(resultStr ?? "")
        }) { (error) in
            print(error)
        }
    }
}

//MARK:- Selector
private extension Selector {
    static let backWard = #selector( LoginPage.backButtonAction(button:) )
    static let registAction = #selector( LoginPage.registButtonAction(button:) )
    static let loginAction = #selector( LoginPage.loginButtonAction(button:) )
}


extension LoginPage : UITextFieldDelegate {

}
