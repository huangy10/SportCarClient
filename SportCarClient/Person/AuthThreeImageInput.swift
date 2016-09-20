//
//  AuthThreeImageInput.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/12.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

/// 三张输入图片的认证窗口
class AuthThreeImagesController: AuthBasicController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var staticLabel1: UILabel!
    var staticLabel2: UILabel!
    var staticLabel3: UILabel!
    
    var imageBtn1: UIButton!
    var imageBtn2: UIButton!
    var imageBtn3: UIButton!
    
//    var quitBtn: UIButton!
    
    var activeBtn: UIButton?
    var selectedImages: [UIImage?] = [nil, nil, nil]
    
    override func createImagesImputPanel() -> UIView {
        let container = UIView()
        //
        let defaultCover = UIImage(named: "auth_image_Input_btn")
        let btnSize = CGSize(width: 187.5, height: 108.5)
        //
        staticLabel1 = getStaticLabel()
        staticLabel1.text = getStaticLabelContentForIndex(0)
        container.addSubview(staticLabel1)
        staticLabel1.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(container)
            make.top.equalTo(container)
        }
        //
        imageBtn1 = UIButton()
        imageBtn1.tag = 0
        imageBtn1.imageView?.contentMode = .scaleAspectFill
        imageBtn1.setImage(defaultCover, for: UIControlState())
        container.addSubview(imageBtn1)
        imageBtn1.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(container)
            make.top.equalTo(container)
            make.size.equalTo(btnSize)
        }
        imageBtn1.addTarget(self, action: #selector(AuthThreeImagesController.imageInputBtnPressed(_:)), for: .touchUpInside)
        //
        staticLabel2 = getStaticLabel()
        staticLabel2.text = getStaticLabelContentForIndex(1)
        container.addSubview(staticLabel2)
        staticLabel2.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(container)
            make.top.equalTo(staticLabel1.snp_bottom).offset(110)
        }
        //
        imageBtn2 = UIButton()
        imageBtn2.tag = 1
        imageBtn2.setImage(defaultCover, for: UIControlState())
        imageBtn2.imageView?.contentMode = .scaleAspectFill
        container.addSubview(imageBtn2)
        imageBtn2.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(container)
            make.top.equalTo(staticLabel2)
            make.size.equalTo(btnSize)
        }
        imageBtn2.addTarget(self, action: #selector(AuthThreeImagesController.imageInputBtnPressed(_:)), for: .touchUpInside)
        //
        staticLabel3 = getStaticLabel()
        staticLabel3.text = getStaticLabelContentForIndex(2)
        container.addSubview(staticLabel3)
        staticLabel3.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(container)
            make.top.equalTo(staticLabel2.snp_bottom).offset(110)
        }
        //
        imageBtn3 = UIButton()
        imageBtn3.tag = 2
        imageBtn3.setImage(defaultCover, for: UIControlState())
        imageBtn3.imageView?.contentMode = .scaleAspectFill
        container.addSubview(imageBtn3)
        imageBtn3.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(container)
            make.top.equalTo(staticLabel3)
            make.size.equalTo(btnSize)
        }
        imageBtn3.addTarget(self, action: #selector(AuthThreeImagesController.imageInputBtnPressed(_:)), for: .touchUpInside)
        //
//        quitBtn = UIButton()
//        quitBtn.setImage(UIImage(named: "auth_not_now_btn"), forState: .Normal)
//        container.addSubview(quitBtn)
//        quitBtn.snp_makeConstraints { (make) -> Void in
//            make.centerX.equalTo(container)
//            make.top.equalTo(imageBtn3.snp_bottom).offset(35)
//            make.size.equalTo(CGSizeMake(150, 50))
//        }
        return container
    }
    
    func getStaticLabel() -> UILabel{
        let lbl = UILabel()
        lbl.textColor = UIColor(white: 0.72, alpha: 1)
        lbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        return lbl
    }
    
    func getStaticLabelContentForIndex(_ index: Int) -> String{
        assertionFailure()
        return ""
    }
    
    override func getHeightForImageInputPanel() -> CGFloat {
        return 600
    }
    
    func imageInputBtnPressed(_ sender: UIButton) {
        activeBtn = sender
        let alert = UIAlertController(title: NSLocalizedString("选择图片", comment: ""), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("拍照", comment: ""), style: .default, handler: { (action) -> Void in
            let sourceType = UIImagePickerControllerSourceType.camera
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                let alert = UIAlertController(title: "错误", message: "无法打开相机", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("从相册中选择", comment: ""), style: .default, handler: { (action) -> Void in
            let sourceType = UIImagePickerControllerSourceType.photoLibrary
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                let alert = UIAlertController(title: "错误", message: "无法打开相册", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        if activeBtn == nil {
            assertionFailure()
        }
        self.dismiss(animated: true, completion: nil)
        activeBtn?.setImage(image, for: UIControlState())
        selectedImages[activeBtn!.tag] = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
