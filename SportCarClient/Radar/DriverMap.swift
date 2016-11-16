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
import Dollar


class RadarDriverMapController: UIViewController, RadarFilterDelegate {
//    weak var radarHome: RadarHomeController?
    
    var map: BMKMapView!
    var mapOp: MapOpertaionView!
    var userAnnotate: BMKPointAnnotation!
    var locationService: BMKLocationService!
    var userLocation: BMKUserLocation?
    var userAnnos: MyOrderedDict<String, UserAnnotation> = MyOrderedDict()
    var timer: Timer?
    
    var userList: UITableView!
    var showUserListBtn: UIButton!
    
    var mapFilter: RadarFilterController!
    var mapNav: BlackBarNavigationController!
    var mapFilterView: UIView!
    
    var tapper: UITapGestureRecognizer!
    ///
    
    weak var locationUpdatingRequest: Request?
    
    // Added by Woody Huang 2016.07.10
    var lastUpdate: Date = Date()
    var showOnMap: Bool = false
    weak var confirmToast: ConfirmToastPresentationController?
    weak var toast: UIView?
    var zoomLevelToastDisplayed: Bool = false
    var mapAnnoEmpty: Bool = false
    
    // about cluster
    let clusteringManager = FBClusteringManager()
    
    deinit {
        print("deinit radar map")
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        createSubviews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUserBlocked(_:)), name: NSNotification.Name(rawValue: kAccountBlacklistChange), object: nil)
        
        locationService = BMKLocationService()
        locationService.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//        locationService.allowsBackgroundLocationUpdates = true
    }
    
    func confirmShowOnMap() {
        showOnMap = true
        toast = showStaticToast(LS("正在定位..."))
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(RadarDriverMapController.getLocationData), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        map.viewWillAppear()
        map.delegate = self
        locationService.delegate = self
        if showOnMap {
            let now = Date()
            let timeDelta = now.timeIntervalSince(self.lastUpdate)
            if timeDelta > kMaxRadarKeptTime {
                userLocation = nil
                map.removeAnnotations(map.annotations)
                userAnnos.removeAll()
                if showUserListBtn.tag == 1 {
                    userList.reloadData()
                }
            }
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(RadarDriverMapController.getLocationData), userInfo: nil, repeats: true)
        } else if confirmToast == nil {
            confirmToast = showConfirmToast(LS("跑车雷达"), message: LS("这里会将您的实时位置共享给周围用户，确认继续？\n如需隐身，请进入：个人-设置-定位可见 中设置隐身"), target: self, onConfirm: #selector(confirmShowOnMap))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        map.viewWillDisappear()
        map.delegate = nil
        locationService.delegate = nil
        timer?.invalidate()
        locationUpdatingRequest?.cancel()
    }
    
    func createSubviews() {
        self.view.backgroundColor = UIColor.black
        map = BMKMapView()
        map.showMapScaleBar = true
        self.view.addSubview(map)
        map.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
        tapper = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        tapper.isEnabled = false
        map.addGestureRecognizer(tapper)
        //
        userList = UITableView(frame: CGRect.zero, style: .plain)
        userList.separatorStyle = .none
        userList.rowHeight = 90
        userList.delegate = self
        userList.dataSource = self
        self.view.addSubview(userList)
        userList.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(self.view)
            make.left.equalTo(self.view)
            make.height.equalTo(self.view.frame.height - 190)
            make.top.equalTo(self.view.snp.bottom)
        }
        userList.register(DriverMapUserCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(UIView.self)
            .config(UIColor.white)
            .addShadow(3, color: UIColor.black, opacity: 0.1, offset: CGSize(width: 0, height: -2))
            .layout { (make) in
                make.edges.equalTo(userList)
        }
        self.view.bringSubview(toFront: userList)
        //
        showUserListBtn = self.view.addSubview(UIButton.self)
            .config(UIColor.white)
            .config(self, selector: #selector(showUserBtnPressed))
            .toRound(20)
            .addShadow().layout({ (make) in
                make.bottom.equalTo(userList.snp.top).offset(-25)
                make.right.equalTo(self.view).offset(-20)
                make.size.equalTo(CGSize(width: 40, height: 40))
            })
        showUserListBtn.addSubview(UIImageView.self)
            .config(UIImage(named: "view_list"), contentMode: .scaleAspectFit)
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
            make.right.equalTo(showUserListBtn.snp.left).offset(-13)
            make.width.equalTo(115)
            make.height.equalTo(40)
        })

        self.view.addSubview(UIButton.self).config(self, selector: #selector(toggleMapFilter))
            .layout { (make) in
                make.top.equalTo(mapFilterView)
                make.left.equalTo(mapFilterView)
                make.size.equalTo(CGSize(width: 115, height: 40))
        }
        
        configureMapOps()
    }
    
    func configureMapOps() {
        mapOp = MapOpertaionView()
        mapOp.map = map
        mapOp.delegate = self
        view.addSubview(mapOp)
        mapOp.snp.makeConstraints { (mk) in
            mk.bottom.equalTo(showUserListBtn)
            mk.left.equalTo(view).offset(15)
        }
    }
}


