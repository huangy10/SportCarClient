//
//  chatAccessoryBoard.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/31.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

/// ChatAccessoryBoard的默认高宽比
let kChatAccessoryBoardSizeRatio: CGFloat = 500.0 / 750.0


class ChatAccessoryBoard: UIView {
    
    var takePhotoBtn: UIButton?
    var photoAlbumBtn: UIButton?
    
    var chatRoomController: ChatRoomController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
    func createSubViews() {
        let superview = self
        superview.backgroundColor = UIColor.white
        //
        takePhotoBtn = UIButton()
        takePhotoBtn?.setImage(UIImage(named: "chat_accessory_take_photo"), for: .normal)
        takePhotoBtn?.addTarget(self, action: #selector(ChatAccessoryBoard.takePhotoBtnPressed), for: .touchUpInside)
        superview.addSubview(takePhotoBtn!)
        takePhotoBtn?.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(superview).offset(15)
            make.top.equalTo(superview).offset(25)
            make.size.equalTo(69)
        })
        let takePhotoLbl = UILabel()
        takePhotoLbl.text = LS("拍照")
        takePhotoLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
        takePhotoLbl.textColor = kTextGray28
        takePhotoLbl.textAlignment = .center
        superview.addSubview(takePhotoLbl)
        takePhotoLbl.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(takePhotoBtn!)
            make.top.equalTo(takePhotoBtn!.snp.bottom).offset(10)
        }
        //
        photoAlbumBtn = UIButton()
        photoAlbumBtn?.setImage(UIImage(named: "chat_accessory_photos"), for: .normal)
        photoAlbumBtn?.addTarget(self, action: #selector(ChatAccessoryBoard.photoAlbumBtnPressed), for: .touchUpInside)
        superview.addSubview(photoAlbumBtn!)
        photoAlbumBtn?.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(takePhotoBtn!)
            make.left.equalTo(takePhotoBtn!.snp.right).offset(23)
            make.size.equalTo(69)
        })
        let photoAlbumLbl = UILabel()
        photoAlbumLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
        photoAlbumLbl.textColor = kTextGray28
        photoAlbumLbl.textAlignment = .center
        photoAlbumLbl.text = LS("照片")
        superview.addSubview(photoAlbumLbl)
        photoAlbumLbl.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(photoAlbumBtn!.snp.bottom).offset(10)
            make.centerX.equalTo(photoAlbumBtn!)
        }
    }
    
    func takePhotoBtnPressed() {
        // 拍摄照片
        let sourceType = UIImagePickerControllerSourceType.camera
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            chatRoomController?.showToast(LS("无法打开相机"))
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = chatRoomController
        imagePicker.allowsEditing = false
        chatRoomController?.present(imagePicker, animated: true, completion: nil)
    }
    
    func photoAlbumBtnPressed() {
        // 从已有的相册中选择
        let sourceType = UIImagePickerControllerSourceType.photoLibrary
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            chatRoomController?.showToast(LS("无法打开相册"))
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = chatRoomController
        imagePicker.allowsEditing = false
        chatRoomController?.present(imagePicker, animated: true, completion: nil)
    }
    
}


