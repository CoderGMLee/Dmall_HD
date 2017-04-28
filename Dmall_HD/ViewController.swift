//
//  ViewController.swift
//  Dmall_HD
//
//  Created by GM on 17/1/18.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        networkTest()

        let array = NSMutableArray()
        let index = array.index(of:1)
    }


    func networkTest() {
        let request = BaseRequest()
//        request.method = "POST"
//        request.path = "common/appCommonConfig"

        HttpClient.shared.connectWithRequest(request: request, successHandle: { (responseStr) in

//            print(responseStr)

        }, failHandle: { (responseStr) in

//            print(responseStr)

        }) { (error) in

            print(error.localizedDescription)
            
        };
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

