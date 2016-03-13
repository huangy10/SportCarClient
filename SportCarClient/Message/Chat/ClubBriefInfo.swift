//
//  ClubBriefInfo.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/4.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//
//  Brief introduction to a club, mainly for users who are not a member of it.
//

import UIKit
import SwiftyJSON


class ClubBriefInfoController: UITableViewController {
    
    /// The corresponding club
    var targetClub: Club!
    
    var inlineUserSelect: InlineUserSelectController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        tableView.separatorStyle = .None
        tableView.registerClass(PrivateChatSettingsAvatarCell.self, forCellReuseIdentifier: PrivateChatSettingsAvatarCell.reuseIdentifier)
        tableView.registerClass(PrivateChatSettingsCommonCell.self, forCellReuseIdentifier: PrivateChatSettingsCommonCell.reuseIdentifier)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "inline_user_select")
        tableView.registerClass(PrivateChatSettingsHeader.self, forHeaderFooterViewReuseIdentifier: "reuse_header")
        // Request data for the club
        let requester = ChatRequester.requester
        requester.getClubInfo(targetClub.clubID!, onSuccess: { (json) -> () in
            var clubJson: JSON
            if json!["clubID"].stringValue != ""{
                self.targetClub.loadValueFromJSON(json!)
                clubJson = json!
            }else {
                self.targetClub.loadValueFromJSON(json!["club"])
                self.navigationItem.rightBarButtonItem = nil
                clubJson = json!["club"]
            }
            for data in clubJson["members"].arrayValue {
                // 添加成员
                let user = User.objects.getOrCreate(data)
                self.targetClub.addMember(user)
            }
            self.tableView.reloadData()
            }) { (code) -> () in
                print(code)
        }
    }
    
    func navSettings() {
        // Override this method to enable "release activity" button
        self.navigationItem.title = targetClub.name
        let leftBtn = UIButton()
        leftBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        leftBtn.frame = CGRectMake(0, 0, 9, 15)
        leftBtn.addTarget(self, action: "navLeftBtnPressed", forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        let barBtnItem = UIBarButtonItem(title: LS("申请加入"), style: .Plain, target: self, action: "navRightBtnPressed")
        barBtnItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
        self.navigationItem.rightBarButtonItem = barBtnItem
    }
    
    func navRightBtnPressed() {
        
    }
    
    func navLeftBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return targetClub.show_members ? 4 : 3
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsAvatarCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsAvatarCell
            cell.avatarImage.kf_setImageWithURL(SFURL(targetClub.logo_url!)!, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                cell.avatarImage.setupForImageViewer(nil, backgroundColor: UIColor.blackColor())
            })
            return cell
        }
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsCommonCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsCommonCell
            cell.selectionStyle = .None
            cell.boolSelect.hidden = true
            cell.staticLbl.text = LS("群聊名称")
            cell.infoLbl.text = targetClub.name ?? LS("正在获取数据...")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsCommonCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsCommonCell
            cell.selectionStyle = .None
            cell.boolSelect.hidden = true
            cell.staticLbl.text = LS("本群简介")
            cell.infoLbl.text = targetClub.clubDescription ?? LS("正在获取数据...")
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsCommonCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsCommonCell
            cell.selectionStyle = .None
            cell.boolSelect.hidden = true
            cell.staticLbl.text = LS("本群活动")
            cell.infoLbl.text = targetClub.name ?? LS("正在获取数据")
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("inline_user_select", forIndexPath: indexPath)
            cell.selectionStyle = .None
            if inlineUserSelect == nil {
                inlineUserSelect = InlineUserSelectController()
                inlineUserSelect?.users = Array(targetClub.members)
                inlineUserSelect?.showAddBtn = false
                inlineUserSelect?.showDeleteBtn = false
                cell.contentView.addSubview(inlineUserSelect!.view)
                inlineUserSelect?.view.snp_makeConstraints(closure: { (make) -> Void in
                    make.edges.equalTo(cell.contentView).inset(UIEdgeInsetsMake(20, 0, 0, 0))
                })
            }
            inlineUserSelect?.users = Array(targetClub.members)
            inlineUserSelect?.collectionView?.reloadData()
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 114
        }else if indexPath.row < 3{
            return 50
        }else {
            let userNum = targetClub.members.count
            let height: CGFloat = 110 * CGFloat(userNum / 4 + 1)
            return height + 20
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
        header.titleLbl.text = LS("信息")
        return header
    }

}
