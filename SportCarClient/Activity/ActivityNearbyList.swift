//
//  ActivityNearbyList.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/10/29.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire

class ActivityNearByListController: UIViewController {
    var collectionView: UICollectionView!
    
    var cityFilterBtn: UIButton!
    var cityFilterLbl: UILabel!
    
    var ongoingRequest: Request?
    
    var data: [Activity] = []
    
    var locationService: BMKLocationService!
    var geoSearch: BMKGeoCodeSearch!
    
    var location: CLLocationCoordinate2D?
    var locDes: String? {
        didSet {
            refreshView.pullingLbl.text = locDes
        }
    }
    
    var refreshView: SSPullToRefresh!
    var initFetched: Bool = false
    var nearByOnly: Bool {
        return cityFilterLbl.text == "全国"
    }
    
    deinit {
        refreshView.scrollView = nil
        refreshView = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureCityFilter()
        configureRefreshControl()

        locationService = BMKLocationService()
        geoSearch = BMKGeoCodeSearch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationService.delegate = self
        geoSearch.delegate = self
        locationService.startUserLocationService()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationService.delegate = nil
        geoSearch.delegate = nil
        locationService.stopUserLocationService()
        
        if let req = ongoingRequest {
            req.cancel()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func configureRefreshControl() {
        refreshView = SSPullToRefresh()
        refreshView.addToSrollView(collectionView, action: { [weak self] in
            self?.loadActivityData()
        })
        
        refreshView.pullingLbl.text = LS("这里显示当前地址")
       
    }
    
    func loadActivityData(clearOlds: Bool = false) {
        let userLoc: CLLocationCoordinate2D
        if let loc = location , nearByOnly {
            userLoc = loc
        } else if !nearByOnly {
            // 此时为按地址筛选，这里的userLoc只需要提供一个fake的就可以了
            userLoc = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        } else {
            return
        }
        
        if let req = ongoingRequest {
            req.cancel()
        }
        
        ongoingRequest = ActivityRequester.sharedInstance.getNearByActivities(userLoc, queryDistance: 10000, cityLimit: cityFilterLbl.text!, skip: clearOlds ? 0 : self.data.count, limit: 10, onSuccess: { (json) in
            self.refreshView.endRefreshing()
            var newActs: [Activity] = []
            for data in json!.arrayValue {
                let act: Activity = try! MainManager.sharedManager.getOrCreate(data)
                newActs.append(act)
            }
            if clearOlds {
                self.data.removeAll()
                self.data = newActs
            } else {
                self.data.append(contentsOf: newActs)
            }
            self.collectionView.reloadData()
        }, onError: { (code) in
            self.refreshView.endRefreshing()
            self.showToast(LS("网络访问错误:\(code)"))
        })
    }
    
    func getCollectionLayout() -> UICollectionViewLayout {
        let defaultLayout = UICollectionViewFlowLayout()
        defaultLayout.scrollDirection = .vertical
        defaultLayout.minimumLineSpacing = 10
        defaultLayout.minimumInteritemSpacing = 10
        return defaultLayout
    }
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: getCollectionLayout())
        view.addSubview(collectionView)
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsetsMake(10, 12.5, 10, 12.5)
        collectionView.backgroundColor = kGeneralTableViewBGColor
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        collectionView.register(ActivityCell.self, forCellWithReuseIdentifier: ActivityCell.reuseIdentifier)
        collectionView.register(SSEmptyCollectionHitCell.self, forCellWithReuseIdentifier: "empty")
    }
    
    func configureCityFilter() {
        cityFilterBtn = view.addSubview(UIButton.self)
            .config(self, selector: #selector(cityFilterBtnPressed)).config(UIColor.white)
            .addShadow()
            .toRound(20)
            .layout({ (make) in
                make.right.equalTo(view).offset(-13)
                make.top.equalTo(view).offset(13)
                make.width.equalTo(120)
                make.height.equalTo(40)
            })
        let icon = cityFilterBtn.addSubview(UIImageView.self)
            .config(UIImage(named: "down_arrow_black"))
            .layout { (make) in
                make.centerY.equalTo(cityFilterBtn)
                make.right.equalTo(cityFilterBtn).offset(-20)
                make.size.equalTo(CGSize(width: 13, height: 9))
        }
        cityFilterLbl = cityFilterBtn.addSubview(UILabel.self)
            .config(14, textColor: UIColor(white: 0, alpha: 0.87), text: LS("全国"))
            .layout({ (make) in
                make.left.equalTo(cityFilterBtn).offset(20)
                make.right.equalTo(icon.snp.left).offset(-10)
                make.centerY.equalTo(cityFilterBtn)
            })
    }
    
    func cityFilterBtnPressed() {
        let select = CityElementSelectWithSuggestionsController()
        select.maxLevel = 1
        select.showAllContry = true
        select.delegate = self
        select.curSelected = cityFilterLbl.text
        
        parent?.present(select.toNavWrapper(), animated: true, completion: nil)
    }
}

extension ActivityNearByListController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(data.count, 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if data.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "empty", for: indexPath) as! SSEmptyCollectionHitCell
            cell.titleLbl.text = LS("附近暂无活动")
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActivityCell.reuseIdentifier, for: indexPath) as! ActivityCell
        cell.act = data[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let act = data[indexPath.row]
        let detail = ActivityDetailController(act: act)
        parent?.navigationController?.pushViewController(detail, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        if data.isEmpty {
            return CGSize(width: screenWidth - collectionView.contentInset.left - collectionView.contentInset.right, height: 100)
        } else {
            return CGSize(width: screenWidth / 2 - 17.5, height: 200)
        }
    }
}


extension ActivityNearByListController: CityElementSelectDelegate {
    func cityElementSelectDidCancel() {
        parent?.dismiss(animated: true, completion: nil)
    }
    
    func cityElementSelectDidSelect(_ dataSource: CityElementSelectDataSource) {
        parent?.dismiss(animated: true, completion: nil)
        let keyword = dataSource.selectedCity ?? "全国"
        cityFilterLbl.text = keyword
    }
}

extension ActivityNearByListController: BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate {
    
    func didUpdate(_ userLocation: BMKUserLocation!) {
        location = userLocation.location.coordinate
        if locDes == nil {
            fetchLocDescription(forLoc: location!)
        }
        if data.count == 0 && !self.initFetched {
            initFetched = true
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: { 
                self.refreshView.startRefreshing()
            })
        }
    }
    
    func fetchLocDescription(forLoc loc: CLLocationCoordinate2D) {
        let option = BMKReverseGeoCodeOption()
        option.reverseGeoPoint = loc
        let res = geoSearch.reverseGeoCode(option)
        if !res {
            locDes = "\(loc.latitude), \(loc.longitude)"
        }
    }
    
    func onGetReverseGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        if error == BMK_SEARCH_NO_ERROR && result.address.length > 0 {
            locDes = LS("上次刷新位置: ") +  result.address
        } else {
            locDes = "\(location!.latitude), \(location!.longitude)"
        }
    }
}
