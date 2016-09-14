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

class GroupChatSettingController: UITableViewController, PersonMineSinglePropertyModifierDelegate, InlineUserSelectDelegate, FFSelectDelegate, LoadingProtocol {
    
    var delayTask: dispatch_block_t?
    
    var targetClub: Club!
    // 是否设置发生了更改
    var dirty: Bool = false
    
    // 活动描述：
    var activityDescription: String?
    
    var inlineUserSelect: InlineUserSelectController?
    var deleteQuitBtn: UIButton?
    var startChatBtn: UIButton?
    
    var inlineUsersCell: UITableViewCell!
    
    init(targetClub: Club) {
        super.init(style: .Plain)
        self.targetClub = targetClub
    }
    
//    init(rosterItem: RosterItem) {
//        super.init(style: .Plain)
//        self.rosterItem = rosterItem
//        switch rosterItem.data! {
//        case .CLUB(let club):
//            targetClub = club
//        default:
//            break
//        }
//    }

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
        
        tableView.showsVerticalScrollIndicator = false
        
        let requester = ClubRequester.sharedInstance
        lp_start()
        requester.getClubInfo(targetClub.ssidString, onSuccess: { (json) -> () in
            self.lp_stop()
            try! self.targetClub.loadDataFromJSON(json!, detailLevel: 0)
            self.targetClub.members.removeAll()
            for data in json!["club"]["members"].arrayValue {
                // 添加成员
                let user: User = try! MainManager.sharedManager.getOrCreate(data)
                self.targetClub.members.append(user)
                
                if user.isHost {
                    self.targetClub.remarkName = user.clubNickName
                }
            }
//            let actJson = json!["recent_act"]
//            if actJson.exists() {
//                self.targetClub.recentActivity = try! MainManager.sharedManager.getOrCreate(actJson) as Activity
//            }
            self.tableView.reloadData()
            self.inlineUserSelect?.users = self.targetClub.members
            self.inlineUserSelect?.collectionView?.reloadData()
            
            }) { (code) -> () in
                self.lp_stop()
        }
        createInlineUserSelect()
    }
    
    func createInlineUserSelect() {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "inline_user_select")
        cell.selectionStyle = .None
        inlineUserSelect = InlineUserSelectController()
        inlineUserSelect?.delegate = self
        cell.contentView.addSubview(inlineUserSelect!.view)
        inlineUserSelect?.view.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(cell.contentView)
        })
        inlineUserSelect?.relatedClub = targetClub
        inlineUserSelect?.parentController = self
        inlineUserSelect?.showAddBtn = !targetClub.onlyHostCanInvite
        inlineUserSelect?.showClubName = targetClub.showNickName
        inlineUsersCell = cell
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func navSettings() {
        self.navigationItem.title = targetClub.name
        let leftBtn = UIButton()
        leftBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        leftBtn.frame = CGRectMake(0, 0, 9, 15)
        leftBtn.addTarget(self, action: #selector(GroupChatSettingController.navLeftBtnPressed), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        let rightBtn = UIButton()
        let btnText = LS("进入聊天")
        rightBtn.frame = CGRectMake(0, 0, btnText.sizeWithFont(UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), boundingSize: CGSizeMake(CGFloat.max, 21)).width, 21)
        rightBtn.setTitle(btnText, forState: .Normal)
        rightBtn.titleLabel!.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        rightBtn.setTitleColor(kHighlightedRedTextColor, forState: .Normal)
        rightBtn.addTarget(self, action: #selector(GroupChatSettingController.navRightBtnPressed), forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
    }
    
    func navRightBtnPressed() {
        startChatBtnPressed()
    }
    
    func navLeftBtnPressed() {
        // push modification to the server
        if dirty {
            let requester = ClubRequester.sharedInstance
            requester.updateClubSettings(targetClub, onSuccess: { (json) -> () in
                // Do nothing when succeed since modification has already taken effects
                }, onError: { (code) -> () in
                    self.showToast(LS("网络访问错误:\(code)"))
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
            return 5
        case 2:
            return 2
        default:
            return 3
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
            if indexPath.row < 4 {
                return 50
            }else {
//                let userCellHeight = UIScreen.mainScreen().bounds.width / 4
//                let userNum = targetClub.members.count + (inlineUserSelect!.showAddBtn ? 1 : 0)
//                if userNum == 0 {
//                    return userCellHeight
//                }
//                let height: CGFloat = userCellHeight * CGFloat((userNum - 1) / 4 + 1)
//                return height
                
                return InlineUserSelectController.preferedHeightFor(targetClub.members.count, showAddBtn: inlineUserSelect!.showAddBtn, showDeleteBtn: false)
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
            if indexPath.row < 4 {
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
                    cell.boolSelect.addTarget(self, action: #selector(GroupChatSettingController.switchBtnPressed(_:)), forControlEvents: .ValueChanged)
                }
                return cell
            }else {
                inlineUserSelect?.collectionView?.reloadData()
                return inlineUsersCell
//                let cell = tableView.dequeueReusableCellWithIdentifier("inline_user_select", forIndexPath: indexPath)
//                cell.selectionStyle = .None
//                if inlineUserSelect == nil {
//                    inlineUserSelect = InlineUserSelectController()
//                    inlineUserSelect?.delegate = self
//                    cell.contentView.addSubview(inlineUserSelect!.view)
//                    inlineUserSelect?.view.snp_makeConstraints(closure: { (make) -> Void in
//                        make.edges.equalTo(cell.contentView)
//                    })
//                    inlineUserSelect?.relatedClub = targetClub
//                    inlineUserSelect?.parentController = self
//                }
//                inlineUserSelect?.users = Array(targetClub.members)
//                inlineUserSelect?.showAddBtn = !targetClub.onlyHostCanInvite
//                inlineUserSelect?.collectionView?.reloadData()
//                return cell
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
                cell.boolSelect.addTarget(self, action: #selector(GroupChatSettingController.switchBtnPressed(_:)), forControlEvents: .ValueChanged)
                break
            case 1:
                cell.staticLbl.text = LS("置顶聊天")
                cell.infoLbl.text = ""
                cell.boolSelect.hidden = false
                cell.boolSelect.tag = 2
                cell.boolSelect.on = targetClub.alwayOnTop
                cell.boolSelect.addTarget(self, action: #selector(GroupChatSettingController.switchBtnPressed(_:)), forControlEvents: .ValueChanged)
                break
            default:
                break
            }
            return cell
        default:
            if indexPath.row < 2 {
                let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsCommonCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsCommonCell
                cell.staticLbl.text = [LS("清空聊天内容"), LS("举报")][indexPath.row]
                cell.infoLbl.text = ""
                cell.boolSelect.hidden = true
                return cell
            }else {
                let cell = tableView.dequeueReusableCellWithIdentifier("quit", forIndexPath: indexPath)
                cell.selectionStyle = .None
                if deleteQuitBtn == nil {
//                    deleteQuitBtn = UIButton()
//                    deleteQuitBtn?.setImage(UIImage(named: "delete_and_quit_btn"), forState: .Normal)
//                    deleteQuitBtn?.addTarget(self, action: #selector(GroupChatSettingController.deleteAndQuitBtnPressed), forControlEvents: .TouchUpInside)
//                    cell.contentView.addSubview(deleteQuitBtn!)
//                    deleteQuitBtn?.snp_makeConstraints(closure: { (make) -> Void in
//                        make.centerX.equalTo(cell.contentView)
//                        make.top.equalTo(cell.contentView).offset(15)
//                        make.size.equalTo(CGSizeMake(150, 50))
//                    })
                    deleteQuitBtn = cell.contentView.addSubview(UIButton)
                        .config(self, selector: #selector(deleteAndQuitBtnPressed), title: LS("删除并退出"), titleColor: kHighlightedRedTextColor, titleSize: 15)
                        .layout({ (make) in
                            make.centerX.equalTo(cell.contentView)
                            make.top.equalTo(cell.contentView).offset(15)
                            make.size.equalTo(CGSizeMake(150, 50))
                        })
                    
                }
                if startChatBtn == nil {
                    startChatBtn = cell.contentView.addSubview(UIButton)
                        .config(self, selector: #selector(startChatBtnPressed), title: LS("进入聊天"), titleColor: kHighlightedRedTextColor, titleSize: 15)
                        .layout({ (make) in
                            make.centerX.equalTo(cell.contentView)
                            make.top.equalTo(deleteQuitBtn!.snp_bottom)
                            make.size.equalTo(deleteQuitBtn!)
                        })
                }
                return cell
            }
            
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 2 {
            // 修改本群昵称
            let detail = PersonMineSinglePropertyModifierController()
            detail.initValue = targetClub.remarkName ?? MainManager.sharedManager.hostUser!.nickName
            detail.focusedIndexPath = indexPath
            detail.delegate = self
            self.navigationController?.pushViewController(detail, animated: true)
        } else if indexPath.section == 3 && indexPath.row == 0 {
            showConfirmToast(LS("清除聊天记录"), message: LS("确定清除聊天记录?"), target: self, onConfirm: #selector(clearChatContent))
        } else if indexPath.section == 3 && indexPath.row == 1 {
            // 举报
            let report = ReportBlacklistViewController(userID: targetClub.ssid, reportType: "club", parent: self)
            self.presentViewController(report, animated: false, completion: nil)
        } else if indexPath.section == 1 && indexPath.row == 2 {
//            if let act = targetClub.recentActivity {
//                let detail = ActivityDetailController(act: act)
//                self.navigationController?.pushViewController(detail, animated: true)
//            }
        }
    }
    
    func didModify(newValue: String?, indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 2 {
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
        let select = FFSelectController(maxSelectNum: kMaxSelectUserNum, preSelectedUsers: targetClub.members, preSelect: false, forced: true)
        select.delegate = self
        let wrapper = BlackBarNavigationController(rootViewController: select)
        self.presentViewController(wrapper, animated: true, completion: nil)
    }
    
    func inlineUserSelectShouldDeleteUser(user: User) {
        // do nothing
    }
    
    func userSelectCancelled() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     邀请用户加入群聊
     
     - parameter users: 被邀请的用户list
     */
    func userSelected(users: [User]) {
        // send request to the server
        dismissViewControllerAnimated(true, completion: nil)
        if users.count == 0 { return }
        let userIDs = users.map({return $0.ssidString})
        let originIDs = Array(targetClub.members).map({return $0.ssidString})
        let targets = userIDs.filter({!originIDs.contains($0)})
        let requester = ClubRequester.sharedInstance
        self.lp_start()
        requester.updateClubMembers(targetClub.ssidString, members: targets, opType: "add", onSuccess: { (json) -> () in
            // TODO: 放到请求外面
            self.targetClub.members.appendContentsOf(users)
            self.targetClub.memberNum = Int32(self.targetClub.members.count)
            self.inlineUserSelect?.users = self.targetClub.members
            self.tableView.reloadData()
            NSNotificationCenter.defaultCenter().postNotificationName(kMessageClubMemberChangeNotification, object: self, userInfo:
                [kMessageClubKey: self.targetClub])
            self.showToast(LS("邀请成功"))
            self.lp_stop()
            }) { (code) -> () in
                self.lp_stop()
                if code == "no permission" {
                    self.showToast(LS("您没有权限进行此项操作"))
                }
        }
    }
    
    func clearChatContent() {
//        hideToast()
        MessageManager.defaultManager.clearChatHistory(targetClub)
    }

}

extension GroupChatSettingController {
    
    func switchBtnPressed(sender: UISwitch) {
        dirty = true
        switch sender.tag {
        case 0:
            targetClub.showNickName = sender.on
            inlineUserSelect?.showClubName = sender.on
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
        showConfirmToast(LS("退出"), message: LS("确定删除并退出？"), target: self, onConfirm: #selector(deleteAndQuitConfirm))
    }
    
    func deleteAndQuitConfirm() {
        // TOOD: re-implement this
        let waiter = dispatch_semaphore_create(0)
        var success = false
        lp_start()
        ClubRequester.sharedInstance.clubQuit(targetClub.ssidString, newHostID: "", onSuccess: { (json) -> () in
            success = true
            self.lp_stop()
            dispatch_semaphore_signal(waiter)
            }) { (code) -> () in
                self.lp_stop()
                dispatch_semaphore_signal(waiter)
        }
        dispatch_semaphore_wait(waiter, DISPATCH_TIME_FOREVER)
        if success {
            MessageManager.defaultManager.deleteAndQuit(targetClub)
            let nav = self.navigationController!
            let n = nav.viewControllers.count
            if let _ = nav.viewControllers[n-1] as? ChatRoomController {
                self.navigationController?.popToViewController(nav.viewControllers[n-2], animated: true)
            } else {
                self.navigationController?.popViewControllerAnimated(true)
            }
        } else {
            showToast(LS("删除失败"), onSelf: true)
        }
    }
    
    func startChatBtnPressed() {
        guard let controllers = self.navigationController?.viewControllers else {
            return
        }
        let controller = controllers[controllers.count - 2]
        if controller.isKindOfClass(ChatRoomController.self){
            navigationController?.popViewControllerAnimated(true)
        } else if let temp = controller as? RadarHomeController {
            let chatRoom = ChatRoomController()
            chatRoom.targetClub = targetClub
            chatRoom.chatCreated = false
            temp.navigationController?.pushViewController(chatRoom, animated: true)
        }
    }
}
