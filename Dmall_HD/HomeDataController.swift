//
//  HomeDataController.swift
//  Dmall_HD
//
//  Created by GM on 2017/6/21.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit

class HomeDataController: NSObject {

    func fetchTabbarData(timeout: Int) {
        fetchTabbar(result: nil, failure: nil, error: nil)
    }

    private func fetchTabbar(result:(()->())?, failure:(()->())?, error:(()->())?) {
        HttpClient.shared.connectWithRequest(request: TabbarRequest(), successHandle: { (response: TabbarResponse) in
            
            print(response)
        }, failHandle: { (failStr) in

            print(failStr ?? "123")
        }) { (error) in

            print(error)
        }
    }
}
