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
    func groupChatSetupControllerDidSuccessCreatingClub(newClub: Club)
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
        let superview = self.view
        superview.backgroundColor = UIColor.whiteColor()
        //
        let logoLbl = UILabel()
        logoLbl.text = LS("请选择一个标识")
        logoLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightSemibold)
        logoLbl.textColor = UIColor.blackColor()
        logoLbl.textAlignment = .Center
        superview.addSubview(logoLbl)
        logoLbl.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.top.equalTo(superview).offset(25)
        }
        //
        logo = UIButton()
        logo.layer.cornerRadius = 45
        logo.clipsToBounds = true
        logo.setImage(UIImage(named: "account_profile_avatar_btn"), forState: .Normal)
        superview.addSubview(logo)
        logo.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.top.equalTo(logoLbl.snp_bottom).offset(20)
            make.size.equalTo(90)
        }
        logo.addTarget(self, action: #selector(GroupChatSetupController.logoBtnPressed), forControlEvents: .TouchUpInside)
        //
        nameInput = UITextField()
        nameInput.delegate = self
        inputFields.append(nameInput)
        nameInput.textColor = UIColor.blackColor()
        nameInput.font = UIFont.systemFontOfSize(15, weight: UIFontWeightUltraLight)
        nameInput.textAlignment = .Center
        nameInput.placeholder = LS("请输入群聊名称")
        superview.addSubview(nameInput)
        nameInput.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.top.equalTo(logo.snp_bottom).offset(30)
            make.size.equalTo(CGSizeMake(250, 27.5))
        }
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.945, alpha: 1)
        superview.addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(nameInput.snp_bottom).offset(3)
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
        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        navLeftBtn.frame = CGRectMake(0, 0, 9, 15)
        navLeftBtn.addTarget(self, action: #selector(GroupChatSetupController.navLeftBtnPressed), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        //
        let rightItem = UIBarButtonItem(title: LS("确定"), style: .Done, target: self, action: #selector(GroupChatSetupController.navRightBtnPressed))
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func navLeftBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func navRightBtnPressed() {
        if requesting { return }
        nameInput.resignFirstResponder()
        // Check the data
        guard let clubName = nameInput.text where clubName.length > 0 else {
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
            let waiter: dispatch_semaphore_t = dispatch_semaphore_create(0)
            dispatch_async(ChatModelManger.sharedManager.workQueue, {
                club = try! ChatModelManger.sharedManager.getOrCreate(json!) as Club
                let rosterItem = RosterManager.defaultManager.getOrCreateNewRoster(json!["roster"], autoBringToFront: true)
                try! ChatModelManger.sharedManager.save()
                club.rosterItem = rosterItem
                dispatch_semaphore_signal(waiter)
            })
            let waitUntil = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
            // only wait for one second
            dispatch_semaphore_wait(waiter, waitUntil)
            club = MainManager.sharedManager.objectWithSSID(club.ssid) as Club?
            club.rosterItem?.loadData()
            let kingfisherCache = KingfisherManager.sharedManager.cache
            kingfisherCache.storeImage(self.logoImage!, forKey: club!.logoURL!.absoluteString)
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
        let alert = UIAlertController(title: NSLocalizedString("选择图片", comment: ""), message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("拍照", comment: ""), style: .Default, handler: { (action) -> Void in
            let sourceType = UIImagePickerControllerSourceType.Camera
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                let alert = UIAlertController(title: "错误", message: "无法打开相机", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("从相册中选择", comment: ""), style: .Default, handler: { (action) -> Void in
            let sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                let alert = UIAlertController(title: "错误", message: "无法打开相册", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

extension GroupChatSetupController {
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        logoImage = image
        logo.setImage(logoImage!, forState: .Normal)
    }
    
}
