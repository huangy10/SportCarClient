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

class GroupChatController: UITableViewController {
    
    var targetClub: Club!
    //
    var clubJoining: ClubJoining!
    // 活动描述：
    var activityDescription: String?
    
    var inlineUserSelect: InlineUserSelectController?
    
    init(targetUser: Club) {
        super.init(style: .Plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .None
        
        tableView.registerClass(PrivateChatSettingsAvatarCell.self, forCellReuseIdentifier: PrivateChatSettingsAvatarCell.reuseIdentifier)
        tableView.registerClass(PrivateChatSettingsCommonCell.self, forCellReuseIdentifier: PrivateChatSettingsCommonCell.reuseIdentifier)
        tableView.registerClass(PrivateChatSettingsHeader.self, forHeaderFooterViewReuseIdentifier: "reuse_header")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "inline_user_select")
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
                let height: CGFloat = 110 * CGFloat(userNum / 4)
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
            cell.avatarBtn.kf_setImageWithURL(SFURL(targetClub.logo_url!)!, forState: .Normal)
            return cell
        case 1:
            if indexPath.row < 5 {
                let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsCommonCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsCommonCell
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
                    cell.infoLbl.text = clubJoining.nickName
                    cell.boolSelect.hidden = true
                    break
                default:
                    cell.staticLbl.text = LS("显示本群昵称")
                    cell.boolSelect.hidden = false
                    cell.infoLbl.text = ""
                    cell.boolSelect.on = clubJoining.showNickName
                    cell.tag = 0
                    cell.boolSelect.addTarget(self, action: "switchBtnPressed:", forControlEvents: .ValueChanged)
                }
                return cell
            }else {
                let cell = tableView.dequeueReusableCellWithIdentifier("inline_user_select", forIndexPath: indexPath)
                if inlineUserSelect == nil {
                    inlineUserSelect = InlineUserSelectController()
                    inlineUserSelect?.users = targetClub.members.map({ (user) -> User in
                        return user
                    })
                    cell.contentView.addSubview(inlineUserSelect!.view)
                    inlineUserSelect?.view.snp_makeConstraints(closure: { (make) -> Void in
                        make.edges.equalTo(cell.contentView)
                    })
                }
                return cell
            }
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsCommonCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsCommonCell
            switch indexPath.row {
            case 0:
                cell.staticLbl.text = LS("消息免打扰")
                cell.infoLbl.text = ""
                cell.boolSelect.hidden = false
                cell.boolSelect.tag = 1
                cell.boolSelect.on = clubJoining.noDisturbing
                cell.boolSelect.addTarget(self, action: "switchBtnPressed:", forControlEvents: .ValueChanged)
                break
            case 1:
                cell.staticLbl.text = LS("置顶聊天")
                cell.infoLbl.text = ""
                cell.boolSelect.hidden = false
                cell.boolSelect.tag = 2
                cell.boolSelect.on = clubJoining.alwaysOnTop
                cell.boolSelect.addTarget(self, action: "switchBtnPressed:", forControlEvents: .ValueChanged)
                break
            default:
                break
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsCommonCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsCommonCell
            cell.staticLbl.text = [LS("查找聊天内容"), LS("清空聊天内容"), LS("举报")][indexPath.row]
            cell.infoLbl.text = ""
            cell.boolSelect.hidden = false
            return cell
        }
    }
}

extension GroupChatController {
    func switchBtnPressed(sender: UISwitch) {
        switch sender.tag {
        case 0:
            clubJoining.showNickName = sender.on
            break
        case 1:
            clubJoining.noDisturbing = sender.on
            break
        case 2:
            clubJoining.alwaysOnTop = sender.on
        default:
            break
        }
    }
}
