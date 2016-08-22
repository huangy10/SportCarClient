//
//  SportCarBrandOnlineSelectorController.swift
//  SportCarClient
//
//  Created by 黄延 on 16/8/21.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Dollar


protocol SportCarBrandOnlineSelectorDelegate: class {
    func sportCarBrandOnlineSelectorDidSelect(manufacture: String, carName: String, subName: String)
    
    func sportCarBrandOnlineSelectorDidCancel()
}


class ManufacturerOnlineSelectorController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    var data: [String: [String]] = [:] {
        didSet {
            keys = ((data as NSDictionary).allKeys as! [String]).sort()
        }
    }
    private var keys: [String] = []
    var delegate: SportCarBrandOnlineSelectorDelegate!
    
    var filter: String?
    var searchController: UISearchController!
    var tapper: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        configureSearchView()

        loadManufactuers()
    }
    
    func configureNavigationBar() {
        navigationItem.title = LS("品牌型号")
        let leftBtnItem = UIBarButtonItem(title: LS("取消"), style: .Done, target: self, action: #selector(navLeftBtnPressed))
        leftBtnItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightRed], forState: .Normal)
        navigationItem.leftBarButtonItem = leftBtnItem
    }
    
    func navLeftBtnPressed() {
        delegate.sportCarBrandOnlineSelectorDidCancel()
    }
    
    func configureTableView() {
        tableView.registerClass(SportCarBrandSelectCell.self, forCellReuseIdentifier: "cell")
        
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl!)
        refreshControl?.addTarget(self, action: #selector(loadManufactuers), forControlEvents: .ValueChanged)
    }
    
    func configureSearchView() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
//        searchController.active = true
        
        tapper = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapper)
        tapper.enabled = false
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return keys.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = keys[section]
        return data[key]!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SportCarBrandSelectCell
        let key = keys[indexPath.section]
        let name = data[key]![indexPath.row]
        cell.nameLbl?.text = name
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return keys[section]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let index = keys[indexPath.section]
        let manufacturer = data[index]![indexPath.row]
        
        let detail = SportCarBrandOnlineSelectorController()
        detail.pickedCarInfo = [manufacturer]
        detail.delegate = delegate
        dismissKeyboard()
        navigationController?.pushViewController(detail, animated: true)
    }
    
    func loadManufactuers() {
        let filter = searchController.searchBar.text
        SportCarRequester.sharedInstance.carList("manufacturer", filter: filter, onSuccess: { (json) in
            self.data.removeAll()
            let parsedDict = json!.dictionaryValue
            for (key, value) in parsedDict {
                self.data[key] = $.map(value.arrayValue, transform: { $0.stringValue })
            }
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            }) { (code) in
                self.showToast(LS("网络访问出错"), onSelf: true)
                self.refreshControl?.endRefreshing()
        }
    }
    
    func dismissKeyboard() {
        tapper.enabled = false
        searchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        loadManufactuers()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        tapper.enabled = true
    }
}

class SportCarBrandOnlineSelectorController: UITableViewController, UISearchBarDelegate {
    
    var delegate: SportCarBrandOnlineSelectorDelegate!
    
    var data: [String] = []
    var pickedCarInfo: [String] = []
    var curLevel: Int {
        return pickedCarInfo.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNavigationBar()
        
        loadCarData()
    }
    
    func configureTableView() {
        tableView.registerClass(SportCarBrandSelectCell.self, forCellReuseIdentifier: "cell")
    }
    
    func configureNavigationBar() {
        navigationItem.title = pickedCarInfo.last()
        let leftBtn = UIButton().config(self, selector: #selector(navLeftBtnPressed))
        leftBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        leftBtn.frame = CGRectMake(0, 0, 15, 15)
        leftBtn.contentMode = .ScaleAspectFit

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
    }
    
    func navLeftBtnPressed() {
        navigationController?.popViewControllerAnimated(true)
    }

    func loadCarData() {
        let level = curLevel
        if level == 1 {
            loadCarNamesByManufacturer(pickedCarInfo[0])
        } else if level == 2 {
            loadSubNamesBy(pickedCarInfo[0], carName: pickedCarInfo[1])
        }
    }
    
    func loadCarNamesByManufacturer(manufacturer: String) {
        SportCarRequester.sharedInstance.carList("car_name", manufacturer: manufacturer, onSuccess: { (json) in
            self.data.removeAll()
            self.data = $.map(json!.arrayValue, transform: { $0.stringValue })
            self.tableView.reloadData()
            }) { (code) in
                self.showToast(LS("网络访问出错"), onSelf: true)
        }
    }
    
    func loadSubNamesBy(manufactuer: String, carName: String) {
        SportCarRequester.sharedInstance.carList("sub_name", manufacturer: manufactuer, carName: carName, onSuccess: { (json) in
            self.data.removeAll()
            self.data = $.map(json!.arrayValue, transform: { $0.stringValue })
            self.tableView.reloadData()
            }) { (code) in
                self.showToast(LS("网络访问出错"), onSelf: true)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SportCarBrandSelectCell
        if curLevel == 1 {
            cell.nameLbl?.text = data[indexPath.row]
        } else {
            let carName = pickedCarInfo[0]
            cell.nameLbl?.text = "\(carName) \(data[indexPath.row])"
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let level = curLevel
        if level == 1 {
            let carName = data[indexPath.row]
            var nextLevelPickedInfo = pickedCarInfo
            nextLevelPickedInfo.append(carName)
            let detail = SportCarBrandOnlineSelectorController()
            detail.delegate = delegate
            detail.pickedCarInfo = nextLevelPickedInfo
            navigationController?.pushViewController(detail, animated: true)
        } else if level == 2 {
            let manufacturer = pickedCarInfo[0]
            let carName = pickedCarInfo[1]
            let subName = data[indexPath.row]
            delegate.sportCarBrandOnlineSelectorDidSelect(manufacturer, carName: carName, subName: subName)
        }
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