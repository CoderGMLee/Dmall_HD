//
//  LoginMainView.swift
//  Dmall_HD
//
//  Created by GM on 2017/4/28.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit


protocol LoginMainViewProtocol {

}

class LoginMainView: UIView {
    var delegate : LoginMainViewProtocol?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


}
