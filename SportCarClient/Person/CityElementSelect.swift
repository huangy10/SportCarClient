//
//  CityElementSelect.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/6.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


protocol CityElementSelectDelegate: class {
    func cityElementSelectDidSelect(_ dataSource: CityElementSelectDataSource)
    func cityElementSelectDidCancel()
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
        let path = Bundle.main.path(forResource: "ChineseSubdivisions", ofType: "plist")
        let data = NSDictionary(contentsOfFile: path!)
        if data == nil {
            assertionFailure()
        }
        self.data = data!
    }
    
    func citiesForProvince(_ prov: String) -> [String]{
        let cities = (data[prov] as! NSArray)[0] as! NSDictionary
        return cities.allKeys as! [String]
    }
    
    func districtForProvince(_ prov: String, forCity city: String) -> [String]{
        let cities = (data[prov] as! NSArray)[0] as! NSDictionary
        return cities[city] as! [String]
    }
}


class CityElementSelectController: UITableViewController {
    weak var delegate: CityElementSelectDelegate?
    var level: Int = 0
    var maxLevel: Int = 2// 可以通过修改这个level值来控制选择的深度
    var datas: [String] = []
    var selectedElement: String?
    var dataSource: CityElementSelectDataSource!
    var data: [String] = []
    var showAllContry: Bool = false
    
    //
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        tableView.register(SportCarBrandSelectCell.self, forCellReuseIdentifier: SportCarBrandSelectCell.reuseIdentifier)
        
        assert(showAllContry || maxLevel > 0)
    }
    
    func navSettings() {
        self.navigationItem.title = LS("活跃地区")
        let backBtn = UIBarButtonItem(title: LS("取消"), style: .done, target: self, action: #selector(navLeftBtnPressed))
        backBtn.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular), NSForegroundColorAttributeName: kHighlightedRedTextColor], for: .normal)
        navigationItem.leftBarButtonItem = backBtn
    }
    
    func navLeftBtnPressed() {
        delegate?.cityElementSelectDidCancel()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showAllContry {
            return data.count + 1
        }
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SportCarBrandSelectCell.reuseIdentifier, for: indexPath) as! SportCarBrandSelectCell
        if showAllContry {
            if (indexPath as NSIndexPath).row == 0  {
                cell.nameLbl?.text = LS("全国")
            } else {
                cell.nameLbl?.text = data[(indexPath as NSIndexPath).row - 1]
            }
        } else {
            cell.nameLbl?.text = data[(indexPath as NSIndexPath).row]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch level {
        case 0:
            if showAllContry {
                if (indexPath as NSIndexPath).row > 0 {
                    dataSource.selectedProv = data[(indexPath as NSIndexPath).row - 1]
                } else {
                    dataSource.selectedProv = "全国"
                    dataSource.selectedCity = nil
                    delegate?.cityElementSelectDidSelect(dataSource)
                }
            } else {
                dataSource.selectedProv = data[(indexPath as NSIndexPath).row]
            }
        case 1:
            dataSource.selectedCity = data[(indexPath as NSIndexPath).row]
        case 2:
            dataSource.selectedDistrict = data[(indexPath as NSIndexPath).row]
        default:
            break
        }
        if level == maxLevel {
            delegate?.cityElementSelectDidSelect(dataSource)
            return
        }
        let detail = CityElementSelectController()
        detail.dataSource = dataSource
        detail.maxLevel = maxLevel
        detail.level = level + 1
        detail.delegate = delegate
        self.navigationController?.pushViewController(detail, animated: true)
    }
}




