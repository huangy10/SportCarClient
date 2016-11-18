//
//  PersonMineSettingsLocationVisiblity.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/11.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


let kPersonMineSettingsLocationVisiblityStaticLabelString = [LS("仅列表可见"), LS("所有人可见"), LS("仅女性可见"), LS("仅男性可见"), LS("隐身"), LS("仅我关注的人"), LS("互相关注")]

class PersonMineSettingsLocationVisiblityController: UITableViewController {
    
    var selectedType: String?
    var showOnMap: Bool = true
    var dirty: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        navSettings()
        //
        tableView.register(PrivateChatSettingsCommonCell.self, forCellReuseIdentifier: PrivateChatSettingsCommonCell.reuseIdentifier)
        tableView.register(PersonMineSettingsLocationVisiblityCell.self, forCellReuseIdentifier: PersonMineSettingsLocationVisiblityCell.reuseIdentifier)
        tableView.separatorStyle = .none
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
        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), for: .normal)
        navLeftBtn.frame = CGRect(x: 0, y: 0, width: 9, height: 15)
        navLeftBtn.addTarget(self, action: #selector(PersonMineSettingsLocationVisiblityController.navLeftBtnPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        //
        let rightItem = UIBarButtonItem(title: LS("确定"), style: .done, target: self, action: #selector(PersonMineSettingsLocationVisiblityController.navRightBtnPressed))
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
            dataSource.locationVisible = self.selectedType
            dataSource.showOnMap = self.showOnMap
            dataSource.sync()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kPersonMineSettingsLocationVisiblityStaticLabelString.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row < kPersonMineSettingsLocationVisiblityStaticLabelString.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: PrivateChatSettingsCommonCell.reuseIdentifier, for: indexPath) as! PrivateChatSettingsCommonCell
            cell.selectionStyle = .none
            cell.staticLbl.text = kPersonMineSettingsLocationVisiblityStaticLabelString[(indexPath as NSIndexPath).row]
            if (indexPath as NSIndexPath).row == 0 {
                cell.useAsMark = false
                cell.boolSelect.isHidden = false
                cell.boolSelect.isOn = !showOnMap
                cell.boolSelect.addTarget(self, action: #selector(PersonMineSettingsLocationVisiblityController.switchBtnPressed(_:)), for: .valueChanged)
            }else{
                cell.useAsMark = true
                if cell.staticLbl.text == kPersonMineSettingsLocationVisibleMapping[selectedType!] {
                    cell.markIcon.isHidden = false
                }else {
                    cell.markIcon.isHidden = true
                }
            }
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: PersonMineSettingsLocationVisiblityCell.reuseIdentifier, for: indexPath) as! PersonMineSettingsLocationVisiblityCell
            cell.selectionStyle = .none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 0 {
            return
        }
        dirty = true
        selectedType = kPersonMineSettingsLocationVisibilityList[(indexPath as NSIndexPath).row - 1]
        tableView.reloadData()
    }
    
    func switchBtnPressed(_ sender: UISwitch) {
        showOnMap = !sender.isOn
        dirty = true
    }
}

class PersonMineSettingsLocationVisiblityCell: UITableViewCell {
    
    static let reuseIdentifier = "person_mine_settings_location_visibility_cell"
    
    var titleLbl: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        titleLbl = UILabel()
        titleLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
        titleLbl.textColor = kTextGray28
        titleLbl.text = LS("请开启定位可见以发现跑车地图上的车主并在系统设置中开启定位功能")
        titleLbl.numberOfLines = 0
        titleLbl.textAlignment = .center
        self.contentView.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.contentView)
            make.top.equalTo(self.contentView).offset(40)
            make.width.equalTo(218)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
