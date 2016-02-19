//
//  ViewControllerExtensions.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/10.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /**
     展示一个包含确定按钮的的Alert
     
     - parameter title:   标题
     - parameter message: 消息内容
     */
    func displayAlertController(title: String?, message: String?, onConfirm: (()->())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "确定", style: .Default, handler: { (action) -> Void in
            if onConfirm != nil {
                onConfirm!()
            }
        })
        alert.addAction(defaultAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    /**
     获取当前controller的截图
     
     - parameter blurred: 是否进行模糊
     */
    func getScreenShotBlurred(blurred: Bool) -> UIImage {
        let window = UIApplication.sharedApplication().keyWindow!
        UIGraphicsBeginImageContextWithOptions(window.frame.size, window.opaque, UIScreen.mainScreen().scale)
        window.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if blurred {
            let imageToBlur = CIImage(image: image)
            let blurFilter = CIFilter(name: "CIGaussianBlur")
            blurFilter?.setValue(imageToBlur, forKey: "inputImage")
            let resultImage = blurFilter?.valueForKey("outputImage") as? CIImage
            return UIImage(CIImage: resultImage!)
        }
        return image
    }
    
    func blurImageUsingCoreImage(inputImage: UIImage) -> UIImage {
        return inputImage.applyBlurWithRadius(5, tintColor: UIColor(white: 0, alpha: 0.7), saturationDeltaFactor: 1.8)!
    }
}
