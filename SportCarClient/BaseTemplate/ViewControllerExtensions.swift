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
        if onConfirm == nil {
            self.showToast(title ?? message!)
            return
        }
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
    
    /**
     弹出一个一段时间之后自动消失的对话框
     
     - parameter message:       显示的文字内容
     - parameter maxLastLength: 最大显示的时长
     */
    func showToast(message: String, maxLastLength: Double=3) {
//        let rootViewController = UIApplication.sharedApplication().keyWindow!.rootViewController!
        let superview = self.view
        let toastContainer = UIView()
        toastContainer.backgroundColor = UIColor(red: 0.067, green: 0.051, blue: 0.051, alpha: 1)
        toastContainer.layer.shadowColor = UIColor(white: 0, alpha: 0.4).CGColor
        toastContainer.layer.shadowOffset = CGSizeMake(0, 4.5)
        toastContainer.layer.shadowRadius = 6
        toastContainer.clipsToBounds = false
        superview.addSubview(toastContainer)
        toastContainer.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.top.equalTo(superview).offset(40)
            make.size.equalTo(CGSizeMake(200, 45))
        }
        let lbl = UILabel()
        lbl.font = UIFont.systemFontOfSize(14)
        lbl.textColor = UIColor.whiteColor()
        lbl.textAlignment = .Center
        toastContainer.addSubview(lbl)
        lbl.text = message
        lbl.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(toastContainer)
        }
        //
        toastContainer.layer.opacity = 0
        UIView.animateWithDuration(0.5) { () -> Void in
            toastContainer.layer.opacity = 1
        }
        UIView.animateWithDuration(0.5, delay: maxLastLength, options: [], animations: { () -> Void in
            toastContainer.layer.opacity = 0
            }) { (_) -> Void in
                toastContainer.removeFromSuperview()
        }
    }
    
    func showStaticToast(message: String) -> UIView {
        let superview = self.view
        let toastContainer = UIView()
        toastContainer.backgroundColor = UIColor(red: 0.067, green: 0.051, blue: 0.051, alpha: 1)
        toastContainer.layer.shadowColor = UIColor(white: 0, alpha: 0.4).CGColor
        toastContainer.layer.shadowOffset = CGSizeMake(0, 4.5)
        toastContainer.layer.shadowRadius = 6
        toastContainer.clipsToBounds = false
        superview.addSubview(toastContainer)
        toastContainer.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.top.equalTo(superview).offset(40)
            make.size.equalTo(CGSizeMake(200, 45))
        }
        let lbl = UILabel()
        lbl.font = UIFont.systemFontOfSize(14)
        lbl.textColor = UIColor.whiteColor()
        lbl.textAlignment = .Center
        toastContainer.addSubview(lbl)
        lbl.text = message
        lbl.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(toastContainer)
        }
        //
        toastContainer.layer.opacity = 0
        UIView.animateWithDuration(0.5) { () -> Void in
            toastContainer.layer.opacity = 1
        }
        return toastContainer
    }
    
    func hideToast(toast: UIView) {
        UIView.animateWithDuration(0.5, delay: 0, options: [], animations: { () -> Void in
            toast.layer.opacity = 0
            }) { (_) -> Void in
                toast.removeFromSuperview()
        }
    }
}
