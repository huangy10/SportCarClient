//
//  ActivityNearBy.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/14.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Mapbox


class ActivityNearByController: UIViewController, MGLMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate {
    
    var home: ActivityHomeController!
    
    var acts: [Activity] = []
    
    var map: MGLMapView!
    var actMarker: MGLPointAnnotation?
    var userLocMarker: UserMapLocationManager!
    var userLocationUpdator: CADisplayLink?
    var locationManager: CLLocationManager!
    var userLocation: CLLocation?
    
    var actsBoard: UICollectionView!
    var pageCount: UIPageControl!
    var _prePage: Int = 0
    
    deinit {
        userLocationUpdator?.paused = true
        userLocationUpdator?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
        
        actsBoard.registerClass(ActivityNearByCell.self, forCellWithReuseIdentifier: ActivityNearByCell.reuseIdentifier)
        // 启动位置跟踪
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        locationManager.requestLocation()
        locationManager?.startUpdatingLocation()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if userLocationUpdator != nil {
            userLocationUpdator?.paused = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        if userLocationUpdator != nil {
            userLocationUpdator?.paused = true
        }
    }
    
    func createSubviews() {
        let superview = self.view
        //
        map = MGLMapView(frame: CGRectZero, styleURL: kMapStyleURL)
        map.delegate = self
        map.allowsRotating = false
        superview.addSubview(map)
        map.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        //
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(170, 250)
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
            make.height.equalTo(270)
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
        map.setCenterCoordinate(center, zoomLevel: 12, animated: true)
        //
        if actMarker != nil {
            map.removeAnnotation(actMarker!)
        }
        actMarker = MGLPointAnnotation()
        actMarker?.title = ""
        actMarker?.coordinate = center
        map.addAnnotation(actMarker!)
    }
    
    // ========================
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print(status)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let needRequest = userLocation == nil
        userLocation = locations.last()
        if needRequest {
            let requester = ActivityRequester.requester
            requester.getNearByActivities(userLocation!, queryDistance: 10, skip: 0, limit: 10, onSuccess: { (json) -> () in
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
            let center = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
            map.setCenterCoordinate(center, zoomLevel: 12, animated: true)
            
            userLocationUpdator = CADisplayLink(target: self, selector: "userLocationOnScreenUpdate")
            userLocationUpdator?.frameInterval = 1
            userLocationUpdator?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            userLocationUpdator?.paused = false
            
            let userMarkLocationOnScreen = map.convertCoordinate(center, toPointToView: map)
            userLocMarker = UserMapLocationManager(size: CGSizeMake(200, 200))
            map.addSubview(userLocMarker)
            userLocMarker.center = userMarkLocationOnScreen
        }
        let center = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
        let userMarkLocationOnScreen = map.convertCoordinate(center, toPointToView: map)
        userLocMarker.center = userMarkLocationOnScreen
    }
    
    func userLocationOnScreenUpdate() {
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    // ========================
    
    func mapView(mapView: MGLMapView, didUpdateUserLocation userLocation: MGLUserLocation?) {
        
    }
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        var annoationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("act_current_location")
        
        if annoationImage == nil {
            annoationImage = MGLAnnotationImage(image: UIImage(named: "map_default_marker")!, reuseIdentifier: "act_current_location")
        }
        
        return annoationImage
    }
}

