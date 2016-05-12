//
//  SportCarBrandSelecter.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/14.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit


protocol SportCarBrandSelecterControllerDelegate: class {
    func brandSelected(manufacturer: String?, carType: String?)
}


class SportCarBrandDataManager {
    static let sharedManager = SportCarBrandDataManager()
    /// 这个字典装载的是原始数据，可以通过这个来查询最总选中的车型的id
    var data: NSDictionary
    // 下面这几个数据是为了检索方便而创建的Key数组
    /// 所有的首字母集合
    let letterSet: [String]
    /// 应用在无过滤情况下品牌选择界面的矩阵
    var manufacturerMatrix: [[String]?] = []
    /// 这个字典里面的装载的是品牌的
    var manufacturerSet: [String] = []
    var filteredManufactureSet: [String]?
    
    init() {
        // 从plist文件中载入
        let path = NSBundle.mainBundle().pathForResource("sportcar", ofType: "plist")
        let data = NSDictionary(contentsOfFile: path!)
        if data == nil {
            assertionFailure()
        }
        self.data = data!
        letterSet = (self.data.allKeys as! [String]).sort()
        for key in letterSet {
            let manufactuers = self.data[key] as! NSDictionary
            let manufNameList = manufactuers.allKeys as! [String]
            manufacturerMatrix.append(manufNameList)
            manufacturerSet += manufNameList
        }
        filteredManufactureSet = manufacturerSet
    }
    
    /**
     重置DataManager
     */
    func reset() {
        self.filterWithStr()
    }
    
    /**
     对当前的品牌列表进行筛选
     
     - parameter filterStr: 关键词
     */
    func filterWithStr(filterStr: String?=nil){
        guard let filter = filterStr?.lowercaseString else{
            filteredManufactureSet = manufacturerSet
            return
        }
        filteredManufactureSet = manufacturerSet.filter({ (element) -> Bool in
            if (element.lowercaseString.rangeOfString(filter) != nil){
                return true
            }else{
                return false
            }
        })
    }
    /**
     获取某一品牌下的车型列表
     
     - parameter letter: 品牌所属的首字母组
     - parameter name:   品牌名称
     
     - returns: 车型名称列表
     */
    func carTypes(letter: String, forManufacturer name: String) -> [String]{
        let manufList = data[letter] as! NSDictionary
        let carList = manufList[name] as! [String]
        return carList
    }
    
    func letterForManufacturer(manuf: String) -> String? {
        var letterIndex = 0
        for manufs in manufacturerMatrix {
            if ((manufs?.contains(manuf)) != nil) {
                return self.letterSet[letterIndex]
            }
            letterIndex += 1
        }
        return nil
    }
}


