//
//  OtherPerson.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/11.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SwiftyJSON


class PersonOtherController: PersonBasicController {
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
    }
    
    func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = LS("个人信息")
        //
        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        backBtn.frame = CGRect(x: 0, y: 0, width: 10.5, height: 18)
        backBtn.addTarget(self, action: "navLeftBtnPressed", forControlEvents: .TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        //
        let shareBtn = UIButton()
        shareBtn.setImage(UIImage(named: "status_detail_other_operation"), forState: .Normal)
        shareBtn.imageView?.contentMode = .ScaleAspectFit
        shareBtn.frame = CGRect(x: 0, y: 0, width: 24, height: 214)
        shareBtn.addTarget(self, action: "navRightBtnPressed", forControlEvents: .TouchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareBtn)
        //

    }
    
    override func navRightBtnPressed() {
        
    }
    
    override func navLeftBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /*
     基于basic改造而来，主要是替换了用户信息面板的类
    */
    
    override func getPersonInfoPanel() -> PersonHeaderMine {
        let panel = PersonHeaderOther()
        totalHeaderHeight = 906 / 750 * self.view.frame.width
        panel.followBtn.addTarget(self, action: "followBtnPressed:", forControlEvents: .TouchUpInside)
        panel.chatBtn.addTarget(self, action: "chatBtnPressed", forControlEvents: .TouchUpInside)
        panel.locBtn.addTarget(self, action: "locateBtnPressed", forControlEvents: .TouchUpInside)
        //
        if data.user.followed {
            panel.followBtn.setImage(UIImage(named: "person_followed"), forState: .Normal)
            panel.followBtnTmpImage.image = UIImage(named: "person_followed")
        }
        return panel
    }
    
    func followBtnPressed(sender: UIButton) {
        let requester = PersonRequester.requester
        requester.follow(self.data.user.userID!, onSuccess: { (json) -> () in
            let board = self.header as! PersonHeaderOther
            
            if json!.boolValue {
                board.followBtnTmpImage.image = UIImage(named: "person_add_follow")
                board.followBtn.setImage(UIImage(named: "person_followed"), forState: .Normal)
            }else{
                board.followBtnTmpImage.image = UIImage(named: "person_followed")
                board.followBtn.setImage(UIImage(named: "person_add_follow"), forState: .Normal)
            }
            board.followBtnTmpImage.hidden = false
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                board.followBtnTmpImage.layer.opacity = 0
                }, completion: { (_) -> Void in
                    board.followBtnTmpImage.hidden = false
            })
            }) { (code) -> () in
                print(code)
        }
    }
    
    func chatBtnPressed() {
        ChatRecordDataSource.sharedDataSource.start()
        let room = ChatRoomController()
        ChatRecordDataSource.sharedDataSource.curRoom = room
        room.targetUser = data.user
        self.navigationController?.pushViewController(room, animated: true)
    }
    
    func locateBtnPressed() {
        
    }
}