// MARK: - Delegate functions about map
extension RadarDriverMapController: BMKMapViewDelegate, BMKLocationServiceDelegate {
    
    func getLocationData() {
        locationService.startUserLocationService()
        
        if let toast = toast {
            hideToast(toast)
        }
    }
    
    func didUpdate(_ userLocation: BMKUserLocation!) {
        locationService.stopUserLocationService()
        if self.userLocation == nil {
            let annotate = UserAnnotation()
            clusteringManager.userAnno = annotate
            annotate.user = MainManager.sharedManager.hostUser!
            annotate.coordinate = userLocation.location.coordinate
            map.addAnnotation(annotate)
//            map.setCenterCoordinate(annotate.coordinate, animated: true)
            let region = BMKCoordinateRegionMakeWithDistance(annotate.coordinate, 3000, 5000)
            map.setRegion(region, animated: true)
            userAnnotate = annotate
//            clusteringManager.addAnnotations([annotate])
        }
        self.userLocation = userLocation
        userAnnotate.coordinate = userLocation.location.coordinate
        updateUserLocationToServer()
    }
    
    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        if annotation is FBAnnotationCluster {
            let reuseId = "cluster"
            var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? ClusterAnnotationView
            if clusterView == nil {
                clusterView = ClusterAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                clusterView?.delegate = self
            } else {
                clusterView?.annotation = annotation
                clusterView?.resetCountLblVal()
            }
            return clusterView
        }
        if let userAnno = annotation as? UserAnnotation {
            let user = userAnno.user
            if (user?.isHost)! {
                let cell = HostUserOnRadarAnnotationView(annotation: annotation, reuseIdentifier: "host")
                cell?.startScan()
                return cell
            } else {
                var cell = mapView.dequeueReusableAnnotationView(withIdentifier: "user") as? UserAnnotationView
                
                if cell == nil {
                    cell = UserAnnotationView(annotation: userAnno, reuseIdentifier: "user")
                } else {
                    cell?.annotation = userAnno
                }
                cell?.parent = parent
                cell?.user = userAnno.user
                return cell
            }
        }
        return nil
    }
    
    func mapView(_ mapView: BMKMapView!, regionDidChangeAnimated animated: Bool) {
        if map.zoomLevel < 11 && !zoomLevelToastDisplayed {
            zoomLevelToastDisplayed = true
            showToast(LS("跑车范仅显示你附近30km的用户"))
        } else if map.zoomLevel > 11 {
            zoomLevelToastDisplayed = false
        }
        reloadMapClusterPins()
    }
    
    func reloadMapClusterPins() {
        DispatchQueue.global(qos: .userInitiated).async {
            let mapBoundsWidth = Double(self.map.bounds.width)
            let mapRectWidth = self.map.visibleMapRect.size.width
            let scale = mapBoundsWidth / mapRectWidth
            let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.map.visibleMapRect, withZoomScale: scale)
            self.mapAnnoEmpty = annotationArray.count == 0
            DispatchQueue.main.async(execute: {
                self.clusteringManager.displayAnnotations(annotationArray, onMapView: self.map)
            })
        }
    }
    
    func mapView(_ mapView: BMKMapView!, didSelect view: BMKAnnotationView!) {
        if let user = view.annotation as? UserAnnotation {
            parent?.navigationController?.pushViewController(user.user.showDetailController(), animated: true)
        }
    }
    
    func mapTapped() {
        showUserBtnPressed()
    }
    
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
        let distance = loc1.distance(from: loc2)
        
        let filterType = mapFilter.getFitlerTypeString()
        let filterParam = mapFilter.getFilterParam()
        
        
        locationUpdatingRequest = requester.getRadarDataWithFilter(userLocation!.location.coordinate, scanCenter: scanCenter, filterDistance: distance, filterType: filterType, filterParam: filterParam, onSuccess: { (json) in
            // 当前正在显示的用户
            guard let json = json else {
                return
            }
            var usersIDs: [String] = []
            var annotations = [BMKAnnotation]()
            var dirty: Bool = false
            for data in json.arrayValue {
                let onlyOnList = data["only_on_list"].boolValue
                // 创建用户对象
                let user: User = try! MainManager.sharedManager.getOrCreate(data, detailLevel: 1)
                let userID = user.ssidString
                if usersIDs.contains(value: userID) {
                    continue
                }
                usersIDs.append(user.ssidString)
                if let anno = self.userAnnos[userID] {
                    let loc = data["loc"]
                    anno.coordinate = CLLocationCoordinate2D(latitude: loc["lat"].doubleValue, longitude: loc["lon"].doubleValue)
                    if onlyOnList && anno.onMap {
                        anno.onMap = false
                        //                        self.map.removeAnnotation(anno)
                        dirty = true
                    } else if !onlyOnList && !anno.onMap {
                        anno.onMap = true
                        //                        self.map.addAnnotation(anno)
                        annotations.append(anno)
                        dirty = true
                    } else {
                        annotations.append(anno)
                    }
                } else {
                    let anno = UserAnnotation()
                    anno.user = user
                    anno.title = " "
                    let loc = data["loc"]
                    anno.coordinate = CLLocationCoordinate2D(latitude: loc["lat"].doubleValue, longitude: loc["lon"].doubleValue)
                    self.userAnnos[userID] = anno
                    if !onlyOnList {
                        anno.onMap = true
                        //                        self.map.addAnnotation(anno)
                        annotations.append(anno)
                        dirty = true
                    } else {
                        anno.onMap = false
                    }
                }
            }
            for oldUser in self.userAnnos.keys {
                if !usersIDs.contains(oldUser) {
                    let anno = self.userAnnos[oldUser]!
                    self.map.removeAnnotation(anno)
                    self.userAnnos[oldUser] = nil
                }
            }
            if dirty || self.mapAnnoEmpty {
                self.clusteringManager.setAnnotations(annotations)
                self.reloadMapClusterPins()
            }
            self.locationUpdatingRequest = nil
            self.lastUpdate = Date()
            if self.showUserListBtn.tag == 1 {
                DispatchQueue.main.async(execute: {
                    self.userList.reloadData()
                })
            }
        }, onError: { (code) in
            self.locationUpdatingRequest = nil
        })
    }
    
    func onUserBlocked(_ notification: Foundation.Notification) {
        let user = (notification as NSNotification).userInfo![kUserKey] as! User
        let blockStatus = (notification as NSNotification).userInfo![kAccountBlackStatusKey] as! String
        if blockStatus == kAccountBlackStatusBlocked {
            if let anno = userAnnos[user.ssidString] {
                userAnnos[user.ssidString] = nil
                map.removeAnnotation(anno)
                if showUserListBtn.tag == 1 {
                    DispatchQueue.main.async(execute: {
                        self.userList.reloadData()
                    })
                }
            }
        }
    }
}

