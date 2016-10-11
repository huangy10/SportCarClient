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
        tableView.register(PrivateChatSettingsCommonCell.self, forCellReuseIdentifier: PrivateChatSettingsCommonCell.reuseIdentifier)
        tableView.separatorStyle = .none
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
        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), for: .normal)
        navLeftBtn.frame = CGRect(x: 0, y: 0, width: 9, height: 15)
        navLeftBtn.addTarget(self, action: #selector(PersonMineSettingsInvitationController.navLeftBtnPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        //
        let rightItem = UIBarButtonItem(title: LS("确定"), style: .done, target: self, action: #selector(PersonMineSettingsInvitationController.navRightBtnPressed))
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular), NSForegroundColorAttributeName: kHighlightedRedTextColor], for: .normal)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func navLeftBtnPressed() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func navRightBtnPressed() {
        _ = self.navigationController?.popViewController(animated: true)
        if dirty {
            let dataSource = PersonMineSettingsDataSource.sharedDataSource
            dataSource.acceptInvitation = selectedType
            dataSource.sync()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PrivateChatSettingsCommonCell.reuseIdentifier, for: indexPath) as! PrivateChatSettingsCommonCell
        cell.useAsMark = true
        cell.staticLbl.text = kPersonMineSettingsInvitationStaticLabelString[(indexPath as NSIndexPath).row]
        if cell.staticLbl.text == kPersonMineSettingsAcceptInvitationMapping[selectedType] {
            cell.markIcon.isHidden = false
        }else {
            cell.markIcon.isHidden = true
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedType = kPersonMineSettingsAcceptInvitationList[(indexPath as NSIndexPath).row]
        dirty = true
        tableView.reloadData()
    }
}
