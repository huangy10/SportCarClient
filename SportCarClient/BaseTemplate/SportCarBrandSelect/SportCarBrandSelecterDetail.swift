//
//  SportCarBrandSelecterDetail.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/14.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit


class SportCarBrandSelecterDetailController: UITableViewController {
    var manufacturer: String?
    var delegate: SportCarBrandSelecterControllerDelegate?
    let dataManager = SportCarBrandDataManager.sharedManager
    var data: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navBarSettings()
        self.createSubviews()
    }
    
    func createSubviews() {
        self.tableView?.separatorStyle = .None
        self.tableView.registerClass(SportCarBrandSelectCell.self, forCellReuseIdentifier: SportCarBrandSelectCell.reuseIdentifier)
    }
    
    func navBarSettings() {
        self.navigationItem.title = NSLocalizedString("品牌型号", comment: "")
        self.navigationItem.leftBarButtonItem = navBarLeftBtn()
    }
    
    func navBarLeftBtn() -> UIBarButtonItem! {
        let backBtn = UIButton()
        backBtn.setBackgroundImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        backBtn.addTarget(self, action: "backBtnPressed", forControlEvents: .TouchUpInside)
        backBtn.frame = CGRect(x: 0, y: 0, width: 10.2, height: 18)
        
        let leftBtnItem = UIBarButtonItem(customView: backBtn)
        return leftBtnItem
    }
    
    func backBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(SportCarBrandSelectCell.reuseIdentifier, forIndexPath: indexPath) as? SportCarBrandSelectCell
        if cell == nil {
            assertionFailure()
        }
        cell?.nameLbl?.text = data[indexPath.row]
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let carType = data[indexPath.row]
        delegate?.brandSelected(manufacturer, carType: carType)
    }
}
