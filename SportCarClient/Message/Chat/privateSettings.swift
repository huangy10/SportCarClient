//
//  privateSettings.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/6.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyJSON

let kPrivateChatSettingSectionTitles = ["", LS("信息"), LS("聊天")]

class PrivateChatSettingController: UITableViewController, FFSelectDelegate, PersonMineSinglePropertyModifierDelegate, GroupChatSetupDelegate {
    /*
     列表长度有限，则直接采用UIScrollView
    */
    /// 目标用户
    var rosterItem: RosterItem!
//    var targetUser: User!
    var chater: Chater!
    var seeHisStatus: Bool = true
    var allowSeeStatus: Bool = true
    // 是否发生了修改
    var dirty = false
    // 调出用户选择界面的目的: group_chat/recommend
    var userSelectPurpose = ""
    
    var board: UIScrollView!
    var startGroupChatBtn: UIButton?
    var startChat: UIButton?
    
    var toast: UIView?
    
    @available(*, deprecated=1)
    init(targetUser: User) {
        super.init(style: .Plain)
//        self.targetUser = targetUser
    }
    
    init(rosterItem: RosterItem) {
        super.init(style: .Plain)
        self.rosterItem = rosterItem
        switch rosterItem.data! {
        case .USER(let chater):
            self.chater = chater
            break
        default:
            assertionFailure()
        }
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        
        tableView.separatorStyle = .None
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "start_group_chat_cell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "start_chat_cell")
        tableView.registerClass(PrivateChatSettingsAvatarCell.self, forCellReuseIdentifier: PrivateChatSettingsAvatarCell.reuseIdentifier)
        tableView.registerClass(PrivateChatSettingsCommonCell.self, forCellReuseIdentifier: PrivateChatSettingsCommonCell.reuseIdentifier)
        tableView.registerClass(PrivateChatSettingsHeader.self, forHeaderFooterViewReuseIdentifier: "reuse_header")
        // 从网络获取配置数据
//        let requester = ChatRequester.requester
//        requester.getUserRelationSettings(chater.ssidString, onSuccess: { (data) -> () in
//            self.chater.nickName = data!["remark_name"].string
//            self.allowSeeStatus = data!["allow_see_status"].boolValue
//            self.seeHisStatus = data!["see_his_status"].boolValue
//            self.tableView.reloadData()
//            }) { (code) -> () in
//        }
    }
    
