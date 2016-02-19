//
//  ImageInputSelector.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/13.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

protocol ImageInputSelectorDelegate {
    func imageInputSelectorDidSelectImage(image: UIImage)
    
    func imageInputSelectorDidCancel()
}


class ImageInputSelectorController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var delegate: ImageInputSelectorDelegate?
    
    var loadAnimated: Bool = true
    var bgImage: UIImage!
    
    var container: UIView!
    var cancelBtn: UIButton!
    var takePhotoBtn: UIButton!
    var albumBtn: UIButton!
    var bg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        createSubviews()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !loadAnimated {
            return
        }
        
        container.snp_remakeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func createSubviews() {
        let superview = self.view
        //
        let fakeBg = UIImageView()
        fakeBg.image = bgImage
        superview.addSubview(fakeBg)
        fakeBg.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        //
        container = UIView()
        container.clipsToBounds = true
        superview.addSubview(container)
        if loadAnimated {
            container.snp_makeConstraints(closure: { (make) -> Void in
                make.right.equalTo(superview)
                make.top.equalTo(superview.snp_bottom)
                make.left.equalTo(superview)
                make.height.equalTo(superview)
            })
        }else {
            container.snp_makeConstraints(closure: { (make) -> Void in
                make.edges.equalTo(superview)
            })
        }
        //
        bg = UIImageView()
        bg.image = self.blurImageUsingCoreImage(bgImage)
        container.addSubview(bg)
        bg.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        //
//        let blurEffect = UIBlurEffect(style: .Light)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        container.addSubview(blurEffectView)
//        blurEffectView.snp_makeConstraints { (make) -> Void in
//            make.edges.equalTo(container)
//        }
        //
//        let bgCover = UIView()
//        bgCover.backgroundColor = UIColor(white: 0, alpha: 0.7)
//        bg.addSubview(bgCover)
//        bgCover.snp_makeConstraints { (make) -> Void in
//            make.edges.equalTo(bg)
//        }
        //
        cancelBtn = UIButton()
        cancelBtn.setImage(UIImage(named: "news_comment_cancel_btn"), forState: .Normal)
        cancelBtn.addTarget(self, action: "cancelBtnPressed", forControlEvents: .TouchUpInside)
        container.addSubview(cancelBtn)
        cancelBtn.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(container)
            make.top.equalTo(container).offset(90)
            make.size.equalTo(21)
        }
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor.whiteColor()
        container.addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(cancelBtn)
            make.top.equalTo(cancelBtn.snp_bottom).offset(49)
            make.height.equalTo(0.5)
            make.width.equalTo(220)
        }
        //
        takePhotoBtn = UIButton()
        takePhotoBtn.setTitle(LS("拍照"), forState: .Normal)
        takePhotoBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        takePhotoBtn.titleLabel?.font = UIFont.systemFontOfSize(17, weight: UIFontWeightUltraLight)
        container.addSubview(takePhotoBtn)
        takePhotoBtn.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(44)
            make.centerX.equalTo(container)
            make.centerY.equalTo(sepLine.snp_bottom).offset(56)
        }
        takePhotoBtn.addTarget(self, action: "takePhotoBtnPressed", forControlEvents: .TouchUpInside)
        //
        albumBtn = UIButton()
        albumBtn.setTitle(LS("相册"), forState: .Normal)
        albumBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        albumBtn.titleLabel?.font = UIFont.systemFontOfSize(17, weight: UIFontWeightUltraLight)
        container.addSubview(albumBtn)
        albumBtn.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(44)
            make.centerX.equalTo(container)
            make.centerY.equalTo(takePhotoBtn).offset(56)
        }
        albumBtn.addTarget(self, action: "albumBtnPressed", forControlEvents: .TouchUpInside)
    }
    
    func cancelBtnPressed() {
        let superview = self.view
        container.snp_remakeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.top.equalTo(superview.snp_bottom)
            make.left.equalTo(superview)
            make.height.equalTo(superview)
        }
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: { (finished) in
                self.delegate?.imageInputSelectorDidCancel()
        })
    }
    
    func takePhotoBtnPressed() {
        let sourceType = UIImagePickerControllerSourceType.Camera
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            self.displayAlertController(LS("错误"), message: LS("无法打开相机"))
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func albumBtnPressed() {
        let sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            self.displayAlertController(LS("错误"), message: LS("无法打开相册"))
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        delegate?.imageInputSelectorDidSelectImage(image)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
