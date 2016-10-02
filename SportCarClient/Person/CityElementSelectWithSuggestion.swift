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
    
    var delayTask: (()->())?
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        
        loadPopularCities()
    }
    
    func loadPopularCities() {
        lp_start()
        _ = ClubRequester.sharedInstance.clubPopularCities({ (json) in
            self.lp_stop()
            self.popularCities = $.map(json!.arrayValue, transform: { $0.stringValue }).filter({ $0 != "" })
//            self.popularCities = ["北京市", "上海市", "广州市", "深圳市", "南京市", "天津市", "武汉市", "成都市", "重庆市"]
            self.tableView.reloadData()
            }) { (code) in
                self.lp_stop()
                self.showToast(LS("获取热门城市失败"))
        }
    }
    
    func configureTableView() {
        tableView.register(CityElementSelectPopularCitiesCell.self, forCellReuseIdentifier: "popular")
        tableView.register(CityEelementSelectCurrentCell.self, forCellReuseIdentifier: "cur")
        tableView.register(CityElementSelectPopularCitiesHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.backgroundColor = UIColor(white: 0.94, alpha: 1)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if popularCities.count == 0 {
            return 2
        } else {
            return 3
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 && popularCities.count > 0 {
            return 1
        } else {
            return super.tableView(tableView, numberOfRowsInSection: 0)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! CityElementSelectPopularCitiesHeader
        if section == 0 {
            header.titleLbl.text = LS("当前")
        } else if section == 1 && popularCities.count > 0 {
            header.titleLbl.text = LS("热门")
        } else {
            header.titleLbl.text = LS("选择")
        }
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return 35
        } else if (indexPath as NSIndexPath).section == 1 && popularCities.count > 0 {
            let citiesNum = popularCities.count
            let rowsNum = (citiesNum - 1) / 3 + 1
            return CGFloat(rowsNum) * 35 + CGFloat(rowsNum - 1) * 10
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            delegate?.cityElementSelectDidCancel()
        } else if (indexPath as NSIndexPath).section == 2 || popularCities.count == 0 {
            super.tableView(tableView, didSelectRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cur", for: indexPath) as! CityEelementSelectCurrentCell
            cell.nameLbl.text = curSelected
            return cell
        } else if (indexPath as NSIndexPath).section == 1 && popularCities.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "popular", for: indexPath) as! CityElementSelectPopularCitiesCell
            cell.citiesMatrix.delegate = self
            cell.citiesMatrix.dataSource = self
            cell.citiesMatrix.reloadData()
            return cell
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    // ======================================
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularCities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CityElementPopularCityCell
        cell.nameLbl.text = popularCities[(indexPath as NSIndexPath).row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataSource.selectedCity = popularCities[(indexPath as NSIndexPath).row]
        delegate?.cityElementSelectDidSelect(dataSource)
    }
}


class CityEelementSelectCurrentCell: UITableViewCell {
    var nameLbl: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureNameLbl()
        backgroundColor = UIColor(white: 0.94, alpha: 1)
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureNameLbl() {
        let itemWidth = (UIScreen.main.bounds.width - 30 - 45) / 3
        nameLbl = contentView.addSubview(UILabel.self)
            .config(15, fontWeight: UIFontWeightRegular, textColor: kHighlightRed, textAlignment: .center)
            .layout({ (make) in
                make.left.equalTo(contentView).offset(15)
                make.width.equalTo(itemWidth)
                make.height.equalTo(35)
                make.top.equalTo(contentView)
            })
        nameLbl.backgroundColor = UIColor.white
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
        titleLbl = contentView.addSubview(UILabel.self)
            .config(14, fontWeight: UIFontWeightRegular, textColor: UIColor(white: 0, alpha: 0.58), textAlignment: .left)
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
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCitiesMatrix() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 22.5
        let itemWidth = (UIScreen.main.bounds.width - 30 - 45) / 3
        let itemHeight = 35 as CGFloat
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        
        citiesMatrix = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        citiesMatrix.backgroundColor = UIColor(white: 0.94, alpha: 1)
        contentView.addSubview(citiesMatrix)
        citiesMatrix.layout { (make) in
            make.edges.equalTo(contentView).inset(UIEdgeInsetsMake(0, 15, 0, 15))
        }
        
        citiesMatrix.register(CityElementPopularCityCell.self, forCellWithReuseIdentifier: "cell")
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
        nameLbl = contentView.addSubview(UILabel.self)
            .config(15, fontWeight: UIFontWeightRegular, textColor: UIColor.black, textAlignment: .center)
            .layout({ (make) in
                make.edges.equalTo(contentView)
            })
        contentView.backgroundColor = UIColor.white
    }
}