class SportCarBrandSelecterController: InputableViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: SportCarBrandSelecterControllerDelegate?
    let dataManager = SportCarBrandDataManager.sharedManager
    
    var tableView: UITableView?
    var searchBar: UISearchBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navBarSettings()
        let superview = self.view
        superview.backgroundColor = UIColor.whiteColor()
        //
        searchBar = UISearchBar()
        superview.addSubview(searchBar!)
        searchBar?.delegate = self
        searchBar?.searchBarStyle = .Minimal
        searchBar?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.top.equalTo(superview)
            make.height.equalTo(44)
        })
        //
        tableView = UITableView(frame: CGRect.zero, style: .Plain)
        tableView?.dataSource = self
        tableView?.delegate = self
        superview.addSubview(tableView!)
        tableView?.snp_makeConstraints(closure: { (make) -> Void in
            make.top.equalTo(searchBar!.snp_bottom)
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.bottom.equalTo(superview)
        })
        tableView?.registerClass(SportCarBrandSelectCell.self, forCellReuseIdentifier: SportCarBrandSelectCell.reuseIdentifier)
        tableView?.reloadData()
    }
    
    func navBarSettings() {
        self.navigationItem.title = LS("品牌型号")
        self.navigationItem.leftBarButtonItem = navBarLeftBtn()
    }
    
    func navBarLeftBtn() -> UIBarButtonItem! {
        let backBtn = UIButton()
        backBtn.setBackgroundImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        backBtn.addTarget(self, action: #selector(SportCarBrandSelecterController.backBtnPressed), forControlEvents: .TouchUpInside)
        backBtn.frame = CGRect(x: 0, y: 0, width: 10.2, height: 18)
        
        let leftBtnItem = UIBarButtonItem(customView: backBtn)
        return leftBtnItem
    }
    
    func backBtnPressed() {
        delegate?.brandSelected(nil, carType: nil)
    }
    
    // MARK: tableview的代理
    /*
     说明，搜索中的列表和完整状态的列表采用了不同的组织形式，
     在无搜索时，所有的词条按照首字母组合在一起（中文则是拼音的首字母）
     在搜索状态时则不按照字母组合，即只有一个section
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let filterStr = getFilterString()
        if filterStr != nil {
            // 有筛选时，只有一个section来显示结果
            return 1
        }
        return dataManager.letterSet.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let filterStr = getFilterString()
        if filterStr != nil {
            // 有筛选时，只有一个section来显示结果
            return dataManager.filteredManufactureSet!.count
        }
        return dataManager.manufacturerMatrix[section]!.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let filterStr = getFilterString()
        if filterStr != nil {
            // 有筛选时，只有一个section来显示结果
            return nil
        }
        return dataManager.letterSet[section]
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        let filterStr = getFilterString()
        if filterStr != nil {
            // 有筛选时，只有一个section来显示结果
            return nil
        }
        return dataManager.letterSet
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SportCarBrandSelectCell.reuseIdentifier, forIndexPath: indexPath) as? SportCarBrandSelectCell
        let filterStr = getFilterString()
        if filterStr != nil {
            // 有筛选时，只有一个section来显示结果
            cell?.nameLbl?.text = dataManager.filteredManufactureSet![indexPath.row]
        }else{
            cell?.nameLbl?.text = dataManager.manufacturerMatrix[indexPath.section]![indexPath.row]
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedManuf: String?
        var selectedLetter: String?
        if getFilterString() == nil {
            selectedLetter = dataManager.letterSet[indexPath.section]
            selectedManuf = dataManager.manufacturerMatrix[indexPath.section]![indexPath.row]
        }else{
            selectedManuf = dataManager.filteredManufactureSet![indexPath.row]
            selectedLetter = dataManager.letterForManufacturer(selectedManuf!)
        }
        let detail = SportCarBrandSelecterDetailController()
        detail.delegate = self.delegate
        detail.data = dataManager.carTypes(selectedLetter!, forManufacturer: selectedManuf!)
        detail.manufacturer = selectedManuf
        self.navigationController?.pushViewController(detail, animated: true)
    }
    
    func getFilterString() -> String? {
        // 提取搜索参数，这里将空输入""也视为nil返回
        guard let filterStr = searchBar?.text else {
            return nil
        }
        if filterStr == "" {
            return nil
        }
        return filterStr
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        dataManager.filterWithStr(getFilterString())
        tableView?.reloadData()
    }
    
    override func dismissKeyboard() {
        super.dismissKeyboard()
        searchBar?.resignFirstResponder()
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        self.tapper?.enabled = true
        return true
    }
}

class SportCarBrandSelectCell: UITableViewCell {
    var nameLbl: UILabel?
    
    static let reuseIdentifier = "SportCarBrandSelectCell"
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //
        nameLbl = UILabel()
        nameLbl?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        nameLbl?.textColor = UIColor.blackColor()
        self.contentView.addSubview(nameLbl!)
        nameLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.edges.equalTo(self.contentView).inset(UIEdgeInsets(top: 2, left: 15, bottom: 2, right: 15))
        })
        //
        let rightIcon = UIImageView(image: UIImage(named: "account_btn_next_icon"))
        nameLbl?.addSubview(rightIcon)
        rightIcon.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(nameLbl!)
            make.centerY.equalTo(nameLbl!)
            make.size.equalTo(CGSize(width: 9, height: 15))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
