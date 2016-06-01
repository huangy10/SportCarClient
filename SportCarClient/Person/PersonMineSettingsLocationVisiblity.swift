//
//  PersonMineSettingsLocationVisiblity.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/11.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


let kPersonMineSettingsLocationVisiblityStaticLabelString = [LS("仅列表可见"), LS("所有人"), LS("仅女性"), LS("仅男性"), LS("不可见"), LS("仅我关注的人"), LS("互相关注")]

class PersonMineSettingsLocationVisiblityController: UITableViewController {
    
    var selectedType: String?
    var showOnMap: Bool = true
    var dirty: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        navSettings()
        //
        tableView.registerClass(PrivateChatSettingsCommonCell.self, forCellReuseIdentifier: PrivateChatSettingsCommonCell.reuseIdentifier)
        tableView.registerClass(PersonMineSettingsLocationVisiblityCell.self, forCellReuseIdentifier: PersonMineSettingsLocationVisiblityCell.reuseIdentifier)
        tableView.separatorStyle = .None
        tableView.rowHeight = 50
        //
        let dataSource = PersonMineSettingsDataSource.sharedDataSource
        showOnMap = dataSource.showOnMap
        selectedType = dataSource.locationVisible
    }
    
    func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = LS("定位可见")
        //
        let navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        navLeftBtn.frame = CGRectMake(0, 0, 9, 15)
        navLeftBtn.addTarget(self, action: #selector(PersonMineSettingsLocationVisiblityController.navLeftBtnPressed), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        //
        let rightItem = UIBarButtonItem(title: LS("确定"), style: .Done, target: self, action: #selector(PersonMineSettingsLocationVisiblityController.navRightBtnPressed))
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
            dataSource.locationVisible = self.selectedType
            dataSource.showOnMap = self.showOnMap
            dataSource.sync()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kPersonMineSettingsLocationVisiblityStaticLabelString.count + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < kPersonMineSettingsLocationVisiblityStaticLabelString.count {
            let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsCommonCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsCommonCell
            cell.selectionStyle = .None
            cell.staticLbl.text = kPersonMineSettingsLocationVisiblityStaticLabelString[indexPath.row]
            if indexPath.row == 0 {
                cell.useAsMark = false
                cell.boolSelect.hidden = false
                cell.boolSelect.on = !showOnMap
                cell.boolSelect.addTarget(self, action: #selector(PersonMineSettingsLocationVisiblityController.switchBtnPressed(_:)), forControlEvents: .ValueChanged)
            }else{
                cell.useAsMark = true
                if cell.staticLbl.text == kPersonMineSettingsLocationVisibleMapping[selectedType!] {
                    cell.markIcon.hidden = false
                }else {
                    cell.markIcon.hidden = true
                }
            }
            return cell
        }else {
            let cell = tableView.dequeueReusableCellWithIdentifier(PersonMineSettingsLocationVisiblityCell.reuseIdentifier, forIndexPath: indexPath) as! PersonMineSettingsLocationVisiblityCell
            cell.selectionStyle = .None
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            return
        }
        dirty = true
        selectedType = kPersonMineSettingsLocationVisibilityList[indexPath.row - 1]
        tableView.reloadData()
    }
    
    func switchBtnPressed(sender: UISwitch) {
        showOnMap = sender.on
        dirty = true
    }
}

class PersonMineSettingsLocationVisiblityCell: UITableViewCell {
    
    static let reuseIdentifier = "person_mine_settings_location_visibility_cell"
    
    var titleLbl: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        titleLbl = UILabel()
        titleLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        titleLbl.textColor = UIColor(white: 0.72, alpha: 1)
        titleLbl.text = LS("请开启定位可见以发现跑车地图上的车主并在系统设置中开启定位功能")
        titleLbl.numberOfLines = 0
        titleLbl.textAlignment = .Center
        self.contentView.addSubview(titleLbl)
        titleLbl.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.contentView)
            make.top.equalTo(self.contentView).offset(40)
            make.width.equalTo(218)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
