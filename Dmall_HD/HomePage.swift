//
//  HomePage.swift
//  Dmall_HD
//
//  Created by GM on 17/2/13.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit
import Alamofire
class HomePage: CommonViewController {

    var dataController = HomeDataController()


    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.hideCustomNavigationBar = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.gray

        dataController.fetchTabbarData(timeout: 0)

    }

}
