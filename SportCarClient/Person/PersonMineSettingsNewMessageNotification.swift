//
//  PersonMineSettingsNewMessageNotification.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/11.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class PersonMineSettingsNewsMessageNotificationController: UITableViewController {
    
    var settings: [Bool] = [true, true, true]
    var dirty: Bool = false
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        navSettings()
        //
        tableView.registerClass(PrivateChatSettingsCommonCell.self, forCellReuseIdentifier: PrivateChatSettingsCommonCell.reuseIdentifier)
        tableView.separatorStyle = .None
        tableView.rowHeight = 50
        //
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dataSourceDidFinishUpdating:", name: PMUpdateFinishedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dataSourceUpateError:", name: PMUpdateErrorNotification, object: nil)
        //
        let dataSource = PersonMineSettingsDataSource.sharedDataSource
        settings[0] = dataSource.newMessageNotificationAccept
        settings[1] = dataSource.newMessageNotificationSound
        settings[2] = dataSource.newMessageNotificationShake
    }
    
    func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = LS("新消息通知")
        //
        let navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        navLeftBtn.frame = CGRectMake(0, 0, 9, 15)
        navLeftBtn.addTarget(self, action: "navLeftBtnPressed", forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        //
        let rightItem = UIBarButtonItem(title: LS("确定"), style: .Done, target: self, action: "navRightBtnPressed")
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func navLeftBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func navRightBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
        //
        if dirty {
            let dataSource = PersonMineSettingsDataSource.sharedDataSource
            dataSource.newMessageNotificationAccept = settings[0]
            dataSource.newMessageNotificationSound = settings[1]
            dataSource.newMessageNotificationShake = settings[2]
            dataSource.sync()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsCommonCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsCommonCell
        cell.boolSelect.hidden = false
        cell.staticLbl.text = [LS("接受通知"), LS("声音"), LS("振动")][indexPath.row]
        cell.boolSelect.addTarget(self, action: "switchBtnPressed:", forControlEvents: .ValueChanged)
        cell.boolSelect.tag = indexPath.row
        cell.boolSelect.on = settings[indexPath.row]
        return cell
    }
    
    func switchBtnPressed(sender: UISwitch) {
        dirty = true
        settings[sender.tag] = sender.on
    }
    
    func dataSourceDidFinishUpdating(notif: Notification) {
        tableView.reloadData()
    }
    
    func dataSourceUpateError(notif: Notification) {
    }
}
