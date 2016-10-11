//
//  GroupChatSetUp.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/26.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire


protocol GroupChatSetupDelegate: class {
    func groupChatSetupControllerDidSuccessCreatingClub(_ newClub: Club)
}


class GroupChatSetupController: InputableViewController, ProgressProtocol, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var delegate: GroupChatSetupDelegate?
    
    var users: [User] = []
    
    var logoImage: UIImage?
    var name: String?
    
    var logo: UIButton!
    var nameInput: UITextField!
    
    var requesting = false
    
    override func createSubviews() {
        navSettings()
        super.createSubviews()
        let superview = self.view!
        superview.backgroundColor = UIColor.white
        //
        let logoLbl = UILabel()
        logoLbl.text = LS("请选择一个标识")
        logoLbl.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightSemibold)
        logoLbl.textColor = UIColor.black
        logoLbl.textAlignment = .center
        superview.addSubview(logoLbl)
        logoLbl.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.top.equalTo(superview).offset(25)
        }
        //
        logo = UIButton()
        logo.layer.cornerRadius = 45
        logo.clipsToBounds = true
        logo.setImage(UIImage(named: "account_profile_avatar_btn"), for: .normal)
        superview.addSubview(logo)
        logo.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.top.equalTo(logoLbl.snp.bottom).offset(20)
            make.size.equalTo(90)
        }
        logo.addTarget(self, action: #selector(GroupChatSetupController.logoBtnPressed), for: .touchUpInside)
        //
        nameInput = UITextField()
        nameInput.delegate = self
        inputFields.append(nameInput)
        nameInput.textColor = UIColor.black
        nameInput.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        nameInput.textAlignment = .center
        nameInput.placeholder = LS("请输入群聊名称")
        superview.addSubview(nameInput)
        nameInput.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.top.equalTo(logo.snp.bottom).offset(30)
            make.size.equalTo(CGSize(width: 250, height: 27.5))
        }
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.945, alpha: 1)
        superview.addSubview(sepLine)
        sepLine.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(nameInput.snp.bottom).offset(3)
            make.width.equalTo(273)
            make.height.equalTo(0.5)
            make.centerX.equalTo(superview)
        }
    }
    
    func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = LS("聊天信息") + "(\(users.count))"
        //
        let navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), for: .normal)
        navLeftBtn.frame = CGRect(x: 0, y: 0, width: 9, height: 15)
        navLeftBtn.addTarget(self, action: #selector(GroupChatSetupController.navLeftBtnPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        //
        let rightItem = UIBarButtonItem(title: LS("确定"), style: .done, target: self, action: #selector(GroupChatSetupController.navRightBtnPressed))
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular), NSForegroundColorAttributeName: kHighlightedRedTextColor], for: .normal)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func navLeftBtnPressed() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func navRightBtnPressed() {
        if requesting { return }
        nameInput.resignFirstResponder()
        // Check the data
        guard let clubName = nameInput.text , clubName.length > 0 else {
            showToast(LS("请填写俱乐部名称"))
            return
        }
        if logoImage == nil {
            showToast(LS("请为俱乐部选择一个标志"))
            return
        }
        let userIDs = users.map { $0.ssidString }
        // send creation request
        self.pp_showProgressView()
        requesting = true
        ClubRequester.sharedInstance.createNewClub(clubName, clubLogo: logoImage!, members: userIDs, description: "Description", onSuccess: { (json) in
            var club: Club! = nil
            let waiter: DispatchSemaphore = DispatchSemaphore(value: 0)
            ChatModelManger.sharedManager.workQueue.async(execute: {
                club = try! ChatModelManger.sharedManager.getOrCreate(json!) as Club
                let rosterItem = RosterManager.defaultManager.getOrCreateNewRoster(json!["roster"], autoBringToFront: true)
                try! ChatModelManger.sharedManager.save()
                club.rosterItem = rosterItem
                waiter.signal()
            })
            let waitUntil = DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
            // only wait for one second
            _ = waiter.wait(timeout: waitUntil)
            club = MainManager.sharedManager.objectWithSSID(club.ssid) as Club?
            club.rosterItem?.loadData()
            let kingfisherCache = KingfisherManager.shared.cache
            kingfisherCache.store(self.logoImage!, forKey: club!.logoURL!.absoluteString)
            self.delegate?.groupChatSetupControllerDidSuccessCreatingClub(club!)
            self.pp_hideProgressView()
            self.requesting = false
            }, onProgress: { (progress) in
                self.pp_updateProgress(progress)
            }) { (code) in
                self.showToast(LS("创建群聊失败"))
                self.pp_hideProgressView()
                self.requesting = false
        }
//        requester.createNewClub(clubName, clubLogo: logoImage!, members: userIDs, description: "Description", onSuccess: { (json) -> () in
//            // Notice: here we create the club instance after receiving response from server for simplicity
//            let newClub: Club = try! MainManager.sharedManager.getOrCreate(json!)
//            try! MainManager.sharedManager.save()
//            let kingfisherCache = KingfisherManager.sharedManager.cache
//            kingfisherCache.storeImage(self.logoImage!, forKey: newClub.logoURL!.absoluteString)
//            self.delegate?.groupChatSetupControllerDidSuccessCreatingClub(newClub)
//            self.pp_hideProgressView()
//            self.requesting = false
//            }, onProgress: { (progress) in
//                self.pp_updateProgress(progress)
//            }) { (code) -> () in
//                self.showToast(LS("创建群聊失败"))
//                self.pp_hideProgressView()
//                self.requesting = false
//        }
    }
    
    func logoBtnPressed() {
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
}

extension GroupChatSetupController {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismiss(animated: true, completion: nil)
        logoImage = image
        logo.setImage(logoImage!, for: .normal)
    }
    
}
