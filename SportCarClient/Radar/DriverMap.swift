//
//  DriverMap.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/23.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Mapbox
import Spring
import Alamofire


class RadarDriverMapController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, RadarFilterDelegate {
    var radarHome: RadarHomeController?
    /// 待使用的markers
    var markerPool: [UserOnMapView] = []
    /// 当前可见的marker
    var visibleMarkers: [UserOnMapView] = []
    /// 用户数据和marker的绑定关系
    var userMarkerMapping: [String: UserOnMapView] = [:]
    
    var map: MGLMapView!
    
    var userList: UITableView!
    var showUserListBtn: UIButton!
    var showUserListBtnIcon: UIImageView!
    
    var mapFilter: RadarFilterController!
    var mapNav: BlackBarNavigationController!
    var mapFilterView: UIView!
    
    var locationManager: CLLocationManager!
    ///
    var updator: CADisplayLink!
    var usrLocMarker: UserMapLocationManager!
    var userLocation: CLLocation?
    
    var locationUpdatingToServer: Bool = false
    var locationUpdatingRequest: Request?
    var manualStopUpdating: Bool = false {
        didSet {
            if manualStopUpdating {
                locationManager.stopUpdatingLocation()
                locationUpdatingRequest?.cancel()
                locationUpdatingToServer = false
            }else {
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        createSubviews()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func createSubviews() {
        map = MGLMapView(frame: CGRectZero, styleURL: kMapStyleURL)
        map.delegate = self
        self.view.addSubview(map)
        map.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
        //
        usrLocMarker = UserMapLocationManager(size: CGSizeMake(400, 400))
        map.addSubview(usrLocMarker)
        usrLocMarker.userInteractionEnabled = false
        usrLocMarker.center = self.view.center
        //
        userList = UITableView(frame: CGRectZero, style: .Plain)
        userList.separatorStyle = .None
        userList.rowHeight = 90
        userList.delegate = self
        userList.dataSource = self
        self.view.addSubview(userList)
        userList.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(self.view)
            make.left.equalTo(self.view)
            make.height.equalTo(self.view.frame.height - 100)
            make.top.equalTo(self.view.snp_bottom)
        }
        userList.registerClass(DriverMapUserCell.self, forCellReuseIdentifier: "cell")
        //
        showUserListBtn = UIButton()
        showUserListBtn.tag = 0
        showUserListBtn.backgroundColor = UIColor(red: 0.157, green: 0.173, blue: 0.184, alpha: 1)
        showUserListBtn.layer.shadowColor = UIColor.blackColor().CGColor
        showUserListBtn.layer.shadowRadius = 2
        showUserListBtn.layer.shadowOpacity = 0.5
        showUserListBtn.layer.shadowOffset = CGSizeMake(0, 5)
        showUserListBtn.layer.cornerRadius = 4
        showUserListBtn.clipsToBounds = false
        showUserListBtn.addTarget(self, action: "showUserBtnPressed", forControlEvents: .TouchUpInside)
        self.view.addSubview(showUserListBtn)
        showUserListBtn.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(userList.snp_top).offset(-15)
            make.right.equalTo(self.view).offset(-15)
            make.size.equalTo(CGSizeMake(125, 50))
        }
        //
        showUserListBtnIcon = UIImageView(image: UIImage(named: "user_list_invoke"))
        showUserListBtn.addSubview(showUserListBtnIcon)
        showUserListBtnIcon.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        showUserListBtnIcon.bounds = CGRectMake(0, 0, 20, 20)
        showUserListBtnIcon.center = CGPointMake(27, 25)
        //
        let btnLbl = UILabel()
        showUserListBtn.addSubview(btnLbl)
        btnLbl.text = LS("浏览列表")
        btnLbl.textColor = UIColor.whiteColor()
        btnLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        btnLbl.frame = CGRectMake(47.5, 0, 60, 50)
        //
        mapFilter = RadarFilterController()
        mapFilter.delegate = self
        mapNav = BlackBarNavigationController(rootViewController: mapFilter)
        mapFilterView = mapNav.view
        self.view.addSubview(mapFilterView)
        mapFilterView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(10)
            make.left.equalTo(self.view).offset(15)
            make.size.equalTo(CGSizeMake(124, 41))
        }
        //
        let mapFilterToggleBtn = UIButton()
        self.view.addSubview(mapFilterToggleBtn)
        mapFilterToggleBtn.addTarget(self, action: "toggleMapFilter", forControlEvents: .TouchUpInside)
        mapFilterToggleBtn.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(mapFilterView)
            make.left.equalTo(self.view).offset(15)
            make.size.equalTo(CGSizeMake(124, 41))
        }
        //
        updator = CADisplayLink(target: self, selector: "userLocationUpdate")
        updator.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        updator.frameInterval = 0
        updator.paused = false
    }
    
    func userLocationUpdate() {
        if userLocation == nil {
            return
        }
        
        let p = map.convertCoordinate(userLocation!.coordinate, toPointToView: map)
        usrLocMarker.center = p
        
        updateMapContent()
    }
}


// MARK: - Delegate functions about map
extension RadarDriverMapController {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLoc = locations.last() {
            let center = CLLocationCoordinate2D(latitude: userLoc.coordinate.latitude, longitude: userLoc.coordinate.longitude)
            if userLocation == nil {
                map.setCenterCoordinate(center, zoomLevel: 12, animated: true)
            }
            userLocation = userLoc
            if !locationUpdatingToServer {
                locationUpdatingToServer = true
                self.updateUserLocationToServer()
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
        locationManager.requestLocation()
    }
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        var image = mapView.dequeueReusableAnnotationImageWithIdentifier("user")
        if image == nil {
            image = MGLAnnotationImage(image: UIImage(named: "map_default_marker")!, reuseIdentifier: "user")
        }
        
        return image
    }
}

// MARK: - Marker的重复利用
extension RadarDriverMapController {
    
    func dequeueMarker() -> UserOnMapView {
        if markerPool.count == 0 {
            // 否则创建一个新的
            let newMarker = UserOnMapView(size: CGSizeMake(65, 65))
            newMarker.addTarget(self, action: "markerPressed:", forControlEvents: .TouchUpInside)
            visibleMarkers.append(newMarker)
            map.addSubview(newMarker)
            map.bringSubviewToFront(usrLocMarker)
            return newMarker
        }else {
            let marker = markerPool.first()!
            markerPool.removeAtIndex(0)
            visibleMarkers.append(marker)
            map.addSubview(marker)
            map.bringSubviewToFront(usrLocMarker)
            return marker
        }
    }
    
    func recycleMarker(marker: UserOnMapView) {
        if !visibleMarkers.contains(marker) {
            return
        }
        marker.removeFromSuperview()
        visibleMarkers.remove(marker)
        markerPool.append(marker)
        userMarkerMapping[marker.user!.userID!] = nil
    }
    
    func markerPressed(sender: UserOnMapView) {
        let user = sender.user
        if user == nil {
            return
        }
        if user?.userID == User.objects.hostUser()?.userID {
            let detail = PersonBasicController(user: user!)
            radarHome?.navigationController?.pushViewController(detail, animated: true)
        }else {
            let detail = PersonOtherController(user: user!)
            radarHome?.navigationController?.pushViewController(detail, animated: true)
        }
    }
}

// MARK: - 网络&数据
extension RadarDriverMapController {
    
    /**
     更新地图显示内容
     */
    func updateMapContent() {
        var markerToBeRecycled: [UserOnMapView] = []
        for marker in self.visibleMarkers {
            // 更新位置
            let center = map.convertCoordinate(marker.coordinate!, toPointToView: map)
            marker.center = center
            
            let containerRect = CGRectMake(-map.bounds.width, -map.bounds.height, map.bounds.width * 3, map.bounds.height * 3)
            if !CGRectContainsRect(containerRect, marker.frame) {
                // 如果已经离开了当前画面，回收之
                
                markerToBeRecycled.append(marker)
            }
        }
        // 实际回收工作
        markerToBeRecycled.each { (marker) -> () in
            self.recycleMarker(marker)
        }
    }
    
    /**
     更新用户的位置
     */
    func updateUserLocationToServer() {
        if locationUpdatingToServer == false || manualStopUpdating{
            return
        }
        if userLocation == nil {
            assertionFailure()
        }
        print("dunag")
        let requester = RadarRequester.requester
        locationUpdatingToServer = true
        
        let mapBounds = map.visibleCoordinateBounds
        let scanCenter = CLLocationCoordinate2D(latitude: (mapBounds.ne.latitude + mapBounds.sw.latitude) / 2, longitude: (mapBounds.ne.longitude + mapBounds.sw.longitude) / 2 )
        
        let loc1 = CLLocation(latitude: mapBounds.sw.latitude, longitude: mapBounds.sw.longitude)
        let loc2 = CLLocation(latitude: mapBounds.ne.latitude, longitude: mapBounds.ne.longitude)
        let distance = loc1.distanceFromLocation(loc2)
        
        locationUpdatingRequest = requester.getRadarData(scanCenter, filterDistance: distance, onSuccess: { (json) -> () in
            // 当前正在显示的用户
            var existingUsers = Array(self.userMarkerMapping.keys)
            for data in json!.arrayValue {
                // 创建用户对象
                let user: User = User.objects.create(data).value!
                let userID = user.userID!
                
                if let marker = self.userMarkerMapping[userID] {
                    // 用户已经在，则直接修改其数据
                    existingUsers.remove(userID)
                    marker.user = user
                    let loc = data["loc"]
                    marker.coordinate = CLLocationCoordinate2D(latitude: loc["lat"].doubleValue, longitude: loc["lon"].doubleValue)
                }else{
                    // 用户不存在，添加之
                    let marker = self.dequeueMarker()
                    marker.user = user
                    let loc = data["loc"]
                    marker.coordinate = CLLocationCoordinate2D(latitude: loc["lat"].doubleValue, longitude: loc["lon"].doubleValue)
                    self.userMarkerMapping[userID] = marker
                }
            }
            self.performSelector("updateUserLocationToServer", withObject: nil, afterDelay: 1)
            //
            }) { (code) -> () in
                print(code)
                self.performSelector("updateUserLocationToServer", withObject: nil, afterDelay: 1)
        }
//        requester.updateCurrentLocation(userLocation!.coordinate, onSuccess: { (json) -> () in
//            self.performSelector("updateUserLocationToServer", withObject: nil, afterDelay: 1)
//            }) { (code) -> () in
//                print(code)
//                self.locationUpdatingToServer = false
//        }
    }
}

// MARK: - 关于用户列表显示
extension RadarDriverMapController {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleMarkers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! DriverMapUserCell
        let marker = visibleMarkers[indexPath.row]
        cell.user = marker.user
        cell.hostLoc = self.userLocation!
        cell.userLoc = CLLocation(latitude: marker.coordinate!.latitude, longitude: marker.coordinate!.longitude)
        cell.loadDataAndUpdateUI()
        return cell
    }
    
    func showUserBtnPressed() {
        if showUserListBtn.tag == 0 {
            userList.snp_remakeConstraints { (make) -> Void in
                make.right.equalTo(self.view)
                make.left.equalTo(self.view)
                make.height.equalTo(self.view.frame.height - 100)
                make.bottom.equalTo(self.view.snp_bottom).offset(90)
            }
            SpringAnimation.spring(0.6, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.showUserListBtnIcon.transform = CGAffineTransformIdentity
            })
            userList.reloadData()
            showUserListBtn.tag = 1
        }else {
            userList.snp_remakeConstraints { (make) -> Void in
                make.right.equalTo(self.view)
                make.left.equalTo(self.view)
                make.height.equalTo(self.view.frame.height - 100)
                make.top.equalTo(self.view.snp_bottom)
            }
            SpringAnimation.spring(0.6, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.showUserListBtnIcon.transform = CGAffineTransformMakeRotation(CGFloat( M_PI))
            })
            showUserListBtn.tag = 0
        }
        
    }
}

extension RadarDriverMapController {
    func toggleMapFilter() {
        
        if mapNav.viewControllers.count > 1 {
            mapNav.popToRootViewControllerAnimated(true)
            return
        }
        
        if mapFilter.expanded {
            mapFilterView.snp_remakeConstraints(closure: { (make) -> Void in
                make.top.equalTo(self.view).offset(10)
                make.left.equalTo(self.view).offset(15)
                make.size.equalTo(CGSizeMake(124, 41))
            })
        }else {
            mapFilterView.snp_remakeConstraints(closure: { (make) -> Void in
                make.top.equalTo(self.view).offset(10)
                make.left.equalTo(self.view).offset(15)
                make.size.equalTo(CGSizeMake(124, 42 * 6))
            })
        }
        mapFilter.expanded = !mapFilter.expanded
        UIView.animateWithDuration(0.3) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    func radarFilterDidChange() {
        toggleMapFilter()
    }
}