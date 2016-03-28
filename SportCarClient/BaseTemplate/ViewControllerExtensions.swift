//
//  ViewControllerExtensions.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/10.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Spring

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
//        if blurred {
//            let imageToBlur = CIImage(image: image)
//            let blurFilter = CIFilter(name: "CIGaussianBlur")
//            blurFilter?.setValue(imageToBlur, forKey: "inputImage")
//            let resultImage = blurFilter?.valueForKey("outputImage") as? CIImage
//            return UIImage(CIImage: resultImage!)
//        }
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
        let superview = UIApplication.sharedApplication().keyWindow!.rootViewController!.view
//        let superview = self.view
        let toastContainer = UIView()
        toastContainer.backgroundColor = UIColor(red: 0.067, green: 0.051, blue: 0.051, alpha: 1)
        toastContainer.layer.addDefaultShadow(6, opacity: 0.3, offset: CGSizeMake(0, 4))
        toastContainer.clipsToBounds = false
        superview.addSubview(toastContainer)
        superview.bringSubviewToFront(toastContainer)
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
        let superview = UIApplication.sharedApplication().keyWindow!.rootViewController!.view
        let toastContainer = UIView()
        toastContainer.backgroundColor = UIColor(red: 0.067, green: 0.051, blue: 0.051, alpha: 1)
        toastContainer.layer.addDefaultShadow(6, opacity: 0.3, offset: CGSizeMake(0, 4))
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
    
    /**
     Display a toast to ask for permisson
     
     - parameter message:   Message content to be displayed
     */
    func showConfirmToast(message: String, target: AnyObject, confirmSelector: Selector, cancelSelector: Selector) -> UIView {
        let container = UIView()
        let containerWidth = UIScreen.mainScreen().bounds.width * 0.5
        container.backgroundColor = UIColor(red: 0.067, green: 0.051, blue: 0.051, alpha: 1)
        container.layer.addDefaultShadow(6, opacity: 0.3, offset: CGSizeMake(0, 4))
        let staticLbl = UILabel()
        staticLbl.font = UIFont.systemFontOfSize(14)
        staticLbl.textColor = UIColor.whiteColor()
        staticLbl.text = message
        staticLbl.numberOfLines = 0
        container.addSubview(staticLbl)
        staticLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(container).offset(20)
            make.right.equalTo(container).offset(-20)
            make.top.equalTo(container).offset(15)
        }
        let lblHeight = staticLbl.sizeThatFits(CGSizeMake(containerWidth - 40, CGFloat.max)).height
        
        let confirmBtn = UIButton()
        confirmBtn.addTarget(target, action: confirmSelector, forControlEvents: .TouchUpInside)
        confirmBtn.setTitle(LS("确定"), forState: .Normal)
        confirmBtn.setTitleColor(kHighlightedRedTextColor, forState: .Normal)
        confirmBtn.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        container.addSubview(confirmBtn)
        confirmBtn.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(CGSizeMake(74, 43))
            make.bottom.equalTo(container)
            make.right.equalTo(container).offset(-10)
        }
        //
        let cancelBtn = UIButton()
        cancelBtn.addTarget(self, action: cancelSelector, forControlEvents: .TouchUpInside)
        cancelBtn.setTitle(LS("取消"), forState: .Normal)
        cancelBtn.setTitleColor(UIColor(white: 0.72, alpha: 1), forState: .Normal)
        cancelBtn.titleLabel?.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        container.addSubview(cancelBtn)
        cancelBtn.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(confirmBtn)
            make.size.equalTo(CGSizeMake(74, 43))
            make.right.equalTo(confirmBtn.snp_left)
        }
        
        let superview = UIApplication.sharedApplication().keyWindow!.rootViewController!.view
        superview.addSubview(container)
        container.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(containerWidth)
            make.height.equalTo(lblHeight + 44)
            make.top.equalTo(superview.snp_bottom)
            make.centerX.equalTo(superview)
        }
        
        superview.updateConstraints()
        superview.layoutIfNeeded()
        container.snp_remakeConstraints { (make) -> Void in
            make.width.equalTo(containerWidth)
            make.height.equalTo(lblHeight + 64)
            make.top.equalTo(superview).offset(150)
            make.centerX.equalTo(superview)
        }
        
        SpringAnimation.spring(0.5) { () -> Void in
            self.view.layoutIfNeeded()
        }
        
        return container
    }
    
    func hideConfirmToast(toast: UIView) {
        self.view.layoutIfNeeded()
        let superview = self.view
        toast.snp_updateConstraints { (make) -> Void in
            make.top.equalTo(superview).offset(-UIScreen.mainScreen().bounds.height - 30)
        }
        
        SpringAnimation.springWithCompletion(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }) { (_) -> Void in
                toast.removeFromSuperview()
        }
    }
    
}

extension CALayer {
    func addDefaultShadow(
        blur: CGFloat = 2,
        color: UIColor = UIColor.blackColor(),
        opacity: Float = 0.4,
        offset: CGSize = CGSizeMake(0, 3)
        ) {
        self.shadowRadius = blur
        self.shadowColor = color.CGColor
        self.shadowOpacity = opacity
        self.shadowOffset = offset
    }
}
