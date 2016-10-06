//
//  PersonController.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/10/5.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class PersonController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LoadingProtocol {
    
    var delayWorkItem: DispatchWorkItem?
    
    private var needDisplay: Bool = false
    
    var header: PersonHeader!
    var collectionView: UICollectionView!
    var carsViewList: SportsCarViewListController!
    
    var mapView: BMKMapView {
        return header.map
    }
    
    var locationService: BMKLocationService!
    var userLocation: BMKUserLocation?
    var userAnno: BMKPointAnnotation!
    
    var data: PersonDataSource2!
    
    var user: User {
        return data.user
    }
    
    static func initWith(user: User) -> PersonController {
        if user.isHost {
            return PersonMeController(user: user)
        } else {
            return PersonOtherController2(user: user)
        }
    }
    
    init () {
        fatalError("Use initWith(user:) instead")
    }
    
    fileprivate init(user: User) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource(withUser: user)
        configureNavigationBar()
        configureLocationService()
        configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BMKServiceBegin()
        redisplayIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BMKServiceStop()
    }
    
    func BMKServiceBegin() {
        locationService.delegate = self
        locationService.startUserLocationService()
        mapView.delegate = self
        mapView.viewWillAppear()
    }
    
    func BMKServiceStop() {
        locationService.delegate = self
        locationService.stopUserLocationService()
        mapView.delegate = nil
        mapView.viewWillDisappear()
    }
    
    func configureDataSource(withUser user: User) {
        data = PersonDataSource2(user: user)
    }
    
    func configureNavigationBar() {
        navigationItem.title = getNavigationBarTitle()
        navigationItem.rightBarButtonItem = getNavRightBtn()
        navigationItem.leftBarButtonItem = getNavLeftBtn()
    }
    
    func configureLocationService() {
        locationService = BMKLocationService()
    }
    
    func configureCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        view.addSubview(collectionView)
        
        registerCollectionViewCell()
        registerCollectionViewHeader()
    }
    
    func registerCollectionViewHeader() {
        collectionView.register(PersonStatusHeader.self, forCellWithReuseIdentifier: PersonStatusHeader.reuseIdentifier)
    }
    
    func registerCollectionViewCell() {
        
    }
    
    func configureHeader() {
        header = PersonHeader.initWith(user: user)
    }
    
    func configureSportCarList() {
        carsViewList = SportsCarViewListController()
        carsViewList.delegate = self
    }
    

    func redisplayIfNeeded() {
        if needDisplay {
            redisplay()
            needDisplay = false
        }
    }
    
    func redisplay() {
        redisplayHeader()
        redisplayCarList()
        redisplayStatusList()
    }
    
    func redisplayHeader() {
        header.reload()
    }
    
    func redisplayCarList() {
        
    }
    
    func redisplayStatusList() {
        
    }
    
    func getNavigationBarTitle() -> String? {
        return nil
    }
    
    func getNavLeftBtn() -> UIBarButtonItem? {
        return nil
    }
    
    func getNavRightBtn() -> UIBarButtonItem? {
        return nil
    }
    
    func requestAccountInfo(showLoading: Bool = false) {
        if showLoading {
            lp_start()
        }
        
        _ = AccountRequester2.sharedInstance.getProfileDataFor(user.ssidString, onSuccess: { (json) in
            try! self.user.loadDataFromJSON(json!, detailLevel: 1)
            self.redisplayHeader()
            if showLoading {
                self.lp_stop()
            }
            }, onError: { (code) in
                self.showToast(LS("网络访问错误:\(code)"))
                if showLoading {
                    self.lp_stop()
                }
        })
    }
    
    func requestCarList(showLoading: Bool = false) {
        if showLoading {
            lp_start()
        }
        
        _ = AccountRequester2.sharedInstance.getAuthedCarsList(user.ssidString, onSuccess: { (json) in
            
            }, onError: { (code) in
                
        })
    }
    
    func requestStatusList(showLoading: Bool = false) {
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if data.hasCarSelected {
            return 3
        } else {
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 && data.hasCarSelected {
            return 1
        } else {
            return data.currentFocusedStatus.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 {
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PersonStatusHeader.reuseIdentifier, for: indexPath) as! PersonStatusHeader
            header.titleLbl.text = LS("动态")
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: UIScreen.main.bounds.width, height: PersonHeader.requiredHeight)
        } else {
            if data.hasCarSelected && section == 2 {
                return CGSize(width: UIScreen.main.bounds.width, height: 44)
            } else {
                return CGSize.zero
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(width: UIScreen.main.bounds.width, height: 62)
        case 1 where data.selectedCar != nil:
            guard let car = data.selectedCar else {
                fatalError()
            }
            return SportCarInfoCell.getPreferredSizeForSignature(car.signature!, carName: car.name!, withAudioWave: car.audioURL != nil)
        default:
            let width = UIScreen.main.bounds.width / 2
            return CGSize(width: width, height: width * 0.588)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("Implement this in subclasses")
    }
}

extension PersonController: SportCarViewListDelegate {
    
    func didSelect(sportCar car: SportCar?) {
        
    }
    
    func needAddSportCar() {
        
    }
}

extension PersonController: BMKMapViewDelegate, BMKLocationServiceDelegate {
    
    func didUpdate(_ userLocation: BMKUserLocation!) {
        
    }
    
    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        
    }
    
}


class PersonMeController: PersonController {
    
}

class PersonOtherController2: PersonController {
    
}
