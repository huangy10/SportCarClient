//
//  PersonMineSettings.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/11.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//
//  点击『我的』左上角弹出的设置框，仅限于『我的』使用,这里的设置本地化用UserDefaults来完成
//

import UIKit

let kMineSettingsStaticLabelString = [LS("新消息通知"), LS("黑名单"), LS("定位可见"), LS("邀请加入群组"), LS("清除缓存"), LS("评价我们"), LS("意见反馈"), LS("用户协议"), LS("企业认证")]


class PersonMineSettings: UITableViewController, BlackListViewDelegate {
    /// 定位可见性
    var locationVisible: String! {
        return kPersonMineSettingsLocationVisibleMapping[PersonMineSettingsDataSource.sharedDataSource.locationVisible!]
    }
    /// 邀请加入群组
    var acceptInvitation: String! {
        return kPersonMineSettingsAcceptInvitationMapping[PersonMineSettingsDataSource.sharedDataSource.acceptInvitation!]
    }
    /// 缓存大小
    var cacheSizeRepre: String! {
        return PersonMineSettingsDataSource.sharedDataSource.cacheSizeDes ?? LS("正在获取缓存大小")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        tableView.registerClass(PersonMineSettingsBtnsCell.self, forCellReuseIdentifier: PersonMineSettingsBtnsCell.reuseIdentifier)
        // 复用这个cell
        tableView.registerClass(PrivateChatSettingsCommonCell.self, forCellReuseIdentifier: PrivateChatSettingsCommonCell.reuseIdentifier)
        
        tableView.separatorStyle = .None
        //
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dataSourceDidFinishUpdating:", name: PMUpdateFinishedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dataSourceUpateError:", name: PMUpdateErrorNotification, object: nil)
        let dataSource = PersonMineSettingsDataSource.sharedDataSource
        dataSource.update()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func navSettings() {
        self.navigationItem.title = LS("设置")
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        let navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        navLeftBtn.frame = CGRectMake(0, 0, 9, 15)
        navLeftBtn.addTarget(self, action: "navLeftBtnPressed", forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
    }
    
    func navLeftBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return kMineSettingsStaticLabelString.count
        }else{
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsCommonCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsCommonCell
            cell.staticLbl.text = kMineSettingsStaticLabelString[indexPath.row]
            cell.boolSelect.hidden = true
            switch indexPath.row {
            case 2:
                cell.editable = true
                cell.infoLbl.text = locationVisible
                break
            case 3:
                cell.editable = true
                cell.infoLbl.text = acceptInvitation
                break
            case 4:
                cell.editable = false
                cell.infoLbl.text = cacheSizeRepre
                break
            default:
                break
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier(PersonMineSettingsBtnsCell.reuseIdentifier, forIndexPath: indexPath) as! PersonMineSettingsBtnsCell
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 50
        }else {
            return 138
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            return
        }
        switch indexPath.row {
        case 0:
            let detail = PersonMineSettingsNewsMessageNotificationController()
            self.navigationController?.pushViewController(detail, animated: true)
            break
        case 1:
            let detail = BlackListViewController()
            detail.delegate = self
            self.navigationController?.pushViewController(detail, animated: true)
            break
        case 2:
            let detail = PersonMineSettingsLocationVisiblityController()
            self.navigationController?.pushViewController(detail, animated: true)
            break
        case 3:
            let detail = PersonMineSettingsInvitationController()
            self.navigationController?.pushViewController(detail, animated: true)
        case 7:
            let detail = AgreementController()
            self.navigationController?.pushViewController(detail, animated: true)
            break
        case 8:
            let detail = PersonMineSettingsAuthController()
            self.navigationController?.pushViewController(detail, animated: true)
            break
        default:
            break
        }
    }
    
    func didSelectUser(users: [User]) {
        
    }
    
    func dataSourceDidFinishUpdating(notif: Notification) {
        tableView.reloadData()
    }
    
    func dataSourceUpateError(notif: Notification) {
         
    }
}

class PersonMineSettingsBtnsCell: UITableViewCell {
    static let reuseIdentifier = "person_mine_settings_btn_cell"
    var quitBtn: UIButton!
    var changePassword: UIButton!
    
    func createSubviews() {
        let superview = self.contentView
        self.backgroundColor = UIColor.whiteColor()
        //
        quitBtn = UIButton()
        quitBtn.setImage(UIImage(named: "person_logout"), forState: .Normal)
        superview.addSubview(quitBtn)
        quitBtn.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(quitBtn)
            make.top.equalTo(superview).offset(35)
            make.size.equalTo(CGSizeMake(150, 50))
        }
        //
        changePassword = UIButton()
        changePassword.setTitle(LS("修改密码"), forState: .Normal)
        changePassword.setTitleColor(UIColor.blackColor(), forState: .Normal)
        changePassword.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        superview.addSubview(changePassword)
        changePassword.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(quitBtn)
            make.top.equalTo(quitBtn.snp_bottom)
            make.bottom.equalTo(superview)
            make.width.equalTo(quitBtn)
        }
    }
}

