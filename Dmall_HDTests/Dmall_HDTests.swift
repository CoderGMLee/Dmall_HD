//
//  Dmall_HDTests.swift
//  Dmall_HDTests
//
//  Created by GM on 17/1/18.
//  Copyright © 2017年 dmall. All rights reserved.
//

import XCTest


@testable import Dmall_HD

class Dmall_HDTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        func networkTest() {
            let request = BaseRequest()
            HttpClient.shared.connectWithRequest(request: request, successHandle: { (responseStr) in

            print(responseStr ?? "success")

            }, failHandle: { (responseStr) in

            print(responseStr ?? "fail")

            }) { (error) in
                
                print(error.localizedDescription)
                
            };
        }
        networkTest()

    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
