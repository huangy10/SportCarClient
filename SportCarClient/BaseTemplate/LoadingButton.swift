//
//  LoadingButton.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/15.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher


/// 这个按钮的图像是需要从后端现在的
class LoadingButton: UIButton {
    /// loading标识
    var indicator: UIActivityIndicatorView
    
    /**
     采用这个初始化方法会将按钮自动设置成圆角
     
     - parameter size: 按钮大小
     
     - returns: -
     */
    convenience init(size: CGSize) {
        self.init(frame: CGRect.zero)
        self.layer.cornerRadius = min(size.width, size.height)
    }
    
    override init(frame: CGRect) {
        indicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        super.init(frame: frame)
        
        indicator.hidesWhenStopped = true
        self.addSubview(indicator)
        indicator.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LoadingButton {
    
    /**
     - parameter url:              图片的URL
     - parameter placeholderImage: Placeholder
     */
    func loadImageFromURL(url: NSURL, placeholderImage: UIImage?){
        indicator.startAnimating()
        self.imageView?.kf_setImageWithURL(url, placeholderImage: placeholderImage, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
            self.indicator.stopAnimating()
        })
    }
}
