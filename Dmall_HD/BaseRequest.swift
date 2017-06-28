//
//  DMBaseRequest.swift
//  Dmall_HD
//
//  Created by GM on 17/1/18.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit


#if PRODUCT

    let HOST                = "appapi.dmall.com"
    let CMSHOST             = "cmsapi.dmall.com"
    let PORT                = ":443"
    let PREFIX              = "/app/"
    let MAINTAINURL         = "https://maintain.dmall.com/maintain/getMaintainStatus"
    let NEWGATEWAYHOST      = "https://pay.dmall.com/client"
    let PREGOODSDETAILURL   = "https://presale.dmall.com/product.html?skuId="
    let PresaleCheckoutUrl  = "https://t.dmall.com/0faT5z?tradeConfId=c38bfd2a4ea64fcd8ae85fe2a2dfb12"
    let PresaleMiaoshaUrl   = "https://miaosha.gift.dmall.com/assets/html/start.html?"
    let HTCheckoutUrl       = "https://t.dmall.com/0faT5z?tradeConfId=c38bfd2a4ea64fcd8ae85fe2a2dfb17"
    let presaleChanle       = "https://m.dmall.com/presale.html"
    let oldPresaleChanle    = "https://presale.dmall.com/channel.html"
    let DATAREPORTURL       = "https://lg.dmall.com/evt"

#elseif QA

    let HOST                = "testappapi1.dmall.com"
    let CMSHOST             = "testcmsapi.dmall.com"
    let PORT                = ":80"
    let PREFIX              = "/app/"
    let MAINTAINURL         = "https://testmaintain.dmall.com/maintain/getMaintainStatus"
    let NEWGATEWAYHOST      = "http://testpay.dmall.com/client"
    let PREGOODSDETAILURL   = "http://testpresale.dmall.com/product.html?skuId="
    let PresaleCheckoutUrl  = "http://testt.dmall.com/0faT5z?tradeConfId=c38bfd2a4ea64fcd8ae85fe2a2dfb12"
    let PresaleMiaoshaUrl   = "http://miaosha.gift.test.dmall.com/assets/html/start.html?"
    let HTCheckoutUrl       = "http://testt.dmall.com/2rK9Kx?tradeConfId=c38bfd2a4ea64fcd8ae85fe2a2dfb17"
    let presaleChanle       = "http://bjm.test.dmall.com:8003/presale.html"
    let oldPresaleChanle    = "http://testpresale.dmall.com/channel.html"
    let DATAREPORTURL       = "http://testlg.dmall.com/evt"


#endif

func URL(path: String) -> String {
    return "http://" + HOST + PORT + PREFIX + path
}
func CMSURL(path: String) -> String {
    return "http://" + CMSHOST + PORT + PREFIX + path
}

class BaseRequest: NSObject{

    var erpStoreId : String?
    var erpVendorId : String?

}

extension BaseRequest : Requestable {

    var path: String {
        return "common/appCommonConfig"
    }
}


