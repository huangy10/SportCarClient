//
//  GroupChatSetUp.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/26.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Kingfisher


protocol GroupChatSetupDelegate: class {
    func groupChatSetupControllerDidSuccessCreatingClub(newClub: Club)
}


class GroupChatSetupController: InputableViewController, ImageInputSelectorDelegate {
    
    weak var delegate: GroupChatSetupDelegate?
    
    var users: [User] = []
    
    var logoImage: UIImage?
    var name: String?
    
    var logo: UIButton!
    var nameInput: UITextField!
    
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
        logo.addTarget(self, action: "logoBtnPressed", forControlEvents: .TouchUpInside)
        //
        nameInput = UITextField()
        nameInput.delegate = self
        inputFields.append(nameInput)
        nameInput.textColor = UIColor.blackColor()
        nameInput.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
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
        navLeftBtn.addTarget(self, action: "navLeftBtnPressed", forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        //
        let rightItem = UIBarButtonItem(title: LS("确定"), style: .Done, target: self, action: "navRightBtnPressed")
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func navLeftBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func navRightBtnPressed() {
        nameInput.resignFirstResponder()
        // Check the data
        guard let clubName = nameInput.text where clubName.length > 0 else {
            self.displayAlertController(LS("请填写俱乐部名称"), message: nil)
            return
        }
        if logoImage == nil {
            self.displayAlertController(LS("请为俱乐部选择一个标志"), message: nil)
        }
        let userIDs = users.map { $0.userID! }
        // send creation request
        let requester = ChatRequester.requester
        requester.createNewClub(clubName, clubLogo: logoImage!, members: userIDs, description: "Description", onSuccess: { (json) -> () in
            // Notice: here we create the club instance after receiving response from server for simplicity
            let newClub = Club.objects.getOrCreate(json!)
            //
            let kingfisherCache = KingfisherManager.sharedManager.cache
            kingfisherCache.storeImage(self.logoImage!, forKey: SFURL(newClub.logo_url!)!.absoluteString)
            self.delegate?.groupChatSetupControllerDidSuccessCreatingClub(newClub)
            }) { (code) -> () in
                self.displayAlertController(LS("创建群聊失败"), message: nil)
                print(code)
        }
        
    }
    
    func logoBtnPressed() {
        let selector = ImageInputSelectorController()
        selector.delegate = self
        selector.bgImage = self.getScreenShotBlurred(false)
        self.presentViewController(selector, animated: false, completion: nil)
    }
}

extension GroupChatSetupController {
    
    func imageInputSelectorDidCancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imageInputSelectorDidSelectImage(image: UIImage) {
        self.dismissViewControllerAnimated(true, completion: nil)
        logoImage = image
        logo.setImage(logoImage!, forState: .Normal)
    }
    
}
