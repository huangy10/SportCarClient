//
//  GroupSettingHost.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/3.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//
//  群主所见的群聊设置
//

import UIKit
import Kingfisher


class GroupChatSettingHostController: GroupChatSettingController, ImageInputSelectorDelegate {
    
    var newLogo: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(GroupChatSettingHostClubAuthCell.self, forCellReuseIdentifier: "auth_status")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "inline_user_select_deletable")
    }
    
    override func navSettings() {
        // Override this method to enable "release activity" button
        self.navigationItem.title = targetClub.name
        let leftBtn = UIButton()
        leftBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        leftBtn.frame = CGRectMake(0, 0, 9, 15)
        leftBtn.addTarget(self, action: "navLeftBtnPressed", forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        let barBtnItem = UIBarButtonItem(title: LS("发布活动"), style: .Plain, target: self, action: "navRightBtnPressed")
        barBtnItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
        self.navigationItem.rightBarButtonItem = barBtnItem
    }
    
    override func navLeftBtnPressed() {
        // TODO: 将修改结果提交给服务器
        if dirty {
            let requester = ChatRequester.requester
            requester.updateClubSettings(targetClub, onSuccess: { (json) -> () in
                }, onError: { (code) -> () in
                    print(code)
            })
        }
        if newLogo != nil {
            let requester = ChatRequester.requester
            requester.updateClubLogo(targetClub, newLogo: newLogo!, onSuccess: { (json) -> () in
                if let newLogoURL = json?.string where self.newLogo != nil {
                    self.targetClub.logo = newLogoURL
                    // save the uploaded image to the shared cache
                    let logoURL = SFURL(newLogoURL)!
                    let cache = KingfisherManager.sharedManager.cache
                    cache.storeImage(self.newLogo!, forKey: logoURL.absoluteString)
                }
                }, onError: { (code) -> () in
                    print(code)
            })
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func navRightBtnPressed() {
        // TODO: pop up activity-release window
        //
        let detail = ActivityReleasePresentableController()
        detail.clubLimitID = targetClub.ssid
        detail.clubLimit = targetClub.name!
        detail.presentFrom(self)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return super.tableView(tableView, numberOfRowsInSection: section) + 3
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsAvatarCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsAvatarCell
            if newLogo != nil {
                cell.avatarImage.image = newLogo
                return cell
            }
            cell.avatarImage.kf_setImageWithURL(targetClub.logoURL!)
            return cell
        case 1:
            switch indexPath.row {
            case 2:
                // 群主打开本群活动改成俱乐部认证状态
                let cell = tableView.dequeueReusableCellWithIdentifier("auth_status", forIndexPath: indexPath) as! GroupChatSettingHostClubAuthCell
                cell.staticLbl.text = LS("俱乐部认证")
                cell.authed = targetClub.identified
                return cell
            case 3..<6:
                // 后面的cell向后移动
                return super.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section))
            case 6..<8:
                let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsCommonCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsCommonCell
                cell.boolSelect.hidden = false
                cell.infoLbl.text = ""
                cell.boolSelect.on = [targetClub.onlyHostCanInvite, targetClub.showMembers][indexPath.row - 6]
                // 0，1，2已经被占用了，这里从3开始编号，此时页面的5个switch按钮的对应关系如下：
                // 0 - 显示本群昵称； 1 - 消息免打扰； 2 - 置顶聊天； 3 - 仅我可以邀请，4 - 对外公布成员信息
                cell.boolSelect.tag = indexPath.row - 3
                cell.staticLbl.text = [LS("仅我可以邀请"), LS("对外公布群成员信息")][indexPath.row - 6]
                cell.boolSelect.addTarget(self, action: "switchBtnPressed:", forControlEvents: .ValueChanged)
                return cell
            case 8:
                // user inlineUserSelectDeletable
                let cell = tableView.dequeueReusableCellWithIdentifier("inline_user_select_deletable", forIndexPath: indexPath)
                if inlineUserSelect == nil {
                    let select = InlineUserSelectDeletable()
                    cell.contentView.addSubview(select.view)
                    select.view.snp_makeConstraints(closure: { (make) -> Void in
                        make.edges.equalTo(cell.contentView)
                    })
                    select.relatedClub = targetClub
                    select.delegate = self
                    inlineUserSelect = select
                    inlineUserSelect?.parentController = self
                }
                inlineUserSelect?.users = Array(targetClub.members)
                inlineUserSelect?.showAddBtn = true
                inlineUserSelect?.showDeleteBtn = true
                return cell
            default:
                return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
            }
        default:
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 {
            if indexPath.row < 8 {
                return 50
            }else {
                let userNum = targetClub.members.count + 2
                let height: CGFloat = 110 * CGFloat(userNum / 4 + 1)
                return height
            }
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            // 点击第一个section修改logo
            let picker = ImageInputSelectorController()
            picker.bgImage = self.getScreenShotBlurred(false)
            picker.delegate = self
            self.presentViewController(picker, animated: false, completion: nil)
            break
        case 1:
            let modifier = PersonMineSinglePropertyModifierController()
            switch indexPath.row {
            case 0:
                // 这三行：群聊名称，本群简介和我再本群的昵称可以修改
                modifier.initValue = targetClub.name
            case 1:
                modifier.initValue = targetClub.clubDescription
            case 4:
                modifier.initValue = targetClub.remarkName ?? MainManager.sharedManager.hostUser!.nickName!
            case 2:
                if !targetClub.identified {
                    // If the club is not identified, show auth controller
                    let auth = ClubAuthController()
                    auth.club = targetClub
                    self.navigationController?.pushViewController(auth, animated: true)
                    return
                }
            default:
                return
            }
            modifier.focusedIndexPath = indexPath
            modifier.delegate = self
            self.navigationController?.pushViewController(modifier, animated: true)
            break
        case 3:
            switch indexPath.row {
            case 1:
                toast = showConfirmToast(LS("确定清除聊天记录?"), target: self, confirmSelector: "clearChatContent", cancelSelector: "hideToast")
            default:
                break
            }
        default:
            break
        }
    }
    
    override func switchBtnPressed(sender: UISwitch) {
        dirty = true
        if sender.tag < 3 {
            super.switchBtnPressed(sender)
        }else if sender.tag == 3 {
            targetClub.onlyHostCanInvite = sender.on
        }else {
            targetClub.showMembers = sender.on
        }
    }
    
    // MARK: - 图像选择的代理
    func imageInputSelectorDidCancel() {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func imageInputSelectorDidSelectImage(image: UIImage) {
        // 选择了新的logo
        self.dismissViewControllerAnimated(false, completion: nil)
        newLogo = image
        // 由于俱乐部标志的修改被单独分离了出来，故这里不再设置dirty参数
//        dirty = true
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
    }
    
    // MARK: - 单项属性修改器代理
    override func didModify(newValue: String?, indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            // 群聊名称
            targetClub.name = newValue
            break
        case 1:
            // 本群简介
            targetClub.clubDescription = newValue
            break
        case 4:
            // 我在本群的昵称
            targetClub.remarkName = newValue
            break
        default:
            break
        }
        dirty = true
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    override func modificationCancelled() {
        // Do nothing
    }
    
    func inlineUserSelectShouldDeleteUser(user: User) {
        // TODO finish this
    }
    
    override func inlineUserSelectNeedAddMembers() {
        let select = FFSelectController()
        select.selectedUsers = Array(targetClub.members)
        select.delegate = self
        let wrapper = BlackBarNavigationController(rootViewController: select)
        self.presentViewController(wrapper, animated: true, completion: nil)
    }
}




class GroupChatSettingHostClubAuthCell: PrivateChatSettingsCommonCell {
    var authIcon: UIImageView!
    
    var authed: Bool = true {
        didSet {
            if authed {
                authIcon.image = UIImage(named: "auth_status_authed")
            }else {
                authIcon.image = UIImage(named: "auth_status_unauthed")
            }
        }
    }
    
    override func createSubviews() {
        super.createSubviews()
        //
        infoLbl.hidden = true
        boolSelect.hidden = true
        markIcon.hidden = true
        authIcon = UIImageView(image: UIImage(named: "auth_status_authed"))
        self.contentView.addSubview(authIcon)
        authIcon.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(icon)
            make.right.equalTo(icon.snp_left).offset(-15)
            make.size.equalTo(CGSizeMake(44, 18.5))
        }
    }
}