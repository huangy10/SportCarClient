//
//  CityElementSelect.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/6.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


protocol CityElementSelectDelegate: class {
    func cityElementSelectDidSelect(dataSource: CityElementSelectDataSource)
}


class CityElementSelectDataSource {
    var data: NSDictionary
    var provinces: [String] {
        return data.allKeys as! [String]
    }
    
    var selectedProv: String?
    var selectedCity: String?
    var selectedDistrict: String?
    
    init() {
        // read from plist file
        let path = NSBundle.mainBundle().pathForResource("ChineseSubdivisions", ofType: "plist")
        let data = NSDictionary(contentsOfFile: path!)
        if data == nil {
            assertionFailure()
        }
        self.data = data!
    }
    
    func citiesForProvince(prov: String) -> [String]{
        let cities = (data[prov] as! NSArray)[0] as! NSDictionary
        return cities.allKeys as! [String]
    }
    
    func districtForProvince(prov: String, forCity city: String) -> [String]{
        let cities = (data[prov] as! NSArray)[0] as! NSDictionary
        return cities[city] as! [String]
    }
}


class CityElementSelectController: UITableViewController {
    weak var delegate: CityElementSelectDelegate?
    var level: Int = 0      // 可以通过修改这个level值来控制选择的深度
    var maxLevel: Int = 2
    var datas: [String] = []
    var selectedElement: String?
    var dataSource: CityElementSelectDataSource!
    var data: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        switch level {
        case 0:
            dataSource = CityElementSelectDataSource()
            data = dataSource.provinces
        case 1:
            data = dataSource.citiesForProvince(dataSource.selectedProv!)
        case 2:
            data = dataSource.districtForProvince(dataSource.selectedProv!, forCity: dataSource.selectedCity!)
        default:
            assertionFailure()
        }
        tableView.registerClass(SportCarBrandSelectCell.self, forCellReuseIdentifier: SportCarBrandSelectCell.reuseIdentifier)
    }
    
    func navSettings() {
        self.navigationItem.title = LS("活跃地区")
        let backBtn = UIButton()
        backBtn.setBackgroundImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        backBtn.addTarget(self, action: "navLeftBtnPressed", forControlEvents: .TouchUpInside)
        backBtn.frame = CGRect(x: 0, y: 0, width: 10.2, height: 18)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
    }
    
    func navLeftBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SportCarBrandSelectCell.reuseIdentifier, forIndexPath: indexPath) as! SportCarBrandSelectCell
        cell.nameLbl?.text = data[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch level {
        case 0:
            dataSource.selectedProv = data[indexPath.row]
        case 1:
            dataSource.selectedCity = data[indexPath.row]
        case 2:
            dataSource.selectedDistrict = data[indexPath.row]
        default:
            break
        }
        if level == maxLevel {
            let root = delegate as! UIViewController
            self.navigationController?.popToViewController(root, animated: true)
            delegate?.cityElementSelectDidSelect(dataSource)
            return
        }
        let detail = CityElementSelectController()
        detail.dataSource = dataSource
        detail.level = level + 1
        detail.delegate = delegate
        self.navigationController?.pushViewController(detail, animated: true)
    }
}
