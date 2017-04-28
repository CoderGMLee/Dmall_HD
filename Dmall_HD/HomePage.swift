//
//  HomePage.swift
//  Dmall_HD
//
//  Created by GM on 17/2/13.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit

class HomePage: CommonViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.gray
        networkTest()
    }

    func networkTest() {
        let request = MineRequest()
        HttpClient.shared.connectWithRequest(request: request, successHandle: { (responseStr) in

            print(responseStr ?? "success")

        }, failHandle: { (responseStr) in

            print(responseStr ?? "fail")

        }) { (error) in

            print(error.localizedDescription)

        };
    }
}