    func navSettings() {
        self.navigationItem.title = chater.nickName
        let leftBtn = UIButton()
        leftBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        leftBtn.frame = CGRectMake(0, 0, 9, 15)
        leftBtn.addTarget(self, action: #selector(PrivateChatSettingController.navLeftBtnPressed), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
//        let rightBtn = UIButton()
//        rightBtn.setImage(UIImage(named: "status_detail_other_operation"), forState: .Normal)
//        rightBtn.imageView?.contentMode = .ScaleAspectFit
//        rightBtn.frame = CGRectMake(0, 0, 21, 21)
//        rightBtn.addTarget(self, action: "navRightBtnPressed", forControlEvents: .TouchUpInside)
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
    }
    
    func navRightBtnPressed() {
        let report = ReportBlacklistViewController(userID: chater.ssid, parent: self)
        self.presentViewController(report, animated: false, completion: nil)
    }
    
    func navLeftBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
        if dirty {
            ChatRequester2.sharedInstance.postUpdateUserRelationSettings(rosterItem.ssidString, remark_name: chater.nickName, alwaysOnTop: false, noDisturbing: false, onSuccess: { (_) in
                // do nothing
                self.showToast(LS("修改成功"))
                }) { (code) in
                    self.showToast("聊天设置更新失败")
            }
        }
//        let requester = ChatRequester.requester
//        requester.postUpdateUserRelationSettings(chater.ssidString, remark_name: chater.nickName!, allowSeeStatus: allowSeeStatus, seeHisStatus: seeHisStatus, onSuccess: { (_) -> () in
//            
//            }) { (code) -> () in
//                
//        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        case 2:
            return 3
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0.01
        }else {
            return 50
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("reuse_header") as! PrivateChatSettingsHeader
        header.titleLbl.text = kPrivateChatSettingSectionTitles[section]
        return header
    }
    

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsAvatarCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsAvatarCell
            cell.selectionStyle = .None
            cell.avatarImage.kf_setImageWithURL(chater.avatarURL!)
            return cell
        case 1:
            if indexPath.row < 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsCommonCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsCommonCell
                cell.selectionStyle = .None
                cell.staticLbl.text = LS("备注")
                cell.boolSelect.hidden = true
                if indexPath.row == 0 {
                    cell.infoLbl.text = chater.nickName
                }
                return cell
            }else {
                let cell = tableView.dequeueReusableCellWithIdentifier("start_group_chat_cell", forIndexPath: indexPath)
                cell.selectionStyle = .None
                if startGroupChatBtn == nil {
                    startGroupChatBtn = UIButton()
                    startGroupChatBtn?.addTarget(self, action: #selector(PrivateChatSettingController.startGroupChatPressed), forControlEvents: .TouchUpInside)
                    startGroupChatBtn?.setImage(UIImage(named: "chat_settings_add_person"), forState: .Normal)
                    cell.contentView.addSubview(startGroupChatBtn!)
                    startGroupChatBtn?.snp_makeConstraints(closure: { (make) -> Void in
                        make.left.equalTo(cell.contentView).offset(15)
                        make.centerY.equalTo(cell.contentView)
                        make.size.equalTo(65)
                    })
                    let staticLbl = UILabel()
                    staticLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
                    staticLbl.textColor = UIColor(white: 0.72, alpha: 1)
                    staticLbl.text = LS("发起一个群聊")
                    cell.contentView.addSubview(staticLbl)
                    staticLbl.snp_makeConstraints(closure: { (make) -> Void in
                        make.left.equalTo(startGroupChatBtn!.snp_right).offset(15)
                        make.centerY.equalTo(startGroupChatBtn!)
                    })
                }
                return cell
            }
//        case 2:
//            let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsCommonCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsCommonCell
//            cell.selectionStyle = .None
//            cell.staticLbl.text = [LS("不让他看我的动态"), LS("不看他的动态")][indexPath.row]
//            cell.detailTextLabel?.text = ""
//            cell.boolSelect.hidden = false
//            cell.boolSelect.tag = indexPath.row
//            if indexPath.row == 0 {
//                cell.boolSelect.setOn(!allowSeeStatus, animated: false)
//                cell.boolSelect.addTarget(self, action: #selector(PrivateChatSettingController.allowSeeStatusSwitchPressed(_:)), forControlEvents: .ValueChanged)
//            }else{
//                cell.boolSelect.setOn(!seeHisStatus, animated: false)
//                cell.boolSelect.addTarget(self, action: #selector(PrivateChatSettingController.seeHisStatusSwitchPressed(_:)), forControlEvents: .ValueChanged)
//            }
//            return cell
        default:
            if indexPath.row < 2 {
                let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsCommonCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsCommonCell
                cell.selectionStyle = .None
                cell.staticLbl.text = [LS("清空聊天内容"), LS("举报")][indexPath.row]
                cell.detailTextLabel?.text = ""
                cell.boolSelect.hidden = true
                return cell
            }else {
                let cell = tableView.dequeueReusableCellWithIdentifier("start_chat_cell", forIndexPath: indexPath)
                cell.selectionStyle = .None
                if startChat == nil {
                    startChat = UIButton()
                    startChat?.setImage(UIImage(named: "chat_setting_start_chat"), forState: .Normal)
                    startChat?.addTarget(self, action: #selector(startChatBtnPressed), forControlEvents: .TouchUpInside)
                    cell.contentView.addSubview(startChat!)
                    startChat?.snp_makeConstraints(closure: { (make) -> Void in
                        make.centerX.equalTo(cell.contentView)
                        make.top.equalTo(cell.contentView).offset(15)
                        make.size.equalTo(CGSizeMake(150, 50))
                    })
                }
                return cell
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 114
        case 1:
            if indexPath.row < 1 {
                return 50
            }else {
                return 105
            }
        case 2:
            return 50
        case 3:
            if indexPath.row < 2 {
                return 50
            }else {
                return 128
            }
        default:
            return 0
        }
    }
    
    func startGroupChatPressed() {
        userSelectPurpose = "group_chat"
        guard let user = chater.toUser() else {
            assertionFailure()
            return
        }
        let selector = FFSelectController(maxSelectNum: 100, preSelectedUsers: [user])
        let nav = BlackBarNavigationController(rootViewController: selector)
        selector.delegate = self
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    func seeHisStatusSwitchPressed(sender: UISwitch) {
        dirty = true
        seeHisStatus = !sender.on
    }
    
    func allowSeeStatusSwitchPressed(sender: UISwitch) {
        dirty = true
        allowSeeStatus = !sender.on
    }
}


// MARK: - 各个cell的功能的具体实现
extension PrivateChatSettingController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
        case 0:
            // 点击头像进入个人详情
            guard let user = chater.toUser() else {
                assertionFailure()
                return
            }
            let detail = PersonOtherController(user: user)
            self.navigationController?.pushViewController(detail, animated: true)
            break
        case 1:
            // 点击修改备注
            let detail = PersonMineSinglePropertyModifierController()
            detail.focusedIndexPath = indexPath
            detail.delegate = self
            detail.propertyName = LS("修改备注")
            detail.initValue = chater.nickName
            self.navigationController?.pushViewController(detail, animated: true)
        case 2:
            if indexPath.row == 0 {
                toast = showConfirmToast(LS("清除聊天信息"), message: LS("确定要清除聊天信息吗？"), target: self, confirmSelector: #selector(PrivateChatSettingController.clearChatContent), cancelSelector: #selector(PrivateChatSettingController.hideToast as (PrivateChatSettingController) -> () -> ()))
            } else if indexPath.row == 1 {
                let report = ReportBlacklistViewController(userID: chater.ssid, parent: self)
                self.presentViewController(report, animated: false, completion: nil)
            }
            break
        default:
            break
        }
    }
    
    func didModify(newValue: String?, indexPath: NSIndexPath) {
        dirty = true
        
        switch indexPath.section {
        case 1:
            if indexPath.row == 0 {
                chater.nickName = newValue
            }
            break
        default:
            break
        }
        
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func modificationCancelled() {
        // Do nothing for now
    }
    
    /**
     把他推荐给朋友
     */
    func recommendToFriend() {
        let selector = FFSelectController()
        let nav = BlackBarNavigationController(rootViewController: selector)
        selector.delegate = self
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    func userSelectCancelled() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func userSelected(users: [User]) {
        var users = users
        self.dismissViewControllerAnimated(true, completion: nil)
        if userSelectPurpose == "group_chat" {
            if users.findIndex({ $0.ssid == self.chater.ssid}) == nil, let user = self.chater.toUser() {
                users.insert(user, atIndex: 0)
            }
            if users.count <= 1 {
                assertionFailure()
            }
            let detail = GroupChatSetupController()
            detail.users = users
            detail.delegate = self
            self.navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    func groupChatSetupControllerDidSuccessCreatingClub(newClub: Club) {
        self.navigationController?.popViewControllerAnimated(true)
        let chatRoom = ChatRoomController()
        chatRoom.chatCreated = false
        chatRoom.targetClub = newClub
        self.navigationController?.pushViewController(chatRoom, animated: true)
    }
    
    /**
     清空聊天内容
     */
    func clearChatContent() {
        // 
        hideToast()
        MessageManager.defaultManager.clearChatHistory(rosterItem)
    }

    /**
     搜索聊天内容
     */
    func searchChatContent() {
        
    }
    
    func hideToast() {
        if toast != nil {
            hideToast(toast!)
        }
    }
    
    func startChatBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}