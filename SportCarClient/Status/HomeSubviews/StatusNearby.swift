//
//  StatusNearby.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/25.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Alamofire

class StatusNearbyController: StatusBasicController, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate {
    
    var locationService: BMKLocationService!
    var geoSearch: BMKGeoCodeSearch!
    
    var location: CLLocationCoordinate2D?
    var locDes: String? {
        didSet {
            refreshView.pullingLbl.text = locDes
        }
    }
    
    var refreshView: SSPullToRefresh!
    weak var request: Request?
    
    var initFetched: Bool = false
    
    deinit {
        refreshView.scrollView = nil
        refreshView = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myRefreshControl?.removeFromSuperview()
        myRefreshControl = nil
        refreshView = SSPullToRefresh()
        refreshView.addToSrollView(tableView, action: {[weak self] in
            self?.loadLatestData()
            })
        refreshView.pullingLbl.text = LS("这里显示当前地址")
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
        geoSearch.delegate = self
        locationService.stopUserLocationService()
    }
    
    override func loadMoreData() {
        if location == nil {
            return
        }
    }
    
    override func loadLatestData() {
        guard let location = location else {
            refreshView.endRefreshing()
            return
        }
        if let req = request {
            req.cancel()
        }
        request = StatusRequester.sharedInstance.getNearByStatus(Date(), opType: "more", lat: location.latitude, lon: location.longitude, distance: 30000, onSuccess: { (json) in
            self.fetchLocDescription(location)
            self.refreshView.endRefreshing()
            self.status.removeAll()
            self.jsonDataHandler(json!)
            self.tableView.reloadData()
            }) { (code) in
                self.refreshView.endRefreshing()
                self.showToast(LS("网络连接错误"))
        }
    }
    
    func didUpdate(_ userLocation: BMKUserLocation!) {
        location = userLocation.location.coordinate
        if locDes == nil {
            fetchLocDescription(location!)
        }
        if self.status.count == 0 && !self.initFetched {
            initFetched = true
            let delay = DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delay, execute: { 
                self.refreshView.startRefreshing()
            })
        }
    }
    
    func fetchLocDescription(_ loc: CLLocationCoordinate2D) {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let s = self.status[(indexPath as NSIndexPath).row]
        let cell =  tableView.cellForRow(at: indexPath)
        let pos = cell!.frame.origin.y - tableView.contentOffset.y + 10
        let detail = StatusDetailController(status: s, background: getScreenShot(), initPos: pos, initHeight: cell!.frame.height)
        detail.list = tableView
        detail.indexPath = indexPath
        self.homeController?.navigationController?.pushViewController(detail, animated: false)
    }
    
    func getScreenShot() -> UIImage{
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, true, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: -self.tableView.contentOffset.y)
        self.view.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
