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


class GroupChatSettingHostController: GroupChatSettingController, GroupMemberSelectDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var newLogo: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(GroupChatSettingHostClubAuthCell.self, forCellReuseIdentifier: "auth_status")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "inline_user_select_deletable")
    }
    
    override func createInlineUserSelect() {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "inline_user_select")
        cell.selectionStyle = .None
        inlineUserSelect = InlineUserSelectDeletable()
        inlineUserSelect?.delegate = self
        cell.contentView.addSubview(inlineUserSelect!.view)
        inlineUserSelect?.view.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(cell.contentView)
        })
        inlineUserSelect?.relatedClub = targetClub
        inlineUserSelect?.parentController = self
        inlineUserSelect?.showAddBtn = true
        inlineUserSelect?.showDeleteBtn = true
        inlineUserSelect?.showClubName = targetClub.showNickName
        inlineUsersCell = cell
    }
    
    override func navSettings() {
        // Override this method to enable "release activity" button
        self.navigationItem.title = targetClub.name
        let leftBtn = UIButton()
        leftBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        leftBtn.frame = CGRectMake(0, 0, 9, 15)
        leftBtn.addTarget(self, action: #selector(navLeftBtnPressed), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
    }
    
    override func navLeftBtnPressed() {
        if dirty {
            let requester = ClubRequester.sharedInstance
            requester.updateClubSettings(targetClub, onSuccess: { (json) -> () in
                print("success")
                }, onError: { (code) -> () in
                    print("failure")
            })
        }
        if newLogo != nil {
            let requester = ClubRequester.sharedInstance
            requester.updateClubLogo(targetClub, newLogo: newLogo!, onSuccess: { (json) -> () in
                if let newLogoURL = json?.string where self.newLogo != nil {
                    self.targetClub.logo = newLogoURL
                    // save the uploaded image to the shared cache
                    let logoURL = SFURL(newLogoURL)!
                    let cache = KingfisherManager.sharedManager.cache
                    cache.storeImage(self.newLogo!, forKey: logoURL.absoluteString)
                }
                }, onError: { (code) -> () in
                    
            })
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
//    override func navRightBtnPressed() {
//        if !targetClub.identified {
//            showToast(LS("请先认证您的俱乐部"))
//            return
//        }
//        if !PermissionCheck.sharedInstance.releaseActivity {
//            showToast(LS("请先认证一辆车辆"), onSelf: true)
//            return
//        }
//        let detail = ActivityReleaseController()
//        detail.presentFrom(self)
//    }
    
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
                cell.selectionStyle = .None
                cell.staticLbl.text = LS("俱乐部认证")
                cell.authed = targetClub.identified
                return cell
            case 3..<5:
                // 后面的cell向后移动
                return super.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section))
            case 5..<7:
                let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsCommonCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsCommonCell
                cell.boolSelect.hidden = false
                cell.infoLbl.text = ""
                cell.boolSelect.on = [targetClub.onlyHostCanInvite, targetClub.showMembers][indexPath.row - 5]
                // 0，1，2已经被占用了，这里从3开始编号，此时页面的5个switch按钮的对应关系如下：
                // 0 - 显示本群昵称； 1 - 消息免打扰； 2 - 置顶聊天； 3 - 仅我可以邀请，4 - 对外公布成员信息
                cell.boolSelect.tag = indexPath.row - 2
                cell.staticLbl.text = [LS("仅我可以邀请"), LS("对外公布群成员信息")][indexPath.row - 5]
                cell.boolSelect.addTarget(self, action: #selector(switchBtnPressed(_:)), forControlEvents: .ValueChanged)
                return cell
            case 7:
                // user inlineUserSelectDeletable
                inlineUserSelect?.collectionView?.reloadData()
                return inlineUsersCell
//                let cell = tableView.dequeueReusableCellWithIdentifier("inline_user_select_deletable", forIndexPath: indexPath)
//                cell.selectionStyle = .None
//                if inlineUserSelect == nil {
//                    let select = InlineUserSelectDeletable()
//                    cell.contentView.addSubview(select.view)
//                    select.view.snp_makeConstraints(closure: { (make) -> Void in
//                        make.edges.equalTo(cell.contentView)
//                    })
//                    select.relatedClub = targetClub
//                    select.delegate = self
//                    inlineUserSelect = select
//                    inlineUserSelect?.parentController = self
//                } else {
//                    inlineUserSelect?.collectionView?.reloadData()
//                }
//                inlineUserSelect?.users = Array(targetClub.members)
//                inlineUserSelect?.showAddBtn = true
//                inlineUserSelect?.showDeleteBtn = true
//                return cell
            default:
                return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
            }
        default:
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 {
            if indexPath.row < 7 {
                return 50
            }else {
//                let userCellHeight = UIScreen.mainScreen().bounds.width / 4
//                let userNum = targetClub.members.count + 2
//                if userNum == 0 {
//                    return userCellHeight
//                }
//                let height: CGFloat = userCellHeight * CGFloat((userNum - 1) / 4 + 1)
//                return height
//                
                return InlineUserSelectController.preferedHeightFor(targetClub.members.count, showAddBtn: true, showDeleteBtn: true)
            }
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            // 点击第一个section修改logo
            setLogoPressed()
            break
        case 1:
            let modifier = PersonMineSinglePropertyModifierController()
            switch indexPath.row {
            case 0:
                // 这三行：群聊名称，本群简介和我再本群的昵称可以修改
                modifier.initValue = targetClub.name
            case 1:
                modifier.initValue = targetClub.clubDescription
            case 3:
                modifier.initValue = targetClub.remarkName ?? MainManager.sharedManager.hostUser!.nickName!
            case 2:
                if !targetClub.identified {
                    // If the club is not identified, show auth controller
                    let auth = ClubAuthController()
                    auth.club = targetClub
                    self.navigationController?.pushViewController(auth, animated: true)
                }
                return
//            case 3:
//                if let act = targetClub.recentActivity {
//                    let detail = ActivityDetailController(act: act)
//                    self.navigationController?.pushViewController(detail, animated: true)
//                }
//                return
            default:
                return
            }
            modifier.focusedIndexPath = indexPath
            modifier.delegate = self
            self.navigationController?.pushViewController(modifier, animated: true)
            break
        case 3:
            switch indexPath.row {
            case 0:
                showConfirmToast(LS("清除聊天记录"), message: LS("确定清除聊天记录？"), target: self, onConfirm: #selector(clearChatContent))
            case 1:
                let report = ReportBlacklistViewController(userID: targetClub.ssid, reportType: "club", parent: self)
                self.presentViewController(report, animated: false, completion: nil)
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
    
    func setLogoPressed() {
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
    
    // MARK: - 图像选择的代理
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
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
        case 3:
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
    
    
    /**
     删除用户，注意一次只能删除一个用户
     
     - parameter user: 被删除的一个用户
     */
    override func inlineUserSelectShouldDeleteUser(user: User) {
        self.lp_start()
        ClubRequester.sharedInstance.updateClubMembers(self.targetClub.ssidString, members: [user.ssidString], opType: "delete", onSuccess: { (_) in
            self.targetClub.removeMember(user)
            self.targetClub.memberNum -= 1
            self.inlineUserSelect?.users = self.targetClub.members
            self.tableView.reloadData()
            NSNotificationCenter.defaultCenter().postNotificationName(kMessageClubMemberChangeNotification, object: self, userInfo: [kMessageClubKey: self.targetClub])
            self.showToast(LS("删除成功"))
            self.lp_stop()
            }) { (code) in
                self.showToast(LS("删除失败"))
                self.lp_stop()
        }
    }
    
    override func inlineUserSelectNeedAddMembers() {
        let select = FFSelectController(maxSelectNum: kMaxSelectUserNum, preSelectedUsers: targetClub.members, preSelect: false, forced: true)
        select.delegate = self
        let wrapper = BlackBarNavigationController(rootViewController: select)
        self.presentViewController(wrapper, animated: true, completion: nil)
    }
    
    // MARK: 退出群聊
    override func deleteAndQuitConfirm() {
        let select = GroupMemberSelectController(club: targetClub)
        select.delegate = self
        select.presentFrom(self)
    }
    
    /**
     退出群了以后选择新的接替的新群主后会调用这个函数
     */
    func groupMemberSelectControllerDidSelectUser(user: User) {
        let waiter = dispatch_semaphore_create(0)
        var success = false
        ClubRequester.sharedInstance.clubQuit(targetClub.ssidString, newHostID: user.ssidString, onSuccess: { (json) -> () in
            success = true
            dispatch_semaphore_signal(waiter)
            }) { (code) -> () in
                dispatch_semaphore_signal(waiter)
        }
        dispatch_semaphore_wait(waiter, DISPATCH_TIME_FOREVER)
        if success {
            targetClub.attended = false
            targetClub.mine = true
            MessageManager.defaultManager.deleteAndQuit(targetClub)
            let nav = self.navigationController
            let n = nav!.viewControllers.count
            if let _ = nav?.viewControllers[n-1] as? ChatRoomController {
                nav?.pushViewController(nav!.viewControllers[n-2], animated: true)
            } else {
                nav?.popViewControllerAnimated(true)
            }
            
        } else {
            showToast(LS("删除失败"))
        }
    }
    
    func groupMemberSelectControllerDidCancel() {
        // Do nothing
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