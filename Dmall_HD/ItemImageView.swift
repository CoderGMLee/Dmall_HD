//
//  ItemImageView.swift
//  Dmall_HD
//
//  Created by GM on 17/2/23.
//  Copyright © 2017年 dmall. All rights reserved.
//

import UIKit

class ItemImageView: UIView {

    //MARK:- Public Property
    var haveTitle = false
    var imgSrc : String? {
        willSet {
            if (newValue?.hasPrefix("http"))! {
                downloadImg(imgSrc: newValue ?? "")
                return
            }
            let path = Bundle.main.path(forResource: newValue, ofType: nil)
            if path?.characters.count == 0 {
                downloadImg(imgSrc: newValue ?? "")
                return
            }
            let data = NSData(contentsOfFile: path ?? "")
            if let data = data {
                handleImgData(data: data)
            }
        }
    }

    private var proTabSize = CGSize.zero
    var tabSize : CGSize {
        set {
            proTabSize = newValue
            tabWidth = newValue.width
            tabHeight = newValue.height
            setNeedsLayout()
            layoutIfNeeded()
        }
        get {
            return proTabSize
        }
    }

    //MARK:- Private Property

    private var backgroundImage : UIImage?
    private var imageView : UIImageView?
    private var gifView : DMGifView?
    private var imageSize = CGSize.zero
    private var playOnceRequest = false
    private var playLoopRequest = false
    private var tabWidth : CGFloat = 0
    private var tabHeight : CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
//        backgroundColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0)
        tabWidth = size.width
        tabHeight = size.height
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    //MAKR:- Public Method
    func playOnce() {
        playLoopRequest = true
        if gifView != nil {
            gifView?.playOnce()
        }
    }
    func playLoop() {
        playLoopRequest = true
        if gifView != nil {
            gifView?.playLoop()
        }
    }

    //MAKR:- Private Method
    func clearOldSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }

    func downloadImg(imgSrc: String) {
        //TODO:-
    }

    func handleImgData(data: NSData) {
        let isGIF = isGif(data: data)
        if isGIF {
            handleGif(data: data)
        } else {
            handleImg(data: data)
        }
    }

    /// 判断data是否是Gif
    ///
    /// - Parameter data: 图片资源
    /// - Returns: ture or false
    func isGif(data: NSData) -> Bool {

        guard data.length >= 3 else {
            return false
        }
        let gifHeader: [UInt8] = [0x47, 0x49, 0x46]
        var buffer = [UInt8](repeating: 0, count: 8)
        data.getBytes(&buffer, length: 8)
        if buffer[0] == gifHeader[0] &&
            buffer[1] == gifHeader[1] &&
            buffer[2] == gifHeader[2]
        {
            return true
        }
        return false
    }

    func handleGif(data: NSData) {
        gifView = DMGifView()
        gifView?.load(from: data as Data)
        gifView?.backgroundColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0)
        imageSize = (gifView?.imageSize)!
        clearOldSubviews()
        addSubview(gifView!)
        updateFrame()

        if playOnceRequest {
            gifView?.playOnce()
        }
        if playLoopRequest {
            gifView?.playLoop()
        }
    }

    func updateFrame() {
        let view = self
        view.setNeedsLayout()
        var superView = view.superview
        while superView != nil {
            superView?.setNeedsLayout()
            superView = superView?.superview
        }
    }

    func measureWidth() -> CGFloat {
        if imageSize.width > tabWidth {
            return tabWidth
        }
        return imageSize.width
    }

    func measureHeight() -> CGFloat {
        if imageSize.height > tabWidth {
            let measureWidth = self.measureWidth()
            let rate = measureWidth / imageSize.width
            return imageSize.height * rate
        }
        return imageSize.height
    }

    func handleImg(data: NSData) {

        imageView = UIImageView()
        imageView?.image = UIImage(data: data as Data)
        imageView?.backgroundColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0)
        imageView?.contentMode = .scaleToFill
        if let image = imageView?.image {
            let dpWidth = image.size.width * image.scale / 3
            let dpHeight = image.size.height * image.scale / 3
            imageSize = CGSize(width: dpWidth, height: dpHeight)
        }
        clearOldSubviews()
        addSubview(imageView!)
        updateFrame()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let frame = CGRect(x: ( tabWidth - measureWidth() ) / 2, y: viewFrame(), width: measureWidth(), height: measureHeight())
        self.frame = frame
        if gifView != nil {
            gifView?.size = CGSize(width: measureWidth(), height: measureHeight())
        }
        if imageView != nil {
            imageView?.size = CGSize(width: measureWidth(), height: measureHeight())
        }
    }

    func viewFrame() -> CGFloat {

        var y : CGFloat = 0
        var titleHeight : CGFloat = 0
        if haveTitle {
            titleHeight = 15
        }
        if measureHeight() >= (tabHeight - titleHeight) {
            y = tabHeight - measureHeight() - titleHeight
        } else {
            y = ( tabHeight - titleHeight - measureHeight() ) / 2
        }
        return y
    }

}
