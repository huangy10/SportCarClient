//
//  GroupSettings.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/8.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire

let kGroupChatSettingSectionTitles = ["", "信息", "通知", "聊天"]

class GroupChatSettingController: UIViewController, PersonMineSinglePropertyModifierDelegate, InlineUserSelectDelegate, FFSelectDelegate, LoadingProtocol, UITableViewDataSource, UITableViewDelegate, RequestManageMixin {
    internal var delayWorkItem: DispatchWorkItem?
    var onGoingRequest: [String : Request] = [:]
    
    var tableView: UITableView!
    var targetClub: Club!
    // 是否设置发生了更改
    var dirty: Bool = false
    
    // 活动描述：
    var activityDescription: String?
    
    var inlineUserSelect: InlineUserSelectController?
    var deleteQuitBtn: UIButton?
    var startChatBtn: UIButton?
    
    var inlineUsersCell: UITableViewCell!
    
    deinit {
        clearAllRequest()
    }
    
    init(targetClub: Club) {
        super.init(nibName: nil, bundle: nil)
        self.targetClub = targetClub
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        tableView = UITableView(frame: view.bounds, style: .plain)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(PrivateChatSettingsAvatarCell.self, forCellReuseIdentifier: PrivateChatSettingsAvatarCell.reuseIdentifier)
        tableView.register(PrivateChatSettingsCommonCell.self, forCellReuseIdentifier: PrivateChatSettingsCommonCell.reuseIdentifier)
        tableView.register(PrivateChatSettingsHeader.self, forHeaderFooterViewReuseIdentifier: "reuse_header")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "inline_user_select")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "quit")
        
        tableView.showsVerticalScrollIndicator = false
        
        let requester = ClubRequester.sharedInstance
        lp_start()
        requester.getClubInfo(targetClub.ssidString, onSuccess: { (json) -> () in
            self.lp_stop()
            _ = try! self.targetClub.loadDataFromJSON(json!, detailLevel: 0)
            self.targetClub.members.removeAll()
            for data in json!["club"]["members"].arrayValue {
                // 添加成员
                let user: User = try! MainManager.sharedManager.getOrCreate(data)
                if user.ssid == self.targetClub.founderUser!.ssid {
                    self.targetClub.members.insert(user, at: 0)
                } else {
                    self.targetClub.members.append(user)
                }
                
                if user.isHost {
                    self.targetClub.remarkName = user.clubNickName
                }
            }

            self.tableView.reloadData()
            self.inlineUserSelect?.users = self.targetClub.members
            self.inlineUserSelect?.collectionView?.reloadData()
            
            }) { (code) -> () in
                self.lp_stop()
        }.registerForRequestManage(self)
        createInlineUserSelect()
    }
    
    func createInlineUserSelect() {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "inline_user_select")
        cell.selectionStyle = .none
        inlineUserSelect = InlineUserSelectController()
        inlineUserSelect?.delegate = self
        cell.contentView.addSubview(inlineUserSelect!.view)
        inlineUserSelect?.view.snp.makeConstraints({ (make) in
            make.edges.equalTo(cell.contentView)
        })
        inlineUserSelect?.relatedClub = targetClub
        inlineUserSelect?.parentController = self
        inlineUserSelect?.showAddBtn = !targetClub.onlyHostCanInvite
        inlineUserSelect?.showClubName = targetClub.showNickName
        inlineUsersCell = cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func navSettings() {
        self.navigationItem.title = targetClub.name
        let leftBtn = UIButton()
        leftBtn.setImage(UIImage(named: "account_header_back_btn"), for: .normal)
        leftBtn.frame = CGRect(x: 0, y: 0, width: 9, height: 15)
        leftBtn.addTarget(self, action: #selector(GroupChatSettingController.navLeftBtnPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        let rightBtn = UIButton()
        let btnText = LS("进入聊天")
        rightBtn.frame = CGRect(x: 0, y: 0, width: btnText.sizeWithFont(UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular), boundingSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 21)).width, height: 21)
        rightBtn.setTitle(btnText, for: .normal)
        rightBtn.titleLabel!.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
        rightBtn.setTitleColor(kHighlightedRedTextColor, for: .normal)
        rightBtn.addTarget(self, action: #selector(GroupChatSettingController.navRightBtnPressed), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
    }
    
    func navRightBtnPressed() {
        startChatBtnPressed()
    }
    
    func navLeftBtnPressed() {
        // push modification to the server
        if dirty {
            let requester = ClubRequester.sharedInstance
            _ = requester.updateClubSettings(targetClub, onSuccess: { (json) -> () in
                // Do nothing when succeed since modification has already taken effects
                }, onError: { (code) -> () in
                    self.showToast(LS("网络访问错误:\(code)"))
            })
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return kGroupChatSettingSectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 1
        case 1:
            return 5
        case 2:
            return 1
        default:
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            return nil
        }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "reuse_header") as! PrivateChatSettingsHeader
        header.titleLbl.text = kGroupChatSettingSectionTitles[section]
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath as NSIndexPath).section {
        case 0:
            return 114
        case 1:
            if (indexPath as NSIndexPath).row < 4 {
                return 50
            }else {
                return InlineUserSelectController.preferedHeightFor(targetClub.members.count, showAddBtn: inlineUserSelect!.showAddBtn, showDeleteBtn: false)
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: PrivateChatSettingsAvatarCell.reuseIdentifier, for: indexPath) as! PrivateChatSettingsAvatarCell
            cell.avatarImage.kf.setImage(with: targetClub.logoURL!, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, _, _) in
                if error == nil {
                    cell.avatarImage.setupForImageViewer(nil, backgroundColor: UIColor.black)
                }
            })
            return cell
        case 1:
            if (indexPath as NSIndexPath).row < 4 {
                let cell = tableView.dequeueReusableCell(withIdentifier: PrivateChatSettingsCommonCell.reuseIdentifier, for: indexPath) as! PrivateChatSettingsCommonCell
                cell.selectionStyle = .none
                switch (indexPath as NSIndexPath).row {
                case 0:
                    cell.staticLbl.text = LS("群聊名称")
                    cell.infoLbl.text = targetClub.name
                    cell.arrowHidden = true
                    cell.boolSelect.isHidden = true
                    
                    break
                case 1:
                    cell.staticLbl.text = LS("本群简介")
                    cell.infoLbl.text = targetClub.clubDescription
                    cell.arrowHidden = true
                    cell.boolSelect.isHidden = true
                    break
                case 2:
                    cell.staticLbl.text = LS("我在本群的昵称")
                    cell.infoLbl.text = targetClub.remarkName ?? MainManager.sharedManager.hostUser!.nickName
                    cell.arrowHidden = false
                    cell.boolSelect.isHidden = true
                    break
                default:
                    cell.staticLbl.text = LS("显示本群昵称")
                    cell.boolSelect.isHidden = false
                    cell.infoLbl.text = ""
                    cell.boolSelect.isOn = targetClub.showNickName 
                    cell.tag = 0
                    cell.boolSelect.addTarget(self, action: #selector(GroupChatSettingController.switchBtnPressed(_:)), for: .valueChanged)
                }
                return cell
            }else {
                inlineUserSelect?.collectionView?.reloadData()
                return inlineUsersCell
            }
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: PrivateChatSettingsCommonCell.reuseIdentifier, for: indexPath) as! PrivateChatSettingsCommonCell
            cell.selectionStyle = .none
            switch (indexPath as NSIndexPath).row {
            case 0:
                cell.staticLbl.text = LS("消息免打扰")
                cell.infoLbl.text = ""
                cell.boolSelect.isHidden = false
                cell.boolSelect.tag = 1
                cell.boolSelect.isOn = targetClub.noDisturbing
                cell.boolSelect.addTarget(self, action: #selector(GroupChatSettingController.switchBtnPressed(_:)), for: .valueChanged)
                break
            case 1:
                cell.staticLbl.text = LS("置顶聊天")
                cell.infoLbl.text = ""
                cell.boolSelect.isHidden = false
                cell.boolSelect.tag = 2
                cell.boolSelect.isOn = targetClub.alwayOnTop
                cell.boolSelect.addTarget(self, action: #selector(GroupChatSettingController.switchBtnPressed(_:)), for: .valueChanged)
                break
            default:
                break
            }
            return cell
        default:
            if (indexPath as NSIndexPath).row < 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: PrivateChatSettingsCommonCell.reuseIdentifier, for: indexPath) as! PrivateChatSettingsCommonCell
                cell.staticLbl.text = [LS("清空聊天内容"), LS("举报")][(indexPath as NSIndexPath).row]
                cell.infoLbl.text = ""
                cell.boolSelect.isHidden = true
                return cell
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "quit", for: indexPath)
                cell.selectionStyle = .none
                if deleteQuitBtn == nil {
                    deleteQuitBtn = cell.contentView.addSubview(UIButton.self)
                        .config(self, selector: #selector(deleteAndQuitBtnPressed), title: LS("删除并退出"), titleColor: kHighlightedRedTextColor, titleSize: 15)
                        .layout({ (make) in
                            make.centerX.equalTo(cell.contentView)
                            make.top.equalTo(cell.contentView).offset(15)
                            make.size.equalTo(CGSize(width: 150, height: 50))
                        })
                    
                }
                if startChatBtn == nil {
                    startChatBtn = cell.contentView.addSubview(UIButton.self)
                        .config(self, selector: #selector(startChatBtnPressed), title: LS("进入聊天"), titleColor: kHighlightedRedTextColor, titleSize: 15)
                        .layout({ (make) in
                            make.centerX.equalTo(cell.contentView)
                            make.top.equalTo(deleteQuitBtn!.snp.bottom)
                            make.size.equalTo(deleteQuitBtn!)
                        })
                }
                return cell
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 2 {
            // 修改本群昵称
            let detail = PersonMineSinglePropertyModifierController()
            detail.initValue = targetClub.remarkName ?? MainManager.sharedManager.hostUser!.nickName
            detail.focusedIndexPath = indexPath
            detail.delegate = self
            self.navigationController?.pushViewController(detail, animated: true)
        } else if (indexPath as NSIndexPath).section == 3 && (indexPath as NSIndexPath).row == 0 {
            showConfirmToast(LS("清除聊天记录"), message: LS("确定清除聊天记录?"), target: self, onConfirm: #selector(clearChatContent))
        } else if (indexPath as NSIndexPath).section == 3 && (indexPath as NSIndexPath).row == 1 {
            // 举报
            let report = ReportBlacklistViewController(userID: targetClub.ssid, reportType: "club", parent: self)
            self.present(report, animated: false, completion: nil)
        }
    }
    
    func didModify(_ newValue: String?, indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 2 {
            dirty = true
            targetClub.remarkName = newValue
            tableView.reloadRows(at: [indexPath], with: .automatic)
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
        self.present(wrapper, animated: true, completion: nil)
    }
    
    func inlineUserSelectShouldDeleteUser(_ user: User) {
        // do nothing
    }
    
    func userSelectCancelled() {
        dismiss(animated: true, completion: nil)
    }
    
    /**
     邀请用户加入群聊
     
     - parameter users: 被邀请的用户list
     */
    func userSelected(_ users: [User]) {
        // send request to the server
        dismiss(animated: true, completion: nil)
        if users.count == 0 { return }
        let userIDs = users.map({return $0.ssidString})
        let originIDs = Array(targetClub.members).map({return $0.ssidString})
        let targets = userIDs.filter({!originIDs.contains($0)})
        let requester = ClubRequester.sharedInstance
        self.lp_start()
        requester.updateClubMembers(targetClub.ssidString, members: targets, opType: "add", onSuccess: { (json) -> () in
            // TODO: 放到请求外面
            self.targetClub.members.append(contentsOf: users)
            self.targetClub.memberNum = Int32(self.targetClub.members.count)
            self.inlineUserSelect?.users = self.targetClub.members
            self.tableView.reloadData()
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: kMessageClubMemberChangeNotification), object: self, userInfo:
                [kMessageClubKey: self.targetClub])
            self.showToast(LS("邀请成功"))
            self.lp_stop()
            }) { (code) -> () in
                self.lp_stop()
                if code == "no permission" {
                    self.showToast(LS("您没有权限进行此项操作"))
                }
        }.registerForRequestManage(self)
    }
    
    func clearChatContent() {
        MessageManager.defaultManager.clearChatHistory(targetClub)
        showToast(LS("清除成功!"))
    }

}

