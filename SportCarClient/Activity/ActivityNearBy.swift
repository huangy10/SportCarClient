//
//  ActivityNearBy.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/14.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Alamofire


class ActivityNearByController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CityElementSelectDelegate {
    
    weak var home: RadarHomeController!
    
    var acts: [Activity] = []
    
    var map: BMKMapView!
    var actAnno: BMKPointAnnotation?
    var userAnno: BMKPointAnnotation?
    var userLocation: BMKUserLocation?
    var locationService: BMKLocationService!
    
    var actsBoard: UICollectionView!
    var pageCount: UIPageControl!
    var _prePage: Int = 0
    var showReload: Bool = true
    
    var cityFilterBtn: UIButton!
    var cityFilterLbl: UILabel!
    
    var nearByOnly: Bool {
        return cityFilterLbl.text == "全国"
    }
    
    var ongoingRequest: Request?
    
//    var cityFilter: UIButton!
//    var cityFilterLbl: UILabel!
//    
//    var cityFilterType: String = "全国"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
        
        actsBoard.register(ActivityCell.self, forCellWithReuseIdentifier: ActivityCell.reuseIdentifier)
        // 启动位置跟踪
        locationService = BMKLocationService()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        map.delegate = self
        if showReload {
            userLocation = nil
            loadActivities()
        } else {
            showReload = true
        }
        locationService.delegate = self
        locationService.startUserLocationService()
        map.viewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        map.delegate = nil
        locationService.delegate = nil
        locationService.stopUserLocationService()
        map.viewWillDisappear()
    }
    
    func createSubviews() {
        let superview = self.view!
        superview.backgroundColor = UIColor.black
        //
        map = BMKMapView()
        superview.addSubview(map)
        map.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        //
        pageCount = UIPageControl()
        pageCount.numberOfPages = 1
        superview.addSubview(pageCount)
        pageCount.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(superview).offset(5)
            make.centerX.equalTo(superview)
        }
        //
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 170, height: 200)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0.01
        actsBoard = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        actsBoard.backgroundColor = UIColor.clear
        actsBoard.delegate = self
        actsBoard.dataSource = self
        let sideInset = (UIScreen.main.bounds.width - 170) / 2
        actsBoard.contentInset = UIEdgeInsetsMake(0, sideInset, 20, sideInset)
        superview.addSubview(actsBoard)
        actsBoard.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(superview)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.height.equalTo(220)
        }
        
        configureCityFilter()
    }
    
    func configureCityFilter() {
        cityFilterBtn = view.addSubview(UIButton.self)
            .config(self, selector: #selector(cityFilterBtnPressed)).config(UIColor.white)
            .addShadow()
            .toRound(20)
            .layout({ (make) in
                make.right.equalTo(view).offset(-13)
                make.top.equalTo(view).offset(13)
                make.size.equalTo(CGSize(width: 120, height: 40))
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
        home.present(select.toNavWrapper(), animated: true, completion: nil)
    }
    
    //
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageCount.numberOfPages = acts.count
        return acts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActivityCell.reuseIdentifier, for: indexPath) as! ActivityCell
        cell.act = acts[(indexPath as NSIndexPath).row]
        //
        let cellWidth: CGFloat = 170
        let offset = cell.frame.origin.x - collectionView.contentOffset.x + cellWidth / 2
        let absOffsetRatio = abs(offset - collectionView.frame.width / 2) / (collectionView.frame.width / 2)
        let scaleRatio = 1 - absOffsetRatio * 0.05
        var trans = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio)
        trans = trans.translatedBy(x: 0, y: cell.frame.height * (1 - scaleRatio) / 2)
        cell.container.transform = trans
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let act = acts[(indexPath as NSIndexPath).row]
        let detail = ActivityDetailController(act: act)
        showReload = false
        home.navigationController?.pushViewController(detail, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let cells = actsBoard.visibleCells as! [ActivityCell]
        let cellWidth: CGFloat = 170
        var maxCell: UICollectionViewCell?
        var maxRatio: CGFloat = 0
        for cell in cells {
            let offset = cell.frame.origin.x - scrollView.contentOffset.x + cellWidth / 2
            let absOffsetRatio = abs(offset - scrollView.frame.width / 2) / (scrollView.frame.width / 2)
            let scaleRatio = 1 - absOffsetRatio * 0.05
            if maxRatio < scaleRatio {
                maxRatio = scaleRatio
                maxCell = cell
            }
            var trans = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio)
            trans = trans.translatedBy(x: 0, y: cell.frame.height * (1 - scaleRatio) / 2)
            cell.container.transform = trans
        }
        if maxCell != nil {
            let temp = (actsBoard.indexPath(for: maxCell!)! as NSIndexPath).row
            if pageCount.currentPage != temp {
                pageCount.currentPage = temp
                activityFocusedChanged()
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let cells = actsBoard.visibleCells
        let cellWidth: CGFloat = 170
        var minOffset: CGFloat = 1000
        for cell in cells {
            let offset = cell.frame.origin.x - scrollView.contentOffset.x + cellWidth / 2 - scrollView.frame.width / 2
            if abs(offset) < abs(minOffset) {
                minOffset = offset
            }
        }
        var offset = scrollView.contentOffset
        offset.x += minOffset
        scrollView.setContentOffset(offset, animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let cells = actsBoard.visibleCells
        let cellWidth: CGFloat = 170
        var minOffset: CGFloat = 1000
        for cell in cells {
            let offset = cell.frame.origin.x - scrollView.contentOffset.x + cellWidth / 2 - scrollView.frame.width / 2
            if abs(offset) < abs(minOffset) {
                minOffset = offset
            }
        }
        if abs(minOffset) <= 0.1 {
            return
        }
        var offset = scrollView.contentOffset
        offset.x += minOffset
        scrollView.setContentOffset(offset, animated: true)
//        if _prePage != pageCount.currentPage {
//            activityFocusedChanged()
//            _prePage = pageCount.currentPage
//        }
    }
    
    func onActivityManuallyEnded(_ notification: Foundation.Notification) {
        let name = notification.name.rawValue
        if name == kActivityManualEndedNotification {
            if let act = (notification as NSNotification).userInfo?[kActivityKey] as? Activity {
                let originLen = acts.count
                acts = acts.filter({$0.ssid != act.ssid})
                if acts.count < originLen {
                    actsBoard.reloadData()
                }
            }
        }
    }
    
    func cityElementSelectDidCancel() {
        home.dismiss(animated: true, completion: nil)
    }
    
    func cityElementSelectDidSelect(_ dataSource: CityElementSelectDataSource) {
        home.dismiss(animated: true, completion: nil)
        let keyword = dataSource.selectedCity ?? "全国"
        cityFilterLbl.text = keyword
        
//        loadActivities()
    }
}

// MARK: - About map
extension ActivityNearByController: BMKMapViewDelegate, BMKLocationServiceDelegate {
    
    /**
    当前focus的活动发生了变化
    */
    func activityFocusedChanged() {
        let focusedActivity = acts[pageCount.currentPage]
        let center = focusedActivity.location!.coordinate
        map.setCenter(center, animated: true)
        if actAnno != nil {
            map.removeAnnotation(actAnno!)
        }
        actAnno = BMKPointAnnotation()
        actAnno?.coordinate = center
        map.addAnnotation(actAnno)
    }
    
    func didUpdate(_ userLocation: BMKUserLocation!) {
        if self.userLocation == nil {
            if userAnno == nil {
                userAnno = BMKPointAnnotation()
                map.addAnnotation(userAnno!)
            }
            userAnno?.coordinate = userLocation.location.coordinate
            let region = BMKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 3000, 5000)
            map.setRegion(region, animated: true)
            map.setCenter(userLocation.location.coordinate, animated: true)
            if nearByOnly {
                self.userLocation = userLocation
                loadActivities()
            }
//            ActivityRequester.sharedInstance.getNearByActivities(userLocation.location.coordinate, queryDistance: 10000, cityLimit: cityFilterLbl.text!, skip: 0, limit: 10, onSuccess: { (json) -> () in
//                self.acts.removeAll()
//                for data in json!.arrayValue {
//                    let act: Activity = try! MainManager.sharedManager.getOrCreate(data)
//                    self.acts.append(act)
//                }
//                self.actsBoard.reloadData()
//                self.pageCount.currentPage = 0
//                if self.acts.count > 0 {
//                    self.activityFocusedChanged()
//                }
//                }, onError: { (code) -> () in
//            })
        }
        userAnno?.coordinate = userLocation.location.coordinate
        self.userLocation = userLocation
    }
    
    func loadActivities() {
        let userLoc: CLLocationCoordinate2D
        if let loc = userLocation , nearByOnly {
            userLoc = loc.location.coordinate
        } else if !nearByOnly {
            // 此时为按地址筛选，这里的userLoc只需要提供一个fake的就可以了
            userLoc = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        } else {
            return
        }
        
        _ = ActivityRequester.sharedInstance.getNearByActivities(userLoc, queryDistance: 10000, cityLimit: cityFilterLbl.text!, skip: 0, limit: 10, onSuccess: { (json) -> () in
            self.acts.removeAll()
            for data in json!.arrayValue {
                let act: Activity = try! MainManager.sharedManager.getOrCreate(data)
                self.acts.append(act)
            }
            self.actsBoard.reloadData()
            self.pageCount.currentPage = 0
            if self.acts.count > 0 {
                self.activityFocusedChanged()
            }
            }, onError: { (code) -> () in
                self.showToast(LS("网络访问错误:\(code)"))
        })
    }
    
    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        if userAnno == annotation as? BMKPointAnnotation {
            let view = HostUserOnRadarAnnotationView(annotation: annotation, reuseIdentifier: "host")
            view?.startScan()
            return view
        } else {
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "act") as? UserSelectAnnotationView
            if view == nil {
                view = UserSelectAnnotationView(annotation: annotation, reuseIdentifier: "act")
            }
            return view
        }
    }
}

