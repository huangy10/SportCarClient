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
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        navSettings()
        //
        tableView.register(PrivateChatSettingsCommonCell.self, forCellReuseIdentifier: PrivateChatSettingsCommonCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.rowHeight = 50
        //
        NotificationCenter.default.addObserver(self, selector: #selector(PersonMineSettingsNewsMessageNotificationController.dataSourceDidFinishUpdating(_:)), name: NSNotification.Name(rawValue: PMUpdateFinishedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PersonMineSettingsNewsMessageNotificationController.dataSourceUpateError(_:)), name: NSNotification.Name(rawValue: PMUpdateErrorNotification), object: nil)
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
        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), for: .normal)
        navLeftBtn.frame = CGRect(x: 0, y: 0, width: 9, height: 15)
        navLeftBtn.addTarget(self, action: #selector(PersonMineSettingsNewsMessageNotificationController.navLeftBtnPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        //
        let rightItem = UIBarButtonItem(title: LS("确定"), style: .done, target: self, action: #selector(PersonMineSettingsNewsMessageNotificationController.navRightBtnPressed))
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], for: .normal)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func navLeftBtnPressed() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func navRightBtnPressed() {
        _ = self.navigationController?.popViewController(animated: true)
        //
        if dirty {
            let dataSource = PersonMineSettingsDataSource.sharedDataSource
            dataSource.newMessageNotificationAccept = settings[0]
            dataSource.newMessageNotificationSound = settings[1]
            dataSource.newMessageNotificationShake = settings[2]
            dataSource.sync()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 暂时取消对『振动』选项的设置
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PrivateChatSettingsCommonCell.reuseIdentifier, for: indexPath) as! PrivateChatSettingsCommonCell
        cell.boolSelect.isHidden = false
        cell.staticLbl.text = [LS("接受通知"), LS("声音"), LS("振动")][(indexPath as NSIndexPath).row]
        cell.boolSelect.addTarget(self, action: #selector(PersonMineSettingsNewsMessageNotificationController.switchBtnPressed(_:)), for: .valueChanged)
        cell.boolSelect.tag = (indexPath as NSIndexPath).row
        cell.boolSelect.isOn = settings[(indexPath as NSIndexPath).row]
        return cell
    }
    
    func switchBtnPressed(_ sender: UISwitch) {
        dirty = true
        settings[sender.tag] = sender.isOn
    }
    
    func dataSourceDidFinishUpdating(_ notif: Notification) {
        tableView.reloadData()
    }
    
    func dataSourceUpateError(_ notif: Notification) {
    }
}
