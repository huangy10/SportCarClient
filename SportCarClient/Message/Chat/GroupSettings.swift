//
//  GroupSettings.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/8.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit

let kGroupChatSettingSectionTitles = ["", "信息", "通知", "聊天"]

class GroupChatSettingController: UITableViewController, PersonMineSinglePropertyModifierDelegate, InlineUserSelectDelegate, FFSelectDelegate {
    
    var targetClub: Club!
    // 是否设置发生了更改
    var dirty: Bool = false
    
    // 活动描述：
    var activityDescription: String?
    
    var inlineUserSelect: InlineUserSelectController?
    var deleteQuitBtn: UIButton?
    
    var toast: UIView?
    
    init(targetClub: Club) {
        super.init(style: .Plain)
        self.targetClub = targetClub
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        tableView.separatorStyle = .None
        
        tableView.registerClass(PrivateChatSettingsAvatarCell.self, forCellReuseIdentifier: PrivateChatSettingsAvatarCell.reuseIdentifier)
        tableView.registerClass(PrivateChatSettingsCommonCell.self, forCellReuseIdentifier: PrivateChatSettingsCommonCell.reuseIdentifier)
        tableView.registerClass(PrivateChatSettingsHeader.self, forHeaderFooterViewReuseIdentifier: "reuse_header")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "inline_user_select")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "quit")
        
        let requester = ChatRequester.requester
        requester.getClubInfo(targetClub.ssidString, onSuccess: { (json) -> () in
            try! self.targetClub.loadDataFromJSON(json!, detailLevel: 0)
            self.targetClub.members.removeAll()
            for data in json!["club"]["members"].arrayValue {
                // 添加成员
                let user: User = try! MainManager.sharedManager.getOrCreate(data)
                self.targetClub.members.append(user)
            }
            self.tableView.reloadData()
            self.inlineUserSelect?.users = self.targetClub.members
            self.inlineUserSelect?.collectionView?.reloadData()
            
            }) { (code) -> () in
                print(code)
        }
    }
    
    func navSettings() {
        self.navigationItem.title = targetClub.name
        let leftBtn = UIButton()
        leftBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        leftBtn.frame = CGRectMake(0, 0, 9, 15)
        leftBtn.addTarget(self, action: "navLeftBtnPressed", forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        let rightBtn = UIButton()
        rightBtn.hidden = true
        rightBtn.setImage(UIImage(named: "status_detail_other_operation"), forState: .Normal)
        rightBtn.imageView?.contentMode = .ScaleAspectFit
        rightBtn.frame = CGRectMake(0, 0, 21, 21)
        rightBtn.addTarget(self, action: "navRightBtnPressed", forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
    }
    
    func navRightBtnPressed() {
        
    }
    
    func navLeftBtnPressed() {
        // push modification to the server
        if dirty {
            let requester = ChatRequester.requester
            requester.updateClubSettings(targetClub, onSuccess: { (json) -> () in
                // Do nothing when succeed since modification has already taken effects
                }, onError: { (code) -> () in
                    print(code)
            })
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return kGroupChatSettingSectionTitles.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 1
        case 1:
            return 6
        case 2:
            return 2
        default:
            return 4
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else {
            return 50
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            return nil
        }
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("reuse_header") as! PrivateChatSettingsHeader
        header.titleLbl.text = kGroupChatSettingSectionTitles[section]
        return header
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 114
        case 1:
            if indexPath.row < 5 {
                return 50
            }else {
                let userNum = targetClub.members.count
                let height: CGFloat = 110 * CGFloat(userNum / 4 + 1)
                return height
            }
        case 2:
            return 50
        case 3:
            if indexPath.row < 3 {
                return 50
            }else {
                return 128
            }
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsAvatarCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsAvatarCell
            cell.avatarImage.kf_setImageWithURL(targetClub.logoURL!, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                if error == nil {
                    cell.avatarImage.setupForImageViewer(nil, backgroundColor: UIColor.blackColor())
                }
            })
            return cell
        case 1:
            if indexPath.row < 5 {
                let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsCommonCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsCommonCell
                cell.selectionStyle = .None
                switch indexPath.row {
                case 0:
                    cell.staticLbl.text = LS("群聊名称")
                    cell.infoLbl.text = targetClub.name
                    cell.boolSelect.hidden = true
                    break
                case 1:
                    cell.staticLbl.text = LS("本群简介")
                    cell.infoLbl.text = targetClub.clubDescription
                    cell.boolSelect.hidden = true
                    break
                case 2:
                    cell.staticLbl.text = LS("本群活动")
                    cell.infoLbl.text = activityDescription
                    cell.boolSelect.hidden = true
                    break
                case 3:
                    cell.staticLbl.text = LS("我在本群的昵称")
                    cell.infoLbl.text = targetClub.remarkName ?? MainManager.sharedManager.hostUser!.nickName
                    cell.boolSelect.hidden = true
                    break
                default:
                    cell.staticLbl.text = LS("显示本群昵称")
                    cell.boolSelect.hidden = false
                    cell.infoLbl.text = ""
                    cell.boolSelect.on = targetClub.showNickName ?? true
                    cell.tag = 0
                    cell.boolSelect.addTarget(self, action: "switchBtnPressed:", forControlEvents: .ValueChanged)
                }
                return cell
            }else {
                let cell = tableView.dequeueReusableCellWithIdentifier("inline_user_select", forIndexPath: indexPath)
                cell.selectionStyle = .None
                if inlineUserSelect == nil {
                    inlineUserSelect = InlineUserSelectController()
                    inlineUserSelect?.delegate = self
                    cell.contentView.addSubview(inlineUserSelect!.view)
                    inlineUserSelect?.view.snp_makeConstraints(closure: { (make) -> Void in
                        make.edges.equalTo(cell.contentView)
                    })
                    inlineUserSelect?.relatedClub = targetClub
                }
                inlineUserSelect?.users = Array(targetClub.members)
                inlineUserSelect?.showAddBtn = !targetClub.onlyHostCanInvite
                inlineUserSelect?.collectionView?.reloadData()
                return cell
            }
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsCommonCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsCommonCell
            cell.selectionStyle = .None
            switch indexPath.row {
            case 0:
                cell.staticLbl.text = LS("消息免打扰")
                cell.infoLbl.text = ""
                cell.boolSelect.hidden = false
                cell.boolSelect.tag = 1
                cell.boolSelect.on = targetClub.noDisturbing
                cell.boolSelect.addTarget(self, action: "switchBtnPressed:", forControlEvents: .ValueChanged)
                break
            case 1:
                cell.staticLbl.text = LS("置顶聊天")
                cell.infoLbl.text = ""
                cell.boolSelect.hidden = false
                cell.boolSelect.tag = 2
                cell.boolSelect.on = targetClub.alwayOnTop
                cell.boolSelect.addTarget(self, action: "switchBtnPressed:", forControlEvents: .ValueChanged)
                break
            default:
                break
            }
            return cell
        default:
            if indexPath.row < 3 {
                let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsCommonCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsCommonCell
                cell.staticLbl.text = [LS("查找聊天内容"), LS("清空聊天内容"), LS("举报")][indexPath.row]
                cell.infoLbl.text = ""
                cell.boolSelect.hidden = true
                return cell
            }else {
                let cell = tableView.dequeueReusableCellWithIdentifier("quit", forIndexPath: indexPath)
                if deleteQuitBtn == nil {
                    deleteQuitBtn = UIButton()
                    deleteQuitBtn?.setImage(UIImage(named: "delete_and_quit_btn"), forState: .Normal)
                    deleteQuitBtn?.addTarget(self, action: "deleteAndQuitBtnPressed", forControlEvents: .TouchUpInside)
                    cell.contentView.addSubview(deleteQuitBtn!)
                    deleteQuitBtn?.snp_makeConstraints(closure: { (make) -> Void in
                        make.centerX.equalTo(cell.contentView)
                        make.top.equalTo(cell.contentView).offset(15)
                        make.size.equalTo(CGSizeMake(150, 50))
                    })
                }
                return cell
            }
            
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 3 {
            // 修改本群昵称
            let detail = PersonMineSinglePropertyModifierController()
            detail.initValue = targetClub.remarkName ?? MainManager.sharedManager.hostUser!.nickName
            detail.focusedIndexPath = indexPath
            detail.delegate = self
            self.navigationController?.pushViewController(detail, animated: true)
        } else if indexPath.section == 3 && indexPath.row == 1 {
            showConfirmToast(LS("确定清除聊天记录?"), target: self, confirmSelector: "clearChatContent", cancelSelector: "hideToast")
        }
    }
    
    func didModify(newValue: String?, indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 3 {
            dirty = true
            targetClub.remarkName = newValue
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    func modificationCancelled() {
        // Do nothing
    }
    
    func inlineUserSelectNeedAddMembers() {
        if targetClub.onlyHostCanInvite {
            self.showToast(LS("本群只有群主能够邀请成员"))
            return
        }
        let select = FFSelectController()
        select.selectedUsers = Array(targetClub.members)
        select.delegate = self
        let wrapper = BlackBarNavigationController(rootViewController: select)
        self.presentViewController(wrapper, animated: true, completion: nil)
    }
    
    func userSelectCancelled() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func userSelected(users: [User]) {
        // send request to the server
        dismissViewControllerAnimated(true, completion: nil)
        if users.count == 0 { return }
        let userIDs = users.map({return $0.ssidString})
        let originIDs = Array(targetClub.members).map({return $0.ssidString})
        let targets = userIDs.filter({!originIDs.contains($0)})
        let requester = ChatRequester.requester
        requester.updateClubMembers(targetClub.ssidString, members: targets, opType: "add", onSuccess: { (json) -> () in
            // TODO: 放到请求外面
            self.targetClub.members.appendContentsOf(users)
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 5, inSection: 1)], withRowAnimation: .Automatic)
            }) { (code) -> () in
                if code == "no permission" {
                    self.showToast(LS("您没有权限进行此项操作"))
                }
                print(code)
        }
    }
    
    func clearChatContent() {
        let identifier = targetClub.ssidString
        ChatRecordDataSource.sharedDataSource.clearChatContentForIdentifier(identifier)
        hideToast()
    }
    
    func hideToast() {
        if toast != nil {
            hideToast(toast!)
        }
    }
}

extension GroupChatSettingController {
    
    func switchBtnPressed(sender: UISwitch) {
        dirty = true
        switch sender.tag {
        case 0:
            targetClub.showNickName = sender.on
            break
        case 1:
            targetClub.noDisturbing = sender.on
            break
        case 2:
            targetClub.alwayOnTop = sender.on
        default:
            break
        }
    }
    
    func deleteAndQuitBtnPressed() {
        
    }
}