// MARK: - 关于用户列表显示
extension RadarDriverMapController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userAnnos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DriverMapUserCell
        let anno = userAnnos.valueForIndex((indexPath as NSIndexPath).row)
        cell.user = anno?.user
        cell.hostLoc = CLLocation(latitude: userAnnotate.coordinate.latitude, longitude: userAnnotate.coordinate.longitude)
        cell.userLoc = CLLocation(latitude: anno!.coordinate.latitude, longitude: anno!.coordinate.longitude)
        cell.loadDataAndUpdateUI()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let anno = userAnnos.valueForIndex((indexPath as NSIndexPath).row)
        guard let user = anno?.user else {
            assertionFailure()
            return
        }
        assert(!user.isHost)
//        let detail = PersonOtherController(user: user)

        parent?.navigationController?.pushViewController(user.showDetailController(), animated: true)
    }
    
    func showUserBtnPressed() {
        if showUserListBtn.tag == 0 {
            // show the list
            userList.snp.remakeConstraints { (make) -> Void in
                make.right.equalTo(self.view)
                make.left.equalTo(self.view)
                make.height.equalTo(self.view.frame.height - 190)
                make.bottom.equalTo(self.view.snp.bottom)// .offset(90)
            }
            SpringAnimation.spring(duration: 0.6, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
            if mapFilter.expanded {
                toggleMapFilter()
            }
            userList.reloadData()
            showUserListBtn.tag = 1
            tapper.isEnabled = true
        }else {
            userList.snp.remakeConstraints { (make) -> Void in
                make.right.equalTo(self.view)
                make.left.equalTo(self.view)
                make.height.equalTo(self.view.frame.height - 190)
                make.top.equalTo(self.view.snp.bottom)
            }
            SpringAnimation.spring(duration: 0.6, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
            showUserListBtn.tag = 0
            tapper.isEnabled = false
        }
        
    }
}

extension RadarDriverMapController {
    func toggleMapFilter() {
        
        if mapNav.viewControllers.count > 1 {
            mapNav.popToRootViewController(animated: true)
            return
        }
        
        if mapFilter.expanded {
            // hide the list
            mapFilterView.snp.remakeConstraints({ (make) -> Void in
                make.bottom.equalTo(showUserListBtn)
                make.right.equalTo(showUserListBtn.snp.left).offset(-13)
                make.width.equalTo(115)
                make.height.equalTo(40)
            })
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.mapFilter.view.toRound(20)
                self.mapFilter.marker.transform = CGAffineTransform.identity
            }) 
        }else {
            // dispaly the list
            mapFilterView.snp.remakeConstraints({ (make) -> Void in
                make.bottom.equalTo(showUserListBtn)
                make.right.equalTo(showUserListBtn.snp.left).offset(-13)
                make.width.equalTo(115)
                make.height.equalTo(40 * 6)
            })
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.mapFilter.view.toRound(5)
                self.mapFilter.marker.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            }) 
        }
        mapFilter.expanded = !mapFilter.expanded
        
    }
    
    func radarFilterDidChange() {
        toggleMapFilter()
    }
}

