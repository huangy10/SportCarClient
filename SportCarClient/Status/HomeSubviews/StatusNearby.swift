//
//  StatusNearby.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/25.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


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
    
    deinit {
        refreshView.scrollView = nil
        refreshView = nil
        print("status nearby deinit")
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        locationService.delegate = self
        geoSearch.delegate = self
        locationService.startUserLocationService()
    }
    
    override func viewWillDisappear(animated: Bool) {
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
        
        StatusRequester.SRRequester.getNearByStatus(NSDate(), opType: "more", lat: location.latitude, lon: location.longitude, distance: 15000, onSuccess: { (json) in
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
    
    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
        location = userLocation.location.coordinate
        if locDes == nil {
            fetchLocDescription(location!)
        }
    }
    
    func fetchLocDescription(loc: CLLocationCoordinate2D) {
        let option = BMKReverseGeoCodeOption()
        option.reverseGeoPoint = loc
        let res = geoSearch.reverseGeoCode(option)
        if !res {
            locDes = "\(loc.latitude), \(loc.longitude)"
        }
    }
    func onGetReverseGeoCodeResult(searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        if error == BMK_SEARCH_NO_ERROR && result.address.length > 0 {
            locDes = LS("上次刷新位置: ") +  result.address
        } else {
            locDes = "\(location!.latitude), \(location!.longitude)"
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let s = self.status[indexPath.row]
        let cell =  tableView.cellForRowAtIndexPath(indexPath)
        let pos = cell!.frame.origin.y - tableView.contentOffset.y + 10
        let detail = StatusDetailController(status: s, background: getScreenShot(), initPos: pos, initHeight: cell!.frame.height)
        detail.list = tableView
        detail.indexPath = indexPath
        self.homeController?.navigationController?.pushViewController(detail, animated: false)
    }
    
    func getScreenShot() -> UIImage{
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, true, UIScreen.mainScreen().scale)
        let context = UIGraphicsGetCurrentContext()!
        CGContextTranslateCTM(context, 0, -self.tableView.contentOffset.y)
        self.view.layer.renderInContext(context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}