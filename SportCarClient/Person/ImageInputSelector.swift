//
//  ImageInputSelector.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/13.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

@available(*, deprecated: 1)
protocol ImageInputSelectorDelegate: class {
    func imageInputSelectorDidSelectImage(_ image: UIImage)
    
    func imageInputSelectorDidCancel()
}


@available(*, deprecated: 1)
class ImageInputSelectorController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    weak var delegate: ImageInputSelectorDelegate?
    
    var loadAnimated: Bool = true
    var bgImage: UIImage!
    
    var container: UIView!
    var cancelBtn: UIButton!
    var takePhotoBtn: UIButton!
    var albumBtn: UIButton!
    
    var bg: UIImageView!
    var bgBlurred: UIImageView!
    var bgMask: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        createSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !loadAnimated {
            return
        }
        showAnimated()
    }
    
    func createSubviews() {
        let superview = self.view!
        //
        bg = UIImageView()
        bg.image = bgImage
        superview.addSubview(bg)
        bg.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        
        bgBlurred = UIImageView()
        bgBlurred.image = blurImageUsingCoreImage(bgImage)
        superview.addSubview(bgBlurred)
        bgBlurred.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(bg)
        }
        bgBlurred.layer.opacity = 0
        
        bgMask = UIView()
        bgMask.backgroundColor = UIColor(white: 1, alpha: 0.7)
        superview.addSubview(bgMask)
        bgMask.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(bg)
        }
        bgMask.layer.opacity = 0
        
        container = UIView()
        container.backgroundColor = UIColor.clear
        container.clipsToBounds = true
        superview.addSubview(container)
        container.snp_makeConstraints({ (make) -> Void in
            make.edges.equalTo(superview)
        })
        container.layer.opacity = 0
        
        cancelBtn = UIButton()
        cancelBtn.setImage(UIImage(named: "news_comment_cancel_btn"), for: UIControlState())
        cancelBtn.addTarget(self, action: #selector(ImageInputSelectorController.cancelBtnPressed), for: .touchUpInside)
        container.addSubview(cancelBtn)
        cancelBtn.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(container)
            make.top.equalTo(container).offset(90)
            make.size.equalTo(21)
        }
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor.white
        container.addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(cancelBtn)
            make.top.equalTo(cancelBtn.snp_bottom).offset(49)
            make.height.equalTo(0.5)
            make.width.equalTo(220)
        }
        //
        takePhotoBtn = UIButton()
        takePhotoBtn.setTitle(LS("拍照"), for: UIControlState())
        takePhotoBtn.setTitleColor(UIColor.white, for: UIControlState())
        takePhotoBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightUltraLight)
        container.addSubview(takePhotoBtn)
        takePhotoBtn.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(44)
            make.centerX.equalTo(container)
            make.centerY.equalTo(sepLine.snp_bottom).offset(56)
        }
        takePhotoBtn.addTarget(self, action: #selector(ImageInputSelectorController.takePhotoBtnPressed), for: .touchUpInside)
        //
        albumBtn = UIButton()
        albumBtn.setTitle(LS("相册"), for: UIControlState())
        albumBtn.setTitleColor(UIColor.white, for: UIControlState())
        albumBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightUltraLight)
        container.addSubview(albumBtn)
        albumBtn.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(44)
            make.centerX.equalTo(container)
            make.centerY.equalTo(takePhotoBtn).offset(56)
        }
        albumBtn.addTarget(self, action: #selector(ImageInputSelectorController.albumBtnPressed), for: .touchUpInside)
    }
    
    func cancelBtnPressed() {
//        delegate?.imageInputSelectorDidCancel()
        hideAnimated()
    }
    
    func takePhotoBtnPressed() {
        let sourceType = UIImagePickerControllerSourceType.camera
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            showToast(LS("无法打开相机"))
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func albumBtnPressed() {
        let sourceType = UIImagePickerControllerSourceType.photoLibrary
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            showToast(LS("无法打开相册"))
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismiss(animated: true, completion: {
            self.hideAnimated()
            self.delegate?.imageInputSelectorDidSelectImage(image)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAnimated() {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.bg.layer.opacity = 0
            self.bgBlurred.layer.opacity = 1
//            self.bgMask.layer.opacity = 1
            self.container.layer.opacity = 1
        }) 
    }
    
    func hideAnimated() {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.bg.layer.opacity = 1
            self.bgBlurred.layer.opacity = 0
            self.bgMask.layer.opacity = 0
            self.container.layer.opacity = 0
            }, completion: { (_) -> Void in
                self.presentingViewController?.dismiss(animated: false, completion: nil)
        }) 
    }
}
