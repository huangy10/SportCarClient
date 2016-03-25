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
    var showUserListBtnIcon: UIImageView!
    
    var mapFilter: RadarFilterController!
    var mapNav: BlackBarNavigationController!
    var mapFilterView: UIView!
    ///
    
    weak var locationUpdatingRequest: Request?
    
    deinit {
        timer?.invalidate()
        print("deinit driver map")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        createSubviews()
        
        locationService = BMKLocationService()
        locationService.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationService.allowsBackgroundLocationUpdates = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        map.viewWillAppear()
        map.delegate = self
        locationService.delegate = self
        timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "getLocationData", userInfo: nil, repeats: true)
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
        showUserListBtn.layer.shadowOpacity = 0.4
        showUserListBtn.layer.shadowOffset = CGSizeMake(0, 3)
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
        mapFilterView.layer.shadowColor = UIColor.blackColor().CGColor
        mapFilterView.layer.shadowRadius = 2
        mapFilterView.layer.shadowOpacity = 0.4
        mapFilterView.layer.shadowOffset = CGSizeMake(0, 3)
        mapFilterView.layer.cornerRadius = 4
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
    }
}


// MARK: - Delegate functions about map
extension RadarDriverMapController {
    
    func getLocationData() {
        locationService.startUserLocationService()
    }
    
    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
        locationService.stopUserLocationService()
        if self.userLocation == nil {
            let annotate = UserAnnotation()
            annotate.user = User.objects.hostUser()
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
            if user.userID == User.objects.hostUserID {
                let cell = HostUserOnRadarAnnotationView(annotation: annotation, reuseIdentifier: "host")
                cell.startScan()
                return cell
            } else {
                var cell = mapView.dequeueReusableAnnotationViewWithIdentifier("user") as? UserAnnotationView
                
                if cell == nil {
                    cell = UserAnnotationView(annotation: userAnno, reuseIdentifier: "use")
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
        
        let requester = RadarRequester.requester
        let mapBounds = map.region
        let scanCenter = mapBounds.center
        
        let loc1 = CLLocation(latitude: mapBounds.center.latitude, longitude: mapBounds.center.longitude)
        let loc2 = CLLocation(latitude: mapBounds.center.latitude + mapBounds.span.latitudeDelta, longitude: mapBounds.center.longitude + mapBounds.span.longitudeDelta)
        let distance = loc1.distanceFromLocation(loc2)
        
        locationUpdatingRequest = requester.getRadarData(scanCenter, filterDistance: distance, onSuccess: { (json) -> () in
            // 当前正在显示的用户
            for data in json!.arrayValue {
                // 创建用户对象
                let user = User.objects.getOrCreate(data)
                let userID = user.userID!
                if let anno = self.userAnnos[userID] {
                    let loc = data["loc"]
                    anno.coordinate = CLLocationCoordinate2D(latitude: loc["lat"].doubleValue, longitude: loc["lon"].doubleValue)
                } else {
                    let anno = UserAnnotation()
                    anno.user = user
                    let loc = data["loc"]
                    anno.coordinate = CLLocationCoordinate2D(latitude: loc["lat"].doubleValue, longitude: loc["lon"].doubleValue)
                    self.userAnnos[userID] = anno
                    self.map.addAnnotation(anno)
                }
            }
            self.locationUpdatingRequest = nil
            }) { (code) -> () in
                print(code)
                self.locationUpdatingRequest = nil
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
        assert(user.userID != User.objects.hostUserID)
        let detail = PersonOtherController(user: user)
        radarHome?.navigationController?.pushViewController(detail, animated: true)
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