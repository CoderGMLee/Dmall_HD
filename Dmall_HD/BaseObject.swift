//
//  BaseObject.swift
//  Dmall_HD
//
//  Created by GM on 2017/6/1.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit
import ObjectMapper
class BaseObject: NSObject, Mappable {


    required init?(map: Map) {
        
    }

    func mapping(map: Map) {

    }

    //为什么不重写这个方法子类就不能使用这个方法进行初始化
    override init() {
        super.init()
    }
}
