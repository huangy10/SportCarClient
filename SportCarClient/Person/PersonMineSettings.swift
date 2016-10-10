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

let kMineSettingsStaticLabelString = [LS("新消息通知"), LS("黑名单"), LS("定位可见"), LS("清除缓存"), LS("评价我们"), LS("意见反馈"), LS("用户协议"), LS("企业认证")]


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
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        tableView.register(PersonMineSettingsBtnsCell.self, forCellReuseIdentifier: PersonMineSettingsBtnsCell.reuseIdentifier)
        // 复用这个cell
        SSPropertyCell.registerTableView(tableView)
        tableView.register(PrivateChatSettingsCommonCell.self, forCellReuseIdentifier: PrivateChatSettingsCommonCell.reuseIdentifier)
        
        tableView.separatorStyle = .none
        //
        NotificationCenter.default.addObserver(self, selector: #selector(PersonMineSettings.dataSourceDidFinishUpdating(_:)), name: NSNotification.Name(rawValue: PMUpdateFinishedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PersonMineSettings.dataSourceUpateError(_:)), name: NSNotification.Name(rawValue: PMUpdateErrorNotification), object: nil)
        let dataSource = PersonMineSettingsDataSource.sharedDataSource
        dataSource.update()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    func navSettings() {
        self.navigationItem.title = LS("设置")
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        let navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), for: .normal)
        navLeftBtn.frame = CGRect(x: 0, y: 0, width: 9, height: 15)
        navLeftBtn.addTarget(self, action: #selector(PersonMineSettings.navLeftBtnPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
    }
    
    func navLeftBtnPressed() {
        PersonMineSettingsDataSource.sharedDataSource.sync()
        if let delegate = homeDelegate {
            delegate.backToHome(nil)
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return kMineSettingsStaticLabelString.count
        }else{
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            let cell =  tableView.ss_reuseablePropertyCell(SSPropertyCell.self, forIndexPath: indexPath)
            cell.staticLbl.text = kMineSettingsStaticLabelString[(indexPath as NSIndexPath).row]
            switch (indexPath as NSIndexPath).row {
            case 2:
                return cell.setData(kMineSettingsStaticLabelString[(indexPath as NSIndexPath).row], propertyValue: locationVisible)
            case 3:
                return cell.setData(kMineSettingsStaticLabelString[(indexPath as NSIndexPath).row], propertyValue: cacheSizeRepre)
            default:
                return cell.setData(kMineSettingsStaticLabelString[(indexPath as NSIndexPath).row], propertyValue: nil)
            }
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: PersonMineSettingsBtnsCell.reuseIdentifier,
                for: indexPath) as! PersonMineSettingsBtnsCell
            cell.quitBtn.addTarget(self, action: #selector(PersonMineSettings.quitBtnPressed), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 50
        } else {
            return 200
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 1 {
            return
        }
        switch (indexPath as NSIndexPath).row {
        case 0:
            let detail = PersonMineSettingsNewsMessageNotificationController()
            self.navigationController?.pushViewController(detail, animated: true)
        case 1:
            let blacklist = BlacklistController()
            navigationController?.pushViewController(blacklist, animated: true)
        case 2:
            let detail = PersonMineSettingsLocationVisiblityController()
            self.navigationController?.pushViewController(detail, animated: true)
        case 3:
            showConfirmToast(LS("清除缓存"), message: LS("确认清除全部缓存？"), target: self, onConfirm: #selector(clearCacheConfirmed))
//            let detail = ClearCacheController(parent: self)
//            self.presentViewController(detail, animated: false, completion: nil)
            break
        case 4:
            let url = URL(string: "https://itunes.apple.com/us/app/pao-che-fan/id1100110084?l=zh&ls=1&mt=8")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
//            UIApplication.shared.openURL(url!)
        case 5:
            let detail = SuggestionController(parent: self)
            self.present(detail, animated: false, completion: nil)
            break
        case 6:
            let detail = AgreementController()
            self.navigationController?.pushViewController(detail, animated: true)
            break
        case 7:
            let detail = PersonMineSettingsAuthController()
            self.navigationController?.pushViewController(detail, animated: true)
            break
        default:
            break
        }
    }
    
    func dataSourceDidFinishUpdating(_ notif: Notification) {
        tableView.reloadData()
    }
    
    func dataSourceUpateError(_ notif: Notification) {
         
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
        self.backgroundColor = UIColor.white
        //
        quitBtn = UIButton()
        quitBtn.setImage(UIImage(named: "person_logout"), for: .normal)
        superview.addSubview(quitBtn)
        quitBtn.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.top.equalTo(superview).offset(30)
            make.size.equalTo(CGSize(width: 150, height: 50))
        }
        //
        changePassword = UIButton()
        changePassword.setTitle(LS("修改密码"), for: .normal)
        changePassword.setTitleColor(UIColor.black, for: .normal)
        changePassword.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        superview.addSubview(changePassword)
        changePassword.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(quitBtn)
            make.top.equalTo(quitBtn.snp.bottom)
            make.bottom.equalTo(superview)
            make.width.equalTo(quitBtn)
        }
        //
        changePassword.isHidden = true
    }
}

