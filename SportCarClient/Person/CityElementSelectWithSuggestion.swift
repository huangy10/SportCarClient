//
//  CityElementSelectWithSuggestion.swift
//  SportCarClient
//
//  Created by 黄延 on 16/8/22.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Dollar


class CityElementSelectWithSuggestionsController: CityElementSelectController, UICollectionViewDataSource, UICollectionViewDelegate, LoadingProtocol {
    
    var curSelected: String!
    var popularCities: [String] = []
    
    var delayTask: dispatch_block_t?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        
        loadPopularCities()
    }
    
    func loadPopularCities() {
        lp_start()
        ClubRequester.sharedInstance.clubPopularCities({ (json) in
            self.lp_stop()
            self.popularCities = $.map(json!.arrayValue, transform: { $0.stringValue })
//            self.popularCities = ["北京市", "上海市", "广州市", "深圳市", "南京市", "天津市", "武汉市", "成都市", "重庆市"]
            self.tableView.reloadData()
            }) { (code) in
                self.lp_stop()
                self.showToast(LS("获取热门城市失败"))
        }
    }
    
    func configureTableView() {
        tableView.registerClass(CityElementSelectPopularCitiesCell.self, forCellReuseIdentifier: "popular")
        tableView.registerClass(CityEelementSelectCurrentCell.self, forCellReuseIdentifier: "cur")
        tableView.registerClass(CityElementSelectPopularCitiesHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.backgroundColor = UIColor(white: 0.94, alpha: 1)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if popularCities.count == 0 {
            return 2
        } else {
            return 3
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 && popularCities.count > 0 {
            return 1
        } else {
            return super.tableView(tableView, numberOfRowsInSection: 0)
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! CityElementSelectPopularCitiesHeader
        if section == 0 {
            header.titleLbl.text = LS("当前")
        } else if section == 1 && popularCities.count > 0 {
            header.titleLbl.text = LS("热门")
        } else {
            header.titleLbl.text = LS("选择")
        }
        return header
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 35
        } else if indexPath.section == 1 && popularCities.count > 0 {
            let citiesNum = popularCities.count
            let rowsNum = (citiesNum - 1) / 3 + 1
            return CGFloat(rowsNum) * 35 + CGFloat(rowsNum - 1) * 10
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            delegate?.cityElementSelectDidCancel()
        } else if indexPath.section == 2 || popularCities.count == 0 {
            super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("cur", forIndexPath: indexPath) as! CityEelementSelectCurrentCell
            cell.nameLbl.text = curSelected
            return cell
        } else if indexPath.section == 1 && popularCities.count > 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("popular", forIndexPath: indexPath) as! CityElementSelectPopularCitiesCell
            cell.citiesMatrix.delegate = self
            cell.citiesMatrix.dataSource = self
            cell.citiesMatrix.reloadData()
            return cell
        } else {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    // ======================================
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularCities.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CityElementPopularCityCell
        cell.nameLbl.text = popularCities[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        dataSource.selectedCity = popularCities[indexPath.row]
        delegate?.cityElementSelectDidSelect(dataSource)
    }
}


class CityEelementSelectCurrentCell: UITableViewCell {
    var nameLbl: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureNameLbl()
        backgroundColor = UIColor(white: 0.94, alpha: 1)
        selectionStyle = .None
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureNameLbl() {
        let itemWidth = (UIScreen.mainScreen().bounds.width - 30 - 45) / 3
        nameLbl = contentView.addSubview(UILabel)
            .config(15, fontWeight: UIFontWeightRegular, textColor: kHighlightRed, textAlignment: .Center)
            .layout({ (make) in
                make.left.equalTo(contentView).offset(15)
                make.width.equalTo(itemWidth)
                make.height.equalTo(35)
                make.top.equalTo(contentView)
            })
        nameLbl.backgroundColor = UIColor.whiteColor()
    }
}


class CityElementSelectPopularCitiesHeader: UITableViewHeaderFooterView {
    
    var titleLbl: UILabel!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureTitleLbl()
        
        contentView.backgroundColor = UIColor(white: 0.94, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureTitleLbl() {
        titleLbl = contentView.addSubview(UILabel)
            .config(14, fontWeight: UIFontWeightRegular, textColor: UIColor(white: 0, alpha: 0.58), textAlignment: .Left)
            .layout({ (make) in
                make.left.equalTo(contentView).offset(15)
                make.bottom.equalTo(contentView).offset(-16)
            })
    }
}


class CityElementSelectPopularCitiesCell: UITableViewCell {
    var citiesMatrix: UICollectionView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCitiesMatrix()
        backgroundColor = UIColor(white: 0.94, alpha: 1)
        selectionStyle = .None
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCitiesMatrix() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 22.5
        let itemWidth = (UIScreen.mainScreen().bounds.width - 30 - 45) / 3
        let itemHeight = 35 as CGFloat
        layout.itemSize = CGSizeMake(itemWidth, itemHeight)
        
        citiesMatrix = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        citiesMatrix.backgroundColor = UIColor(white: 0.94, alpha: 1)
        contentView.addSubview(citiesMatrix)
        citiesMatrix.layout { (make) in
            make.edges.equalTo(contentView).inset(UIEdgeInsetsMake(0, 15, 0, 15))
        }
        
        citiesMatrix.registerClass(CityElementPopularCityCell.self, forCellWithReuseIdentifier: "cell")
    }
}

class CityElementPopularCityCell: UICollectionViewCell {
    var nameLbl: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureNameLbl()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureNameLbl() {
        nameLbl = contentView.addSubview(UILabel)
            .config(15, fontWeight: UIFontWeightRegular, textColor: UIColor.blackColor(), textAlignment: .Center)
            .layout({ (make) in
                make.edges.equalTo(contentView)
            })
        contentView.backgroundColor = UIColor.whiteColor()
    }
}