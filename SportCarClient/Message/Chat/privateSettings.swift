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

let kPrivateChatSettingSectionTitles = ["", LS("信息"), LS("隐私"), LS("聊天")]

class PrivateChatSettingController: UITableViewController, FFSelectDelegate, PersonMineSinglePropertyModifierDelegate, GroupChatSetupDelegate {
    /*
     列表长度有限，则直接采用UIScrollView
    */
    /// 目标用户
    var targetUser: User!
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
    
    init(targetUser: User) {
        super.init(style: .Plain)
        self.targetUser = targetUser
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
        let requester = ChatRequester.requester
        requester.getUserRelationSettings(targetUser.ssidString, onSuccess: { (data) -> () in
            self.targetUser.remarkName = data!["remark_name"].string
            self.allowSeeStatus = data!["allow_see_status"].boolValue
            self.seeHisStatus = data!["see_his_status"].boolValue
            self.tableView.reloadData()
            }) { (code) -> () in
        }
    }
    
    func navSettings() {
        self.navigationItem.title = targetUser.nickName
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
        let report = ReportBlacklistViewController(user: targetUser, parent: self)
        self.presentViewController(report, animated: false, completion: nil)
    }
    
    func navLeftBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
        let requester = ChatRequester.requester
        requester.postUpdateUserRelationSettings(targetUser.ssidString, remark_name: targetUser.remarkName!, allowSeeStatus: allowSeeStatus, seeHisStatus: seeHisStatus, onSuccess: { (_) -> () in
            
            }) { (code) -> () in
                
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        case 2:
            return 2
        case 3:
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
            cell.avatarImage.kf_setImageWithURL(targetUser.avatarURL!)
            return cell
        case 1:
            if indexPath.row < 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsCommonCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsCommonCell
                cell.selectionStyle = .None
                cell.staticLbl.text = LS("备注")
                cell.boolSelect.hidden = true
                if indexPath.row == 0 {
                    cell.infoLbl.text = targetUser.remarkName ?? targetUser.nickName
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
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsCommonCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsCommonCell
            cell.selectionStyle = .None
            cell.staticLbl.text = [LS("不让他看我的动态"), LS("不看他的动态")][indexPath.row]
            cell.detailTextLabel?.text = ""
            cell.boolSelect.hidden = false
            cell.boolSelect.tag = indexPath.row
            if indexPath.row == 0 {
                cell.boolSelect.setOn(!allowSeeStatus, animated: false)
                cell.boolSelect.addTarget(self, action: #selector(PrivateChatSettingController.allowSeeStatusSwitchPressed(_:)), forControlEvents: .ValueChanged)
            }else{
                cell.boolSelect.setOn(!seeHisStatus, animated: false)
                cell.boolSelect.addTarget(self, action: #selector(PrivateChatSettingController.seeHisStatusSwitchPressed(_:)), forControlEvents: .ValueChanged)
            }
            return cell
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
        let selector = FFSelectController(maxSelectNum: 100, preSelectedUsers: [targetUser])
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
            let detail = PersonOtherController(user: self.targetUser)
            self.navigationController?.pushViewController(detail, animated: true)
            break
        case 1:
            // 点击修改备注
            let detail = PersonMineSinglePropertyModifierController()
            detail.focusedIndexPath = indexPath
            detail.delegate = self
            detail.propertyName = LS("修改备注")
            detail.initValue = targetUser.remarkName ?? targetUser.nickName
            self.navigationController?.pushViewController(detail, animated: true)
        case 3:
            if indexPath.row == 0 {
                toast = showConfirmToast(LS("清除聊天信息"), message: LS("确定要清除聊天信息吗？"), target: self, confirmSelector: #selector(PrivateChatSettingController.clearChatContent), cancelSelector: #selector(PrivateChatSettingController.hideToast as (PrivateChatSettingController) -> () -> ()))
            } else if indexPath.row == 1 {
                let report = ReportBlacklistViewController(user: targetUser, parent: self)
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
                targetUser.remarkName = newValue
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
            if users.findIndex({ $0.ssid == self.targetUser.ssid}) == nil {
                users.insert(self.targetUser, atIndex: 0)
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
        chatRoom.targetClub = newClub
        self.navigationController?.pushViewController(chatRoom, animated: true)
    }
    
    /**
     情况聊天内容
     */
    func clearChatContent() {
        let hostID = MainManager.sharedManager.hostUserIDString
        let targetID = targetUser.ssidString
        let identifier = getIdentifierForIdPair(hostID!, targetID)
        ChatRecordDataSource.sharedDataSource.clearChatContentForIdentifier(identifier)
        hideToast()
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
}