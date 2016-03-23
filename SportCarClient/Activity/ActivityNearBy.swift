//
//  ActivityNearBy.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/14.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class ActivityNearByController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, BMKMapViewDelegate, BMKLocationServiceDelegate {
    
    weak var home: ActivityHomeController!
    
    var acts: [Activity] = []
    
    var map: BMKMapView!
    var actAnno: BMKPointAnnotation?
    var userAnno: BMKPointAnnotation?
    var userLocation: BMKUserLocation?
    var locationService: BMKLocationService!
    
    var actsBoard: UICollectionView!
    var pageCount: UIPageControl!
    var _prePage: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
        
        actsBoard.registerClass(ActivityNearByCell.self, forCellWithReuseIdentifier: ActivityNearByCell.reuseIdentifier)
        // 启动位置跟踪
        locationService = BMKLocationService()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        map.delegate = self
        userLocation = nil
        locationService.delegate = self
        locationService.startUserLocationService()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        map.delegate = nil
        locationService.delegate = nil
        locationService.stopUserLocationService()
    }
    
    func createSubviews() {
        let superview = self.view
        superview.backgroundColor = UIColor.blackColor()
        //
        map = BMKMapView()
        superview.addSubview(map)
        map.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        //
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(170, 200)
        layout.scrollDirection = .Horizontal
        layout.minimumInteritemSpacing = 0.01
        actsBoard = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        actsBoard.backgroundColor = UIColor.clearColor()
        actsBoard.delegate = self
        actsBoard.dataSource = self
        let sideInset = (UIScreen.mainScreen().bounds.width - 170) / 2
        actsBoard.contentInset = UIEdgeInsetsMake(0, sideInset, 20, sideInset)
        superview.addSubview(actsBoard)
        actsBoard.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(superview)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.height.equalTo(220)
        }
        //
        pageCount = UIPageControl()
        pageCount.numberOfPages = 1
        superview.addSubview(pageCount)
        pageCount.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(superview).offset(5)
            make.centerX.equalTo(superview)
        }
    }
    
    //
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageCount.numberOfPages = acts.count
        return acts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ActivityNearByCell.reuseIdentifier, forIndexPath: indexPath) as! ActivityNearByCell
        cell.act = acts[indexPath.row]
        cell.loadDataAndUpdateUI()
        //
        let cellWidth: CGFloat = 170
        let offset = cell.frame.origin.x - collectionView.contentOffset.x + cellWidth / 2
        let absOffsetRatio = abs(offset - collectionView.frame.width / 2) / (collectionView.frame.width / 2)
        let scaleRatio = 1 - absOffsetRatio * 0.05
        var trans = CGAffineTransformMakeScale(scaleRatio, scaleRatio)
        trans = CGAffineTransformTranslate(trans, 0, cell.frame.height * (1 - scaleRatio) / 2)
        cell.container.transform = trans
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let act = acts[indexPath.row]
        let detail = ActivityDetailController(act: act)
        
        home.navigationController?.pushViewController(detail, animated: true)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let cells = actsBoard.visibleCells() as! [ActivityNearByCell]
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
            var trans = CGAffineTransformMakeScale(scaleRatio, scaleRatio)
            trans = CGAffineTransformTranslate(trans, 0, cell.frame.height * (1 - scaleRatio) / 2)
            cell.container.transform = trans
        }
        if maxCell != nil {
            pageCount.currentPage = actsBoard.indexPathForCell(maxCell!)!.row
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let cells = actsBoard.visibleCells()
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
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let cells = actsBoard.visibleCells()
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
        if _prePage != pageCount.currentPage {
            activityFocusedChanged()
            _prePage = pageCount.currentPage
        }
    }
}

// MARK: - About map
extension ActivityNearByController {
    
    //
    /**
    当前focus的活动发生了变化
    */
    func activityFocusedChanged() {
        let focusedActivity = acts[pageCount.currentPage]
        let center = CLLocationCoordinate2D(latitude: focusedActivity.location_y, longitude: focusedActivity.location_x)
        map.setCenterCoordinate(center, animated: true)
        if actAnno != nil {
            map.removeAnnotation(actAnno!)
        }
        actAnno = BMKPointAnnotation()
        actAnno?.coordinate = center
        map.addAnnotation(actAnno)
    }
    
    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
        if self.userLocation == nil {
            if userAnno == nil {
                userAnno = BMKPointAnnotation()
                map.addAnnotation(userAnno!)
            }
            userAnno?.coordinate = userLocation.location.coordinate
            let region = BMKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 3000, 5000)
            map.setRegion(region, animated: true)
            map.setCenterCoordinate(userLocation.location.coordinate, animated: true)
            ActivityRequester.requester.getNearByActivities(userLocation.location, queryDistance: 1000, skip: 0, limit: 10, onSuccess: { (json) -> () in
                self.acts.removeAll()
                for data in json!.arrayValue {
                    let act = Activity.objects.getOrCreate(data)
                    self.acts.append(act)
                }
                self.actsBoard.reloadData()
                self.pageCount.currentPage = 0
                if self.acts.count > 0 {
                    self.activityFocusedChanged()
                }
                }, onError: { (code) -> () in
                    print(code)
            })
        }
        userAnno?.coordinate = userLocation.location.coordinate
        self.userLocation = userLocation
    }
    
    func mapView(mapView: BMKMapView!, viewForAnnotation annotation: BMKAnnotation!) -> BMKAnnotationView! {
        if userAnno == annotation as? BMKPointAnnotation {
            let view = HostUserOnRadarAnnotationView(annotation: annotation, reuseIdentifier: "host")
            view.startScan()
            return view
        } else {
            var view = mapView.dequeueReusableAnnotationViewWithIdentifier("act") as? UserSelectAnnotationView
            if view == nil {
                view = UserSelectAnnotationView(annotation: annotation, reuseIdentifier: "act")
            }
            return view
        }
    }
    
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//
//        let needRequest = userLocation == nil
//        userLocation = locations.last()
//        if needRequest {
//            let requester = ActivityRequester.requester
//            requester.getNearByActivities(userLocation!, queryDistance: 10, skip: 0, limit: 10, onSuccess: { (json) -> () in
//                self.acts.removeAll()
//                for data in json!.arrayValue {
//                    let act = Activity.objects.getOrCreate(data)
//                    self.acts.append(act)
//                }
//                self.actsBoard.reloadData()
//                self.pageCount.currentPage = 0
//                if self.acts.count > 0 {
//                    self.activityFocusedChanged()
//                }
//                }, onError: { (code) -> () in
//                    print(code)
//            })
//            let center = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
//            map.setCenterCoordinate(center, zoomLevel: 12, animated: true)
//            if userLocationUpdator == nil {
//                userLocationUpdator = CADisplayLink(target: self, selector: "userLocationOnScreenUpdate")
//                userLocationUpdator?.frameInterval = 1
//                userLocationUpdator?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
//                userLocationUpdator?.paused = false
//            }
//            if userLocMarker == nil {
//            let userMarkLocationOnScreen = map.convertCoordinate(center, toPointToView: map)
//                userLocMarker = UserMapLocationManager(size: CGSizeMake(400, 400))
//                map.addSubview(userLocMarker)
//                userLocMarker.center = userMarkLocationOnScreen
//            }
//        }
//    }
//    
//    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
//        var annoationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("act_current_location")
//        
//        if annoationImage == nil {
//            annoationImage = MGLAnnotationImage(image: UIImage(named: "map_default_marker")!, reuseIdentifier: "act_current_location")
//        }
//        
//        return annoationImage
//    }
}

