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
    var inlineUserSelectCell: UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        configureInlineUserSelect()
        tableView.separatorStyle = .none
        SSPropertyCell.registerTableView(tableView)
        SSAvatarCell.registerTableView(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "inline_user_select")
        tableView.register(PrivateChatSettingsHeader.self, forHeaderFooterViewReuseIdentifier: "reuse_header")
        // Request data for the club
        let requester = ClubRequester.sharedInstance
        _ = requester.getClubInfo(targetClub.ssidString, onSuccess: { (json) -> () in
            var clubJson: JSON
            if json!["id"].exists() {
                _ = try! self.targetClub.loadDataFromJSON(json!)
                clubJson = json!
                let barBtnItem = UIBarButtonItem(title: LS("申请加入"), style: .plain, target: self, action: #selector(ClubBriefInfoController.navRightBtnPressed))
                barBtnItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular), NSForegroundColorAttributeName: kHighlightedRedTextColor], for: .normal)
                self.navigationItem.rightBarButtonItem = barBtnItem
            }else {
                _ = try! self.targetClub.loadDataFromJSON(json!["club"])
                self.navigationItem.rightBarButtonItem = nil
                clubJson = json!["club"]
            }
            self.targetClub.members.removeAll()
            for data in clubJson["members"].arrayValue {
                // 添加成员
                let user: User = try! MainManager.sharedManager.getOrCreate(data)
                self.targetClub.members.append(user)
            }
            self.tableView.reloadData()
            }) { (code) -> () in
                
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func configureInlineUserSelect() {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "inline_user_select")
        cell.selectionStyle = .none
        inlineUserSelect = InlineUserSelectController()
        cell.contentView.addSubview(inlineUserSelect!.view)
        inlineUserSelect?.view.snp.makeConstraints({ (make) in
            make.edges.equalTo(cell.contentView)
        })
        inlineUserSelect?.relatedClub = targetClub
        inlineUserSelect?.parentController = self
        inlineUserSelect?.showAddBtn = false
        inlineUserSelectCell = cell
    }
    
    func navSettings() {
        // Override this method to enable "release activity" button
        self.navigationItem.title = targetClub.name
        let leftBtn = UIButton()
        leftBtn.setImage(UIImage(named: "account_header_back_btn"), for: .normal)
        leftBtn.frame = CGRect(x: 0, y: 0, width: 9, height: 15)
        leftBtn.addTarget(self, action: #selector(ClubBriefInfoController.navLeftBtnPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
    }
    
    func navRightBtnPressed() {
        _ = ClubRequester.sharedInstance.applyForAClub(targetClub.ssidString, onSuccess: { (json) in
            self.showToast(LS("申请已发送"))
            }) { (code) in
                guard let code = code else {
                    self.showToast(LS("申请发送失败"))
                    return
                }
                switch code {
                case "already join":
                    self.showToast(LS("已经是这个俱乐部的成员"))
                case "already applied":
                    self.showToast(LS("已申请过这个俱乐部"))
                default:
                    self.showToast(LS("申请发送失败"))
                }
        }
    }
    
    func navLeftBtnPressed() {
        _ = self.navigationController?.popViewController(animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return targetClub.showMembers ? 3 : 2
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            return tableView.ss_reuseablePropertyCell(SSAvatarCell.self, forIndexPath: indexPath)
                .setData(targetClub.logoURL!, showArrow: false, zoomable: true)
        }
        switch (indexPath as NSIndexPath).row {
        case 0:
            return tableView.ss_reuseablePropertyCell(SSPropertyCell.self, forIndexPath: indexPath)
                .setData(LS("群聊名称"), propertyValue: targetClub.name ?? LS("正在获取数据..."), editable: false)
        case 1:
            return tableView.ss_reuseablePropertyCell(SSPropertyCell.self, forIndexPath: indexPath)
                .setData(LS("本群简介"), propertyValue: targetClub.clubDescription ?? LS("正在获取数据..."), editable: false)
        default:
//            let cell = tableView.dequeueReusableCellWithIdentifier("inline_user_select", forIndexPath: indexPath)
//            cell.selectionStyle = .None
//            if inlineUserSelect == nil {
//                inlineUserSelect = InlineUserSelectController()
//                inlineUserSelect?.users = Array(targetClub.members)
//                inlineUserSelect?.showAddBtn = false
//                inlineUserSelect?.showDeleteBtn = false
//                inlineUserSelect?.parentController = self
//                cell.contentView.addSubview(inlineUserSelect!.view)
//                inlineUserSelect?.view.snp.makeConstraints(closure: { (make) -> Void in
//                    make.edges.equalTo(cell.contentView).inset(UIEdgeInsetsMake(20, 0, 0, 0))
//                })
//            }
            inlineUserSelect?.users = Array(targetClub.members)
            inlineUserSelect?.collectionView?.reloadData()
            return inlineUserSelectCell!
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return 114
        }else if (indexPath as NSIndexPath).row < 2 {
            return 50
        }else {
            let userNum = targetClub.members.count
            let height: CGFloat = 110 * CGFloat(userNum / 4 + 1)
            return height + 20
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else {
            return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            return nil
        }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "reuse_header") as! PrivateChatSettingsHeader
        header.titleLbl.text = LS("信息")
        return header
    }

}
