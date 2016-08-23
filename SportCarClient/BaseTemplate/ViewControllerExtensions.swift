//
//  ViewControllerExtensions.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/10.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Spring
import Spring

extension UIViewController {
    
    /**
     展示一个包含确定按钮的的Alert
     
     - parameter title:   标题
     - parameter message: 消息内容
     */
    @available(*, deprecated=1)
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
    func showToast(message: String, maxLastLength: Double=2, onSelf: Bool = false) {
        assert(NSThread.isMainThread())
        let superview = onSelf ? self.view : UIApplication.sharedApplication().keyWindow!.rootViewController!.view
//        let superview = self.view
        
        let messageHeight: CGFloat = (message as NSString).boundingRectWithSize(CGSizeMake(170, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14)], context: nil).height
        
        let toastContainer = UIView()
        toastContainer.backgroundColor = UIColor(red: 0.067, green: 0.051, blue: 0.051, alpha: 1)
        toastContainer.layer.addDefaultShadow(6, opacity: 0.3, offset: CGSizeMake(0, 4))
        toastContainer.clipsToBounds = false
        superview.addSubview(toastContainer)
        superview.bringSubviewToFront(toastContainer)
        toastContainer.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.bottom.equalTo(superview.snp_top)
            make.size.equalTo(CGSizeMake(200, messageHeight + 30))
        }
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .ByCharWrapping
        lbl.font = UIFont.systemFontOfSize(14)
        lbl.textColor = UIColor.whiteColor()
        lbl.textAlignment = .Center
        toastContainer.addSubview(lbl)
        lbl.text = message
        lbl.snp_makeConstraints { (make) -> Void in
//            make.edges.equalTo(toastContainer)
            make.center.equalTo(toastContainer)
            make.size.equalTo(CGSizeMake(170, messageHeight))
        }
        //
        superview.layoutIfNeeded()
        toastContainer.snp_remakeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.top.equalTo(superview).offset(40 + 44)
            make.size.equalTo(CGSizeMake(200, messageHeight + 30))
        }
        SpringAnimation.spring(0.3) { 
            superview.layoutIfNeeded()
        }
        UIView.animateWithDuration(0.3, delay: maxLastLength, options: [], animations: { () -> Void in
            toastContainer.snp_remakeConstraints { (make) -> Void in
                make.centerX.equalTo(superview)
                make.bottom.equalTo(superview.snp_top)
                make.size.equalTo(CGSizeMake(200, messageHeight + 30))
            }
            superview.layoutIfNeeded()
            }) { (_) -> Void in
                toastContainer.removeFromSuperview()
        }
    }
    
    func showConfirmToast(title: String, message: String, target: AnyObject!, onConfirm: Selector) {
        ConfirmToastPresentationController(title: title, des: message, target: target, confirmSelector: onConfirm).presentFromRootController()
    }
    
    @available(*, deprecated=1)
    func showConfirmToast(title: String, message: String, target: AnyObject, confirmSelector: Selector, cancelSelector: Selector, onSelf: Bool = true) -> UIView {
        let superview = onSelf ? self.navigationController?.view ?? self.view : UIApplication.sharedApplication().keyWindow!.rootViewController!.view
        let container = superview.addSubview(UIView).config(UIColor.clearColor())
            .layout { (make) in
                make.edges.equalTo(superview)
        }
        let bgView = container.addSubview(UIView).config(UIColor(white: 0, alpha: 0.2))
            .layout { (make) in
                make.edges.equalTo(superview)
        }
        bgView.layer.opacity = 0
        
        let toast = container.addSubview(UIView).config(UIColor.whiteColor()).toRound(4).layout { (make) in
            make.centerX.equalTo(superview)
            make.top.equalTo(superview.snp_bottom).offset(30)
            make.width.equalTo(250)
            make.height.equalTo(150)
        }.addShadow()
        let titleLbl = toast.addSubview(UILabel)
            .config(17, fontWeight: UIFontWeightSemibold, text: title)
            .layout { (make) in
                make.left.equalTo(toast).offset(15)
                make.top.equalTo(toast).offset(20)
        }
        let messageLbl = toast.addSubview(UILabel)
            .config(12, textColor: UIColor(white: 0.72, alpha: 1), text: message, multiLine: true)
            .layout { (make) in
                make.left.equalTo(titleLbl)
                make.right.equalTo(toast).offset(-15)
                make.top.equalTo(titleLbl.snp_bottom).offset(10)
        }
        let confirmBtn = toast.addSubview(UIButton)
            .config(target, selector: confirmSelector, title: LS("确定"), titleColor: kHighlightedRedTextColor)
            .layout { (make) in
                make.size.equalTo(CGSizeMake(74, 43))
                make.right.equalTo(toast)
                make.top.equalTo(messageLbl.snp_bottom).offset(15)
        }
        toast.addSubview(UIButton)
            .config(target, selector: cancelSelector, title: LS("取消"), titleColor: UIColor(white: 0.72, alpha: 1))
            .layout { (make) in
                make.centerY.equalTo(confirmBtn)
                make.size.equalTo(CGSizeMake(74, 43))
                make.right.equalTo(confirmBtn.snp_left)
        }
        var contentRect = CGRectZero
        toast.layoutIfNeeded()
        for view in toast.subviews {
            contentRect = CGRectUnion(contentRect, view.frame)
        }
        let size = CGSizeMake(
            contentRect.width - contentRect.origin.x,
            contentRect.height - contentRect.origin.y)
        toast.snp_updateConstraints { (make) in
            make.height.equalTo(size.height)
        }
        container.layoutIfNeeded()
        toast.snp_remakeConstraints { (make) in
            make.centerX.equalTo(superview)
            make.top.equalTo(superview).offset(100)
            make.width.equalTo(250)
            make.height.equalTo(size.height)
        }
        SpringAnimation.spring(0.5) {
            container.layoutIfNeeded()
            bgView.layer.opacity = 1
        }
        container.tag = 1
        return container
    }
    
    func showStaticToast(message: String) -> UIView {
//        let superview = UIApplication.sharedApplication().keyWindow!.rootViewController!.view
        let superview = self.view
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
        if toast.tag == 0 {
            UIView.animateWithDuration(0.5, delay: 0, options: [], animations: { () -> Void in
                toast.layer.opacity = 0
                }) { (_) -> Void in
                    toast.removeFromSuperview()
            }
        } else {
            let bg = toast.subviews[0]
            let t = toast.subviews[1]
            t.snp_remakeConstraints(closure: { (make) in
                make.centerX.equalTo(toast.superview!)
                make.top.equalTo(toast.superview!.snp_bottom).offset(30)
                make.width.equalTo(250)
                make.height.equalTo(150)
            })
            UIView.animateWithDuration(0.3, animations: {
                bg.layer.opacity = 0
                toast.superview?.layoutIfNeeded()
                }, completion: { (_) in
                    toast.removeFromSuperview()
            })
        }
    }
    func hideConfirmToast(toast: UIView) {
        hideToast(toast)
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


class ConfirmToastPresentationController: UIViewController {
    
    var confirmTitle: String!
    var confirmDes: String! {
        didSet {
            calculateDesLblHeight()
        }
    }
    var bg: UIView!
    var dialog: UIView!
    var titleLbl: UILabel!
    var desLbl: UILabel!
    var confirmBtn: UIButton!
    var confirmBtnLbl: UILabel!
    var cancelBtn: UIButton!
    var canceLBtnLbl: UILabel!
    var blurMask: UIVisualEffectView!
    
    var target: AnyObject!
    var confirmSelector: Selector!
    
    
    private var desLblHeight: CGFloat = 0
    private let desLineSpacing: CGFloat = 5
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBlurredBackground()
        configureDialog()
        configureTitleLbl()
        configureDesLbl()
        configureConfirmBtn()
        configureCancelBtn()
        
        animateEntry()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(cancelBtnPressed), name: kAccontNolongerLogin, object: nil)
    }
    
    init(title: String, des: String, target: AnyObject, confirmSelector: Selector) {
        self.confirmTitle = title
        self.confirmDes = des
        self.target = target
        self.confirmSelector = confirmSelector
        
        super.init(nibName: nil, bundle: nil)
        
        calculateDesLblHeight()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func presentFromRootController() {
        let controller = UIApplication.sharedApplication().keyWindow!.rootViewController!
        willMoveToParentViewController(controller)
        controller.view.addSubview(view)
        controller.addChildViewController(self)
        didMoveToParentViewController(controller)
    }
    
    func dismissFromRootController() {
        willMoveToParentViewController(nil)
        view.removeFromSuperview()
        removeFromParentViewController()
    }
    
    func animateEntry() {
        view.layoutIfNeeded()
        let height = desLblHeight + 160 - 44
        dialog.snp_remakeConstraints { (make) in
            make.centerX.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.667)
            make.height.equalTo(height)
            make.bottom.equalTo(view.snp_centerY)
        }
//        UIView.animateWithDuration(0.3, animations: {
//            self.view.layoutIfNeeded()
//            self.blurMask.layer.opacity = 0.5
//            }, completion: nil)
//        
        SpringAnimation.spring(0.5) {
            self.view.layoutIfNeeded()
        }
        
        UIView.animateWithDuration(0.5) {
            self.bg.layer.opacity = 1
        }
    }
    
    func animateHide(complete: ()->()) {
        let height = desLblHeight + 160 - 44
        dialog.snp_remakeConstraints { (make) in
            make.centerX.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.667)
            make.height.equalTo(height)
            make.top.equalTo(view.snp_bottom).offset(10)
        }
        
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
            self.bg.layer.opacity = 0
            }, completion: { _ in
                complete()
        })
    }
    
    
    func configureBlurredBackground() {
        view.backgroundColor = UIColor.clearColor()
        bg = view.addSubview(UIView).config(UIColor.clearColor())
            .layout({ (make) in
                make.edges.equalTo(view)
            })
        let blurEffect = UIBlurEffect(style: .Dark)
        blurMask = UIVisualEffectView(effect: blurEffect)
        bg.addSubview(blurMask)
        blurMask.snp_makeConstraints { (make) in
            make.edges.equalTo(bg)
        }
        
        bg.addSubview(UIView).config(UIColor(white: 0, alpha: 0.3))
        bg.layer.opacity = 0
    }
    
    func calculateDesLblHeight() {
        if confirmDes.length == 0 {
            desLblHeight = 0
        } else {
            let screenWidth = UIScreen.mainScreen().bounds.width
            let dialogWidth = screenWidth * 0.667
            let detailLblMaxWidth = dialogWidth - 40
            let style = NSMutableParagraphStyle()
            style.lineSpacing = desLineSpacing
            desLblHeight = (confirmDes as NSString).boundingRectWithSize(CGSizeMake(detailLblMaxWidth, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSParagraphStyleAttributeName: style], context: nil).height
        }
    }
    
    func configureDialog() {
        let height = desLblHeight + 160 - 44
        dialog = view.addSubview(UIView)
            .config(UIColor.whiteColor())
            .toRound(2)
            .addShadow()
            .layout({ (make) in
                make.centerX.equalTo(view)
                make.width.equalTo(view).multipliedBy(0.667)
                make.height.equalTo(height)
//                make.bottom.equalTo(view.snp_centerY)
                make.top.equalTo(view.snp_bottom).offset(10)
            })
    }
    
    func configureTitleLbl() {
        titleLbl = dialog.addSubview(UILabel)
            .config(17, fontWeight: UIFontWeightSemibold, textColor: UIColor.blackColor(), text: confirmTitle)
            .layout({ (make) in
                make.left.equalTo(dialog).offset(20)
                make.top.equalTo(20)
                make.right.equalTo(dialog).offset(-20)
            })
    }
    
    func configureDesLbl() {
        desLbl = dialog.addSubview(UILabel)
            .layout({ (make) in
                make.left.equalTo(titleLbl)
                make.right.equalTo(titleLbl)
                make.top.equalTo(titleLbl.snp_bottom).offset(10)
            })
        desLbl.numberOfLines = 0
        desLbl.lineBreakMode = .ByCharWrapping
        let style = NSMutableParagraphStyle()
        style.lineSpacing = desLineSpacing
        let str = NSAttributedString(string: confirmDes, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSParagraphStyleAttributeName: style, NSForegroundColorAttributeName: UIColor(white: 0, alpha: 0.72)])
        desLbl.attributedText = str
    }
    
    func configureConfirmBtn() {
        confirmBtnLbl = dialog.addSubview(UILabel)
            .config(14, fontWeight: UIFontWeightUltraLight, textColor: kHighlightRed, textAlignment: .Center, text: LS("确定"))
            .layout({ (make) in
                make.right.equalTo(dialog).offset(-25)
                make.bottom.equalTo(dialog).offset(-16)
            })
        confirmBtn = dialog.addSubview(UIButton)
            .config(self, selector: #selector(confirmBtnPressed))
            .layout({ (make) in
                make.center.equalTo(confirmBtnLbl)
                make.size.equalTo(30)
            })
    }
    
    func configureCancelBtn() {
        canceLBtnLbl = dialog.addSubview(UILabel)
            .config(12, fontWeight: UIFontWeightUltraLight, textColor: UIColor(white: 0.72, alpha: 1), textAlignment: .Center, text: LS("取消"))
            .layout({ (make) in
                make.centerY.equalTo(confirmBtnLbl)
                make.right.equalTo(confirmBtnLbl.snp_left).offset(-35)
            })
        cancelBtn = dialog.addSubview(UIButton)
            .config(self, selector: #selector(cancelBtnPressed))
            .layout({ (make) in
                make.center.equalTo(canceLBtnLbl)
                make.size.equalTo(30)
            })
    }
    
    func confirmBtnPressed() {
        cancelBtnPressed()
        (target as! NSObject).performSelector(confirmSelector)
    }
    
    func cancelBtnPressed() {
        animateHide { 
            self.dismissFromRootController()
        }
    }
}