extension RadarDriverMapController: ClusterAnnotationViewDelegate {
    func clusterAnnotationPressed(_ clusterView: ClusterAnnotationView) {
        let cluster = clusterView.annotation as! FBAnnotationCluster
        if cluster.annotations.count < 2 {
            return
        }
        var latMax: Double = 0
        var latMin: Double = Double.greatestFiniteMagnitude
        var lonMax: Double = 0
        var lonMin: Double = Double.greatestFiniteMagnitude
        for anno in cluster.annotations {
            let c = anno.coordinate
            if c.latitude < latMin {
                latMin = c.latitude
            }
            if c.latitude > latMax {
                latMax = c.latitude
            }
            if c.longitude < lonMin {
                lonMin = c.longitude
            }
            if c.longitude > lonMax {
                lonMax = c.longitude
            }
        }
        let center = CLLocationCoordinate2D(latitude: (latMax + latMin) / 2, longitude: (lonMax + lonMin) / 2)
        let span = BMKCoordinateSpan(latitudeDelta: (latMax - latMin) * 1.5, longitudeDelta: (lonMax - lonMin) * 1.5)
        let region = BMKCoordinateRegionMake(center, span)
        map.setRegion(region, animated: true)
        
    }
}

extension RadarDriverMapController: MapOperationDelegate {
    func mapOperationGetUserLocation() -> CLLocationCoordinate2D? {
        return userLocation?.location.coordinate
    }
}
