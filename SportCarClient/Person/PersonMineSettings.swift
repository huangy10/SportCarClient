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


class PersonMineSettings: UITableViewController {
    
    weak var homeDelegate: HomeDelegate?
    
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
        SSPropertyCell.registerTableView(tableView)
        tableView.registerClass(PrivateChatSettingsCommonCell.self, forCellReuseIdentifier: PrivateChatSettingsCommonCell.reuseIdentifier)
        
        tableView.separatorStyle = .None
        //
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PersonMineSettings.dataSourceDidFinishUpdating(_:)), name: PMUpdateFinishedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PersonMineSettings.dataSourceUpateError(_:)), name: PMUpdateErrorNotification, object: nil)
        let dataSource = PersonMineSettingsDataSource.sharedDataSource
        dataSource.update()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    func navSettings() {
        self.navigationItem.title = LS("设置")
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        let navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        navLeftBtn.frame = CGRectMake(0, 0, 9, 15)
        navLeftBtn.addTarget(self, action: #selector(PersonMineSettings.navLeftBtnPressed), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
    }
    
    func navLeftBtnPressed() {
        PersonMineSettingsDataSource.sharedDataSource.sync()
        if let delegate = homeDelegate {
            delegate.backToHome(nil)
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
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
            let cell =  tableView.ss_reuseablePropertyCell(SSPropertyCell.self, forIndexPath: indexPath)
            cell.staticLbl.text = kMineSettingsStaticLabelString[indexPath.row]
            switch indexPath.row {
            case 2:
                return cell.setData(kMineSettingsStaticLabelString[indexPath.row], propertyValue: locationVisible)
            case 3:
                return cell.setData(kMineSettingsStaticLabelString[indexPath.row], propertyValue: acceptInvitation)
            case 4:
                return cell.setData(kMineSettingsStaticLabelString[indexPath.row], propertyValue: cacheSizeRepre)
            default:
                return cell.setData(kMineSettingsStaticLabelString[indexPath.row], propertyValue: nil)
            }
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier(PersonMineSettingsBtnsCell.reuseIdentifier,
                forIndexPath: indexPath) as! PersonMineSettingsBtnsCell
            cell.quitBtn.addTarget(self, action: #selector(PersonMineSettings.quitBtnPressed), forControlEvents: .TouchUpInside)
            cell.selectionStyle = .None
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
            let blacklist = BlacklistController()
            navigationController?.pushViewController(blacklist, animated: true)
        case 2:
            let detail = PersonMineSettingsLocationVisiblityController()
            self.navigationController?.pushViewController(detail, animated: true)
            break
        case 3:
            let detail = PersonMineSettingsInvitationController()
            self.navigationController?.pushViewController(detail, animated: true)
        case 4:
            showConfirmToast(LS("清除缓存"), message: LS("确认清除全部缓存？"), target: self, onConfirm: #selector(clearCacheConfirmed))
//            let detail = ClearCacheController(parent: self)
//            self.presentViewController(detail, animated: false, completion: nil)
            break
        case 5:
            let url = NSURL(string: "https://itunes.apple.com/us/app/pao-che-fan/id1100110084?l=zh&ls=1&mt=8")
            UIApplication.sharedApplication().openURL(url!)
        case 6:
            let detail = SuggestionController(parent: self)
            self.presentViewController(detail, animated: false, completion: nil)
            break
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
    
    func dataSourceDidFinishUpdating(notif: Notification) {
        tableView.reloadData()
    }
    
    func dataSourceUpateError(notif: Notification) {
         
    }
    
    func quitBtnPressed() {
        showConfirmToast(LS("退出登录"), message: LS("是否确认退出？"), target: self, onConfirm: #selector(quitConfirmed))
    }
    
    func quitConfirmed() {
        let app = AppManager.sharedAppManager
        app.logout()
    }
    
    func clearCacheConfirmed() {
        if !PersonMineSettingsDataSource.sharedDataSource.clearCacheFolder() {
            self.showToast(LS("清除缓存时出现错误"))
        }
//        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 3, inSection: 0)], withRowAnimation: .Automatic)
        tableView.reloadData()
    }
}

class PersonMineSettingsBtnsCell: UITableViewCell {
    static let reuseIdentifier = "person_mine_settings_btn_cell"
    var quitBtn: UIButton!
    var changePassword: UIButton!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self.contentView
        self.backgroundColor = UIColor.whiteColor()
        //
        quitBtn = UIButton()
        quitBtn.setImage(UIImage(named: "person_logout"), forState: .Normal)
        superview.addSubview(quitBtn)
        quitBtn.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.top.equalTo(superview).offset(3)
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
        //
        changePassword.hidden = true
    }
}

