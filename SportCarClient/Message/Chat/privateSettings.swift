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
//    var chater: Chater!
    var user: User!
    var seeHisStatus: Bool = true
    var allowSeeStatus: Bool = true
    // 是否发生了修改
    var dirty = false
    // 调出用户选择界面的目的: group_chat/recommend
    var userSelectPurpose = ""
    
    var board: UIScrollView!
    var startGroupChatBtn: UIButton?
    var startChat: UIButton?
    
    @available(*, deprecated: 1)
    init(targetUser: User) {
        super.init(style: .plain)
//        self.targetUser = targetUser
    }
    
    init(rosterItem: RosterItem) {
        super.init(style: .plain)
        self.rosterItem = rosterItem
        switch rosterItem.data! {
        case .user(let user):
            self.user = user
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
        
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "start_group_chat_cell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "start_chat_cell")
        tableView.register(PrivateChatSettingsAvatarCell.self, forCellReuseIdentifier: PrivateChatSettingsAvatarCell.reuseIdentifier)
        tableView.register(PrivateChatSettingsCommonCell.self, forCellReuseIdentifier: PrivateChatSettingsCommonCell.reuseIdentifier)
        tableView.register(PrivateChatSettingsHeader.self, forHeaderFooterViewReuseIdentifier: "reuse_header")
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
        self.navigationItem.title = user.chatName
        let leftBtn = UIButton()
        leftBtn.setImage(UIImage(named: "account_header_back_btn"), for: .normal)
        leftBtn.frame = CGRect(x: 0, y: 0, width: 9, height: 15)
        leftBtn.addTarget(self, action: #selector(PrivateChatSettingController.navLeftBtnPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
//        let rightBtn = UIButton()
//        rightBtn.setImage(UIImage(named: "status_detail_other_operation"), forState: .Normal)
//        rightBtn.imageView?.contentMode = .ScaleAspectFit
//        rightBtn.frame = CGRectMake(0, 0, 21, 21)
//        rightBtn.addTarget(self, action: "navRightBtnPressed", forControlEvents: .TouchUpInside)
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
    }
    
    func navRightBtnPressed() {
        let report = ReportBlacklistViewController(userID: user.ssid, parent: self)
        self.present(report, animated: false, completion: nil)
    }
    
    func navLeftBtnPressed() {
        _ = self.navigationController?.popViewController(animated: true)
        if dirty {
            _ = ChatRequester2.sharedInstance.postUpdateUserRelationSettings(rosterItem.ssidString, remark_name: user.noteName ?? "", alwaysOnTop: false, noDisturbing: false, onSuccess: { (_) in
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0.01
        }else {
            return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "reuse_header") as! PrivateChatSettingsHeader
        header.titleLbl.text = kPrivateChatSettingSectionTitles[section]
        return header
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: PrivateChatSettingsAvatarCell.reuseIdentifier, for: indexPath) as! PrivateChatSettingsAvatarCell
            cell.selectionStyle = .none
            cell.avatarImage.kf.setImage(with: user.avatarURL!)
            return cell
        case 1:
            if (indexPath as NSIndexPath).row < 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: PrivateChatSettingsCommonCell.reuseIdentifier, for: indexPath) as! PrivateChatSettingsCommonCell
                cell.selectionStyle = .none
                cell.staticLbl.text = LS("备注")
                cell.boolSelect.isHidden = true
                if (indexPath as NSIndexPath).row == 0 {
                    cell.infoLbl.text = user.chatName
                }
                return cell
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "start_group_chat_cell", for: indexPath)
                cell.selectionStyle = .none
                if startGroupChatBtn == nil {
                    startGroupChatBtn = UIButton()
                    startGroupChatBtn?.addTarget(self, action: #selector(PrivateChatSettingController.startGroupChatPressed), for: .touchUpInside)
                    startGroupChatBtn?.setImage(UIImage(named: "chat_settings_add_person"), for: .normal)
                    cell.contentView.addSubview(startGroupChatBtn!)
                    startGroupChatBtn?.snp.makeConstraints({ (make) -> Void in
                        make.left.equalTo(cell.contentView).offset(15)
                        make.centerY.equalTo(cell.contentView)
                        make.size.equalTo(65)
                    })
                    let staticLbl = UILabel()
                    staticLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
                    staticLbl.textColor = UIColor(white: 0.72, alpha: 1)
                    staticLbl.text = LS("发起一个群聊")
                    cell.contentView.addSubview(staticLbl)
                    staticLbl.snp.makeConstraints({ (make) -> Void in
                        make.left.equalTo(startGroupChatBtn!.snp.right).offset(15)
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
            if (indexPath as NSIndexPath).row < 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: PrivateChatSettingsCommonCell.reuseIdentifier, for: indexPath) as! PrivateChatSettingsCommonCell
                cell.selectionStyle = .none
                cell.staticLbl.text = [LS("清空聊天内容"), LS("举报")][(indexPath as NSIndexPath).row]
                cell.detailTextLabel?.text = ""
                cell.boolSelect.isHidden = true
                return cell
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "start_chat_cell", for: indexPath)
                cell.selectionStyle = .none
                if startChat == nil {
                    startChat = UIButton()
                    startChat?.setImage(UIImage(named: "chat_setting_start_chat"), for: .normal)
                    startChat?.addTarget(self, action: #selector(startChatBtnPressed), for: .touchUpInside)
                    cell.contentView.addSubview(startChat!)
                    startChat?.snp.makeConstraints({ (make) -> Void in
                        make.centerX.equalTo(cell.contentView)
                        make.top.equalTo(cell.contentView).offset(15)
                        make.size.equalTo(CGSize(width: 150, height: 50))
                    })
                }
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath as NSIndexPath).section {
        case 0:
            return 114
        case 1:
            if (indexPath as NSIndexPath).row < 1 {
                return 50
            }else {
                return 105
            }
        case 2:
            return 50
        case 3:
            if (indexPath as NSIndexPath).row < 2 {
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
//        guard let user = chater.toUser() else {
//            assertionFailure()
//            return
//        }
        let selector = FFSelectController(maxSelectNum: 100, preSelectedUsers: [user])
        let nav = BlackBarNavigationController(rootViewController: selector)
        selector.delegate = self
        self.present(nav, animated: true, completion: nil)
    }
    
    func seeHisStatusSwitchPressed(_ sender: UISwitch) {
        dirty = true
        seeHisStatus = !sender.isOn
    }
    
    func allowSeeStatusSwitchPressed(_ sender: UISwitch) {
        dirty = true
        allowSeeStatus = !sender.isOn
    }
}


// MARK: - 各个cell的功能的具体实现
extension PrivateChatSettingController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath as NSIndexPath).section {
        case 0:
            // 点击头像进入个人详情
//            guard let user = chater.toUser() else {
//                assertionFailure()
//                return
//            }
            let detail = PersonOtherController(user: user)
            self.navigationController?.pushViewController(detail, animated: true)
            break
        case 1:
            // 点击修改备注
            let detail = PersonMineSinglePropertyModifierController()
            detail.focusedIndexPath = indexPath
            detail.delegate = self
            detail.propertyName = LS("修改备注")
            detail.initValue = user.chatName
            self.navigationController?.pushViewController(detail, animated: true)
        case 2:
            if (indexPath as NSIndexPath).row == 0 {
                showConfirmToast(LS("清除聊天信息"), message: LS("确定要清除聊天信息吗？"), target: self, onConfirm: #selector(clearChatContent))
            } else if (indexPath as NSIndexPath).row == 1 {
                let report = ReportBlacklistViewController(userID: user.ssid, parent: self)
                self.present(report, animated: false, completion: nil)
            }
            break
        default:
            break
        }
    }
    
    func didModify(_ newValue: String?, indexPath: IndexPath) {
        dirty = true
        
        switch (indexPath as NSIndexPath).section {
        case 1:
            if (indexPath as NSIndexPath).row == 0 {
                user.noteName = newValue
            }
            break
        default:
            break
        }
        
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
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
        self.present(nav, animated: true, completion: nil)
    }
    
    func userSelectCancelled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func userSelected(_ users: [User]) {
        var users = users
        self.dismiss(animated: true, completion: nil)
        if userSelectPurpose == "group_chat" {
            if users.findIndex(callback: { $0.ssid == self.user.ssid}) == nil {
                users.insert(user, at: 0)
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
    
    func groupChatSetupControllerDidSuccessCreatingClub(_ newClub: Club) {
        _ = self.navigationController?.popViewController(animated: true)
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
        MessageManager.defaultManager.clearChatHistory(rosterItem)
    }

    /**
     搜索聊天内容
     */
    func searchChatContent() {
        
    }
    
    func startChatBtnPressed() {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
