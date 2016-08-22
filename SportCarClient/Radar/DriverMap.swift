//
//  DriverMap.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/23.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Spring
import Alamofire


class RadarDriverMapController: UIViewController, UITableViewDataSource, UITableViewDelegate, RadarFilterDelegate, BMKMapViewDelegate, BMKLocationServiceDelegate {
    weak var radarHome: RadarHomeController?
    
    var map: BMKMapView!
    var userAnnotate: BMKPointAnnotation!
    var locationService: BMKLocationService!
    var userLocation: BMKUserLocation?
    var userAnnos: MyOrderedDict<String, UserAnnotation> = MyOrderedDict()
    var timer: NSTimer?
    
    var userList: UITableView!
    var showUserListBtn: UIButton!
    
    var mapFilter: RadarFilterController!
    var mapNav: BlackBarNavigationController!
    var mapFilterView: UIView!
    
    var tapper: UITapGestureRecognizer!
    ///
    
    weak var locationUpdatingRequest: Request?
    
    // Added by Woody Huang 2016.07.10
    var lastUpdate: NSDate = NSDate()
    var showOnMap: Bool = false
    weak var toast: UIView?
    
    deinit {
        timer?.invalidate()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        createSubviews()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onUserBlocked(_:)), name: kAccountBlacklistChange, object: nil)
        
        locationService = BMKLocationService()
        locationService.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//        locationService.allowsBackgroundLocationUpdates = true
    }
    
    func confirmShowOnMap() {
        showOnMap = true
        toast = showStaticToast(LS("正在定位..."))
        timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(RadarDriverMapController.getLocationData), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        map.viewWillAppear()
        map.delegate = self
        locationService.delegate = self
        if showOnMap {
            let now = NSDate()
            let timeDelta = now.timeIntervalSinceDate(self.lastUpdate)
            if timeDelta > kMaxRadarKeptTime {
                userLocation = nil
                map.removeAnnotations(map.annotations)
                userAnnos.removeAll()
                if showUserListBtn.tag == 1 {
                    userList.reloadData()
                }
            }
            timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(RadarDriverMapController.getLocationData), userInfo: nil, repeats: true)
        } else {
            showConfirmToast(LS("跑车雷达"), message: LS("这里会将您的实时位置共享给周围用户，确认继续？"), target: self, onConfirm: #selector(confirmShowOnMap))
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        map.viewWillDisappear()
        map.delegate = nil
        locationService.delegate = nil
        timer?.invalidate()
        locationUpdatingRequest?.cancel()
    }
    
    func createSubviews() {
        self.view.backgroundColor = UIColor.blackColor()
        map = BMKMapView()
        self.view.addSubview(map)
        map.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
        tapper = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        tapper.enabled = false
        map.addGestureRecognizer(tapper)
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
        self.view.addSubview(UIView)
            .config(UIColor.whiteColor())
            .addShadow(3, color: UIColor.blackColor(), opacity: 0.1, offset: CGSizeMake(0, -2))
            .layout { (make) in
                make.edges.equalTo(userList)
        }
        self.view.bringSubviewToFront(userList)
        //
        showUserListBtn = self.view.addSubview(UIButton.self)
            .config(UIColor.whiteColor())
            .config(self, selector: #selector(showUserBtnPressed))
            .toRound(20)
            .addShadow().layout({ (make) in
                make.bottom.equalTo(userList.snp_top).offset(-25)
                make.right.equalTo(self.view).offset(-20)
                make.size.equalTo(CGSizeMake(40, 40))
            })
        showUserListBtn.addSubview(UIImageView)
            .config(UIImage(named: "view_list"), contentMode: .ScaleAspectFit)
            .layout { (make) in
                make.center.equalTo(showUserListBtn)
                make.size.equalTo(showUserListBtn).dividedBy(2)
        }

        mapFilter = RadarFilterController()
        mapFilter.delegate = self
        mapNav = mapFilter.toNavWrapper()

        self.view.addSubview(mapNav.view)
        mapFilter.view.toRound(20, clipsToBound: false)
        mapFilterView = mapNav.view.addShadow()
            .layout({ (make) in
            make.bottom.equalTo(showUserListBtn)
            make.right.equalTo(showUserListBtn.snp_left).offset(-13)
            make.width.equalTo(115)
            make.height.equalTo(40)
        })

        self.view.addSubview(UIButton.self).config(self, selector: #selector(toggleMapFilter))
            .layout { (make) in
                make.top.equalTo(mapFilterView)
                make.left.equalTo(mapFilterView)
                make.size.equalTo(CGSizeMake(115, 40))
        }
    }
}


// MARK: - Delegate functions about map
extension RadarDriverMapController {
    
    func getLocationData() {
        locationService.startUserLocationService()
        
        if let toast = toast {
            hideToast(toast)
        }
    }
    
    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
        locationService.stopUserLocationService()
        if self.userLocation == nil {
            let annotate = UserAnnotation()
            annotate.user = MainManager.sharedManager.hostUser!
            annotate.coordinate = userLocation.location.coordinate
            map.addAnnotation(annotate)
//            map.setCenterCoordinate(annotate.coordinate, animated: true)
            let region = BMKCoordinateRegionMakeWithDistance(annotate.coordinate, 3000, 5000)
            map.setRegion(region, animated: true)
            userAnnotate = annotate
        }
        self.userLocation = userLocation
        userAnnotate.coordinate = userLocation.location.coordinate
        updateUserLocationToServer()
    }
    
    func mapView(mapView: BMKMapView!, viewForAnnotation annotation: BMKAnnotation!) -> BMKAnnotationView! {
        if let userAnno = annotation as? UserAnnotation {
            let user = userAnno.user
            if user.isHost {
                let cell = HostUserOnRadarAnnotationView(annotation: annotation, reuseIdentifier: "host")
                cell.startScan()
                return cell
            } else {
                var cell = mapView.dequeueReusableAnnotationViewWithIdentifier("user") as? UserAnnotationView
                
                if cell == nil {
                    cell = UserAnnotationView(annotation: userAnno, reuseIdentifier: "user")
                } else {
                    cell?.annotation = userAnno
                }
                cell?.parent = self.radarHome
                cell?.user = userAnno.user
                return cell
            }
        }
        return nil
    }
    
    func mapView(mapView: BMKMapView!, didSelectAnnotationView view: BMKAnnotationView!) {
        if let user = view.annotation as? UserAnnotation {
            radarHome?.navigationController?.pushViewController(user.user.showDetailController(), animated: true)
        }
    }
    
    func mapTapped() {
        showUserBtnPressed()
    }
}

// MARK: - 网络&数据
extension RadarDriverMapController {
    
    /**
     更新用户的位置
     */
    func updateUserLocationToServer() {
        
        guard locationUpdatingRequest == nil else {
            return
        }
        
        let requester = RadarRequester.sharedInstance
        let mapBounds = map.region
        let scanCenter = mapBounds.center
        
        let loc1 = CLLocation(latitude: mapBounds.center.latitude, longitude: mapBounds.center.longitude)
        let loc2 = CLLocation(latitude: mapBounds.center.latitude + mapBounds.span.latitudeDelta, longitude: mapBounds.center.longitude + mapBounds.span.longitudeDelta)
        let distance = loc1.distanceFromLocation(loc2)
        
        let filterType = mapFilter.getFitlerTypeString()
        let filterParam = mapFilter.getFilterParam()
        
        
        locationUpdatingRequest = requester.getRadarDataWithFilter(userLocation!.location.coordinate, scanCenter: scanCenter, filterDistance: distance, filterType: filterType, filterParam: filterParam, onSuccess: { (json) in
            // 当前正在显示的用户
            for data in json!.arrayValue {
                // 创建用户对象
                let user: User = try! MainManager.sharedManager.getOrCreate(data)
                let userID = user.ssidString
                if let anno = self.userAnnos[userID] {
                    let loc = data["loc"]
                    anno.coordinate = CLLocationCoordinate2D(latitude: loc["lat"].doubleValue, longitude: loc["lon"].doubleValue)
                } else {
                    let anno = UserAnnotation()
                    anno.user = user
                    anno.title = " "
                    let loc = data["loc"]
                    anno.coordinate = CLLocationCoordinate2D(latitude: loc["lat"].doubleValue, longitude: loc["lon"].doubleValue)
                    self.userAnnos[userID] = anno
                    self.map.addAnnotation(anno)
                }
            }
            self.locationUpdatingRequest = nil
            self.lastUpdate = NSDate()
            if self.showUserListBtn.tag == 1 {
                dispatch_async(dispatch_get_main_queue(), {
                    self.userList.reloadData()
                })
            }
            }, onError: { (code) in
                self.locationUpdatingRequest = nil
        })

//        
//        locationUpdatingRequest = requester.getRadarData(userLocation!.location.coordinate, scanCenter: scanCenter, filterDistance: distance, onSuccess: { (json) -> () in
//            // 当前正在显示的用户
//            for data in json!.arrayValue {
//                // 创建用户对象
//                let user: User = try! MainManager.sharedManager.getOrCreate(data)
//                let userID = user.ssidString
//                if let anno = self.userAnnos[userID] {
//                    let loc = data["loc"]
//                    anno.coordinate = CLLocationCoordinate2D(latitude: loc["lat"].doubleValue, longitude: loc["lon"].doubleValue)
//                } else {
//                    let anno = UserAnnotation()
//                    anno.user = user
//                    anno.title = " "
//                    let loc = data["loc"]
//                    anno.coordinate = CLLocationCoordinate2D(latitude: loc["lat"].doubleValue, longitude: loc["lon"].doubleValue)
//                    self.userAnnos[userID] = anno
//                    self.map.addAnnotation(anno)
//                }
//            }
//            self.locationUpdatingRequest = nil
//            self.lastUpdate = NSDate()
//            if self.showUserListBtn.tag == 1 {
//                dispatch_async(dispatch_get_main_queue(), { 
//                    self.userList.reloadData()
//                })
//            }
//            }) { (code) -> () in
//                self.locationUpdatingRequest = nil
//        }
    }
    
    func onUserBlocked(notification: NSNotification) {
//        guard let user = notification.userInfo?[kUserKey] as? User else {
//            assertionFailure()
//            return
//        }
        let user = notification.userInfo![kUserKey] as! User
        let blockStatus = notification.userInfo![kAccountBlackStatusKey] as! String
        if blockStatus == kAccountBlackStatusBlocked {
            if let anno = userAnnos[user.ssidString] {
                userAnnos[user.ssidString] = nil
                map.removeAnnotation(anno)
                if showUserListBtn.tag == 1 {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.userList.reloadData()
                    })
                }
            }
        }
    }
}

// MARK: - 关于用户列表显示
extension RadarDriverMapController {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userAnnos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! DriverMapUserCell
        let anno = userAnnos.valueForIndex(indexPath.row)
        cell.user = anno?.user
        cell.hostLoc = CLLocation(latitude: userAnnotate.coordinate.latitude, longitude: userAnnotate.coordinate.longitude)
        cell.userLoc = CLLocation(latitude: anno!.coordinate.latitude, longitude: anno!.coordinate.longitude)
        cell.loadDataAndUpdateUI()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let anno = userAnnos.valueForIndex(indexPath.row)
        guard let user = anno?.user else {
            assertionFailure()
            return
        }
        assert(!user.isHost)
        let detail = PersonOtherController(user: user)
        radarHome?.navigationController?.pushViewController(detail, animated: true)
    }
    
    func showUserBtnPressed() {
        if showUserListBtn.tag == 0 {
            // show the list
            userList.snp_remakeConstraints { (make) -> Void in
                make.right.equalTo(self.view)
                make.left.equalTo(self.view)
                make.height.equalTo(self.view.frame.height - 100)
                make.bottom.equalTo(self.view.snp_bottom).offset(90)
            }
            SpringAnimation.spring(0.6, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
            if mapFilter.expanded {
                toggleMapFilter()
            }
            userList.reloadData()
            showUserListBtn.tag = 1
            tapper.enabled = true
        }else {
            userList.snp_remakeConstraints { (make) -> Void in
                make.right.equalTo(self.view)
                make.left.equalTo(self.view)
                make.height.equalTo(self.view.frame.height - 100)
                make.top.equalTo(self.view.snp_bottom)
            }
            SpringAnimation.spring(0.6, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
            showUserListBtn.tag = 0
            tapper.enabled = false
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
            // hide the list
            mapFilterView.snp_remakeConstraints(closure: { (make) -> Void in
                make.bottom.equalTo(showUserListBtn)
                make.right.equalTo(showUserListBtn.snp_left).offset(-13)
                make.width.equalTo(115)
                make.height.equalTo(40)
            })
            UIView.animateWithDuration(0.3) { () -> Void in
                self.view.layoutIfNeeded()
                self.mapFilter.view.toRound(20)
                self.mapFilter.marker.transform = CGAffineTransformIdentity
            }
        }else {
            // dispaly the list
            mapFilterView.snp_remakeConstraints(closure: { (make) -> Void in
                make.bottom.equalTo(showUserListBtn)
                make.right.equalTo(showUserListBtn.snp_left).offset(-13)
                make.width.equalTo(115)
                make.height.equalTo(40 * 6)
            })
            
            UIView.animateWithDuration(0.3) { () -> Void in
                self.view.layoutIfNeeded()
                self.mapFilter.view.toRound(5)
                self.mapFilter.marker.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            }
        }
        mapFilter.expanded = !mapFilter.expanded
        
    }
    
    func radarFilterDidChange() {
        toggleMapFilter()
    }
}