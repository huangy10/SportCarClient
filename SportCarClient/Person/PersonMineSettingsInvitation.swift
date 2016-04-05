//
//  PersonMineSettingsInvitation.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/11.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

let kPersonMineSettingsInvitationStaticLabelString = [LS("所有人"), LS("互相关注"), LS("我关注的"), LS("关注我的"), LS("需通过验证"), LS("不允许")]

class PersonMineSettingsInvitationController: UITableViewController {
    
    var selectedType: String!
    var dirty: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        navSettings()
        //
        tableView.registerClass(PrivateChatSettingsCommonCell.self, forCellReuseIdentifier: PrivateChatSettingsCommonCell.reuseIdentifier)
        tableView.separatorStyle = .None
        tableView.rowHeight = 50
        //
        let dataSource = PersonMineSettingsDataSource.sharedDataSource
        selectedType = dataSource.acceptInvitation
    }
    
    func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = LS("新消息通知")
        //
        let navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        navLeftBtn.frame = CGRectMake(0, 0, 9, 15)
        navLeftBtn.addTarget(self, action: #selector(PersonMineSettingsInvitationController.navLeftBtnPressed), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        //
        let rightItem = UIBarButtonItem(title: LS("确定"), style: .Done, target: self, action: #selector(PersonMineSettingsInvitationController.navRightBtnPressed))
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func navLeftBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func navRightBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
        if dirty {
            let dataSource = PersonMineSettingsDataSource.sharedDataSource
            dataSource.acceptInvitation = selectedType
            dataSource.sync()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsCommonCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsCommonCell
        cell.useAsMark = true
        cell.staticLbl.text = kPersonMineSettingsInvitationStaticLabelString[indexPath.row]
        if cell.staticLbl.text == kPersonMineSettingsAcceptInvitationMapping[selectedType] {
            cell.markIcon.hidden = false
        }else {
            cell.markIcon.hidden = true
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedType = kPersonMineSettingsAcceptInvitationList[indexPath.row]
        dirty = true
        tableView.reloadData()
    }
}