extension GroupChatSettingController {
    
    func switchBtnPressed(_ sender: UISwitch) {
        dirty = true
        switch sender.tag {
        case 0:
            targetClub.showNickName = sender.isOn
            inlineUserSelect?.showClubName = sender.isOn
            break
        case 1:
            targetClub.noDisturbing = sender.isOn
            break
        case 2:
            targetClub.alwayOnTop = sender.isOn
        default:
            break
        }
    }
    
    func deleteAndQuitBtnPressed() {
        showConfirmToast(LS("退出"), message: LS("确定删除并退出？"), target: self, onConfirm: #selector(deleteAndQuitConfirm))
    }
    
    func deleteAndQuitConfirm() {
        // TOOD: re-implement this
        let waiter = DispatchSemaphore(value: 0)
        var success = false
        lp_start()
        _ = ClubRequester.sharedInstance.clubQuit(targetClub.ssidString, newHostID: "", onSuccess: { (json) -> () in
            success = true
            self.lp_stop()
            waiter.signal()
            }) { (code) -> () in
                self.lp_stop()
                waiter.signal()
        }
        _ = waiter.wait(timeout: DispatchTime.distantFuture)
        if success {
            MessageManager.defaultManager.deleteAndQuit(targetClub)
            let nav = self.navigationController!
            let n = nav.viewControllers.count
            if let _ = nav.viewControllers[n-1] as? ChatRoomController {
                _ = self.navigationController?.popToViewController(nav.viewControllers[n-2], animated: true)
            } else {
                _ = self.navigationController?.popViewController(animated: true)
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
        if controller.isKind(of: ChatRoomController.self){
            _ = navigationController?.popViewController(animated: true)
        } else if let temp = controller as? RadarHomeController {
            let chatRoom = ChatRoomController()
            chatRoom.targetClub = targetClub
            chatRoom.chatCreated = false
            temp.navigationController?.pushViewController(chatRoom, animated: true)
        } else {
            let chatRoom = ChatRoomController()
            chatRoom.targetClub = targetClub
            chatRoom.chatCreated = false
            navigationController?.pushViewController(chatRoom, animated: true)
        }
    }
}
