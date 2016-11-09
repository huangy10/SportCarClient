//
//  PersonController.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/11/3.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import SwiftyJSON
import Dollar
import MapKit


class PersonController: UIViewController, RequestManageMixin, LoadingProtocol {
    var delayWorkItem: DispatchWorkItem?
    weak var homeDelegate: HomeDelegate?
    
    var header: PersonHeaderView!
    var tableView: UITableView!
    var refresh: UIRefreshControl!
    var isTableEmpty: Bool {
        return data.numberOfStatusCell() == 0
    }
    
    var data: PersonDataSourceDelegate!
    var user: User {
        return data.user
    }
    
    var mapView: BMKMapView! {
        return header.userProfileView.map
    }
    var locationService: BMKLocationService!
    var userLocation: Location?
    var userAnno: BMKPointAnnotation!
    
    var selectedCar: SportCar? {
        get {
            return data.selectedCar
        }
        
        set {
            if selectedCar == newValue {
                return
            }
            data.selectedCar = newValue
            header.car = newValue
            
//            UIView.animate(withDuration: 0.3, animations: {
//                self.tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.header.requiredHeight())
//            })
            self.tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.header.requiredHeight())
            
            if data.numberOfStatus() == 0 {
                refresh.beginRefreshing()
                tableView.setContentOffset(.zero, animated: true)
                reqGetStatusList(overrideReqKey: "auto")
            } else {
                header.loadDataAndUpdateUI()
                UIView.transition(with: tableView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.tableView.reloadData()
                }, completion: nil)
//                tableView.reloadData()
            }
        }
    }
    
    var onGoingRequest: [String : Request] = [:]
    var isRoot: Bool {
        return homeDelegate != nil
    }
    var homeBtn: BackToHomeBtn!
    weak var oldNavDelegate: UINavigationControllerDelegate?
    var selectedIdx: Int = 0
    var needReload: Bool = false
    
    init (user: User) {
        data = DefaultPersonDataSource(user: user)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    deinit {
        clearAllRequest()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        configureTableView()
        configureHeader()
        configureNotifications()
        if user.isHost {
            configureMap()
        } else {
            trackTargetUserLocation()
        }
        
        refresh.beginRefreshing()
        pullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if user.isHost {
            locationService.delegate = self
            locationService.startUserLocationService()
        }
        
        mapView.delegate = self
        mapView.viewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if user.isHost {
            locationService.delegate = nil
            locationService.stopUserLocationService()
        }
        
        mapView.delegate = nil
        mapView.viewWillDisappear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if needReload {
            tableView.reloadData()
        }
        
        if header.needsReload {
            header.loadDataAndUpdateUI()
        }
    }
    
    func configureNotifications() {
        if user.isHost {
            NotificationCenter.default.addObserver(self, selector: #selector(onStatusNew(_:)), name: NSNotification.Name(rawValue: kStatusNewNotification), object: nil)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(onStatusDelete(_:)), name: NSNotification.Name(rawValue: kStatusDidDeletedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onAccountInfoChanged(_:)), name: NSNotification.Name(rawValue: kAccountInfoChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onCarDeleted(_:)), name: NSNotification.Name(rawValue: kCarDeletedNotification), object: nil)
    }
    
    func onStatusNew(_ n: NSNotification) {
        guard let status = n.userInfo?[kStatusKey] as? Status else {
            return
        }
        
        needReload = data.newStatus(status)
    }
    
    func onStatusDelete(_ n: NSNotification) {
        if let status = n.userInfo?[kStatusKey] as? Status {
            needReload = data.rmStatus(status)
        }
    }
    
    func onAccountInfoChanged(_ n: NSNotification) {
        header.needsReload = true
    }
    
    func onCarDeleted(_ n: NSNotification) {
        if let car = n.userInfo?[kSportcarKey] as? SportCar {
            data.rmCar(car)
            header.needsReload = true
            needReload = true
        }
    }
    
    func configureMap() {
        locationService = BMKLocationService()
    }
    
    func configureNavBar() {
        navigationItem.title = getNavTitle()
        navigationItem.leftBarButtonItem = getNavLeftBtn()
        if user.isHost {
            navigationItem.rightBarButtonItem = getNavRightBtn()
        } else {
            navigationItem.rightBarButtonItems = getNavRightBtns()
        }
        oldNavDelegate = navigationController?.delegate
        navigationController?.delegate = self
    }
    
    func getNavLeftBtn() -> UIBarButtonItem? {
        if isRoot {
            homeBtn = BackToHomeBtn()
            homeBtn.addTarget(self, action: #selector(navLeftBtnPressed), for: .touchUpInside)
            return homeBtn.wrapToBarBtn()
        } else {
            let backBtn = UIButton().config(self, selector: #selector(navLeftBtnPressed))
            backBtn.setImage(UIImage(named: "account_header_back_btn"), for: .normal)
            backBtn.imageView?.contentMode = .scaleAspectFit
            backBtn.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
            return UIBarButtonItem(customView: backBtn)
        }
    }
    
    func getNavRightBtns() -> [UIBarButtonItem] {
        var result: [UIBarButtonItem] = []
        let btnSize: CGFloat = 30
        let iconSize: CGFloat = 18
        let btnFrame = CGRect(x: 0, y: 0, width: btnSize, height: btnSize)
        let edgeVal = (btnSize - iconSize) / 2
        let edge = UIEdgeInsets(top: edgeVal, left: edgeVal, bottom: edgeVal, right: edgeVal)
        let setting = UIButton().config(
            self, selector: #selector(navRightBtnPressed),
            image: UIImage(named: "person_setting"))
        setting.frame = btnFrame
        setting.imageEdgeInsets = edge
        setting.imageView?.contentMode = .scaleAspectFit
        result.append(UIBarButtonItem(customView: setting))
        
        let navigate = UIButton().config(self, selector: #selector(locateBtnPressed))
        navigate.setImage(UIImage(named: "locate"), for: .normal)
        navigate.imageView?.contentMode = .scaleAspectFit
        navigate.frame = btnFrame
        navigate.imageEdgeInsets = edge
        result.append(UIBarButtonItem(customView: navigate))
        
        let chat = UIButton().config(self, selector: #selector(chatBtnPressed))
        chat.setImage(UIImage(named: "chat"), for: .normal)
        chat.imageView?.contentMode = .scaleAspectFit
        chat.frame = btnFrame
        chat.imageEdgeInsets = edge
        result.append(UIBarButtonItem(customView: chat))
        return result
    }
    
    func getNavRightBtn() -> UIBarButtonItem? {
        let setting = UIButton().config(self, selector: #selector(navRightBtnPressed))
            .setFrame(CGRect(x: 0, y: 0, width: 44, height: 44))
        setting.addSubview(UIImageView.self).config(UIImage(named: "person_setting"), contentMode: .scaleAspectFit)
            .layout { (make) in
                make.centerY.equalTo(setting)
                make.right.equalTo(setting)
                make.size.equalTo(20)
        }
        setting.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7)
        return UIBarButtonItem(customView: setting)
    }
    
    func getNavTitle() -> String {
        return LS(user.isHost ? "我" : "个人信息")
    }
    
    func configureTableView() {
        tableView = UITableView()
        tableView.backgroundColor = kGeneralTableViewBGColor
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        tableView.register(PersonStatusListGroupCell.self, forCellReuseIdentifier: "cell")
        tableView.register(SSEmptyListHintCell.self, forCellReuseIdentifier: "empty")
        tableView.rowHeight = UITableViewAutomaticDimension
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (mk) in
            mk.edges.equalTo(view)
        }
        
        refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.refreshControl = refresh
    }
    
    func configureHeader() {
        header = PersonHeaderView(user: user)
        header.dataSource = self
        header.userProfileView.delegate = self
        
        let container = UIView()
        container.addSubview(header)
        container.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: header.requiredHeight())

        tableView.tableHeaderView = container

        header.snp.makeConstraints { (mk) in
            mk.centerX.equalTo(container)
            mk.top.equalTo(container)
            mk.bottom.equalTo(container)
            mk.width.equalTo(view)
        }
        
    }
    
    func navRightBtnPressed() {
        if user.isHost {
            let settings = PersonMineSettings()
            navigationController?.pushViewController(settings, animated: true)
        } else {
            let block = BlockUserController(user: user)
            block.presentFromRootViewController()
        }
    }
    
    func navLeftBtnPressed() {
        if homeDelegate != nil {
            homeDelegate?.backToHome(nil)
        }else {
            navigationController?.delegate = oldNavDelegate
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func reqGetStatusList(overrideReqKey: String = "") {
        let num = data.numberOfStatus()
        let dateThreshold: Date
        if num == 0 {
            dateThreshold = Date()
        } else {
            dateThreshold = data.getStatus(atIdx: num - 1).createdAt!
        }
        // 我们这里用一个临时变量来存下当前的选中的车，以免在回调之前这个变量发生改变
        let curSelectedCar = data.selectedCar
        incrTaskCountDown()
        AccountRequester2.sharedInstance.getStatusListSimplified(user.ssidString, carID: curSelectedCar?.ssidString, dateThreshold: dateThreshold, limit: 10, onSuccess: { (json) -> () in
            if self.parseStatusData(json!.arrayValue, forCar: curSelectedCar) {
//            self.tableView.reloadData()
                if overrideReqKey != "" {
                    UIView.transition(with: self.tableView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                        self.tableView.reloadData()
                    }, completion: nil)
                } else {
                    self.tableView.reloadData()
                }
            }
            
            self.decrTaskCountDown()
        }, onError: { (code) -> () in
            self.showReqError(withCode: code)
            self.decrTaskCountDown(withSuccessFlag: true)
        }).registerForRequestManage(self, forKey: reqKeyFromFunctionName(withExtraID: overrideReqKey))
    }
    
    func parseStatusData(_ json: [JSON], forCar car: SportCar?) -> Bool {
        var buf: [Status] = []
        for data in json {
            let status = try! MainManager.sharedManager.getOrCreate(data) as Status
            buf.append(status)
        }
        data.updateStatusList(forCar: car, withData: buf)
        return buf.count != 0
    }
    
    var taskCountDown: Int = 0
    
    func incrTaskCountDown() {
        taskCountDown += 1
    }
    
    func decrTaskCountDown(withSuccessFlag success: Bool = true) {
        taskCountDown -= 1
        if taskCountDown <= 0 {
            refresh.endRefreshing()
            if success {
                header.loadDataAndUpdateUI()
            }
        }
    }
    
    func pullToRefresh() {
        reqGetAccountInfo()
        reqGetCarList()
        reqGetStatusList(overrideReqKey: "pull")
    }
    
    func reqGetAccountInfo() {
        incrTaskCountDown()
        AccountRequester2.sharedInstance.getProfileDataFor(user.ssidString, onSuccess: { (json) -> () in
            let user = self.data.user
            try! user.loadDataFromJSON(json!, detailLevel: 1)
            //
            self.decrTaskCountDown()
        }, onError: { (code) -> () in
            self.showReqError(withCode: code)
            self.decrTaskCountDown(withSuccessFlag: false)
        }).registerForRequestManage(self)
    }
    
    func reqGetCarList() {
        incrTaskCountDown()
        let autoSelectFirstCar = data.cars.count == 0
        AccountRequester2.sharedInstance.getAuthedCarsList(user.ssidString, onSuccess: { (json) -> () in
            var newCars: [SportCar] = []
            let oldCars: [SportCar] = self.data.cars
            for data in json!.arrayValue {
                let car = try! MainManager.sharedManager.getOrCreate(SportCar.reorgnaizeJSON(data), detailLevel: 1) as SportCar
                newCars.append(car)
            }
            
            let newCarIds = newCars.map({ $0.ssid })
            for oldCar in oldCars {
                if !newCarIds.contains(value: oldCar.ssid) {
                    self.data.rmCar(oldCar)
                }
            }
            
            self.data.cars = newCars
            if autoSelectFirstCar && newCars.count > 0 {
                self.selectedCar = newCars.first()
            }
            
            self.decrTaskCountDown()
        }, onError: { (code) -> () in
            self.showReqError(withCode: code)
            self.decrTaskCountDown(withSuccessFlag: false)
        }).registerForRequestManage(self)
    }
   
    func chatBtnPressed() {
        if navigationController!.viewControllers.count > 3, let room = self.navigationController?.viewControllers.fetch(index: -3) as? ChatRoomController, room.targetUser!.ssid == user.ssid {
            _ = navigationController?.popViewController(animated: true)
            return
        }
        
        let room = ChatRoomController()
        room.targetUser = user
        room.chatCreated = false
        
        navigationController?.pushViewController(room, animated: true)
    }
    
    func locateBtnPressed() {
        guard userLocation != nil else {
            showToast(LS("无法确认目标用户的位置"))
            return
        }
        
        needNavigation()
    }
    
    func needNavigation() {
        showConfirmToast(LS("导航"), message: LS("跳转到地图导航至该用户地址？"), target: self, onConfirm: #selector(openMapToNavigate))
    }
    
    func openMapToNavigate() {
        let param = BMKNaviPara()
        let end = BMKPlanNode()
        let center = userLocation!.location
        end.pt = center
        let targetName = userLocation!.description
        end.name = targetName
        param.endPoint = end
        param.appScheme = "baidumapsdk://mapsdk.baidu.com"
        let res = BMKNavigation.openBaiduMapNavigation(param)
        if res.rawValue != 0 {
            // 如果没有安装百度地图，则打开自带地图
            let target = MKMapItem(placemark: MKPlacemark(coordinate: center, addressDictionary: nil))
            target.name = targetName
            let options: [String: AnyObject] = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving as AnyObject,
                                                MKLaunchOptionsMapTypeKey: NSNumber(value: MKMapType.standard.rawValue as UInt)]
            MKMapItem.openMaps(with: [target], launchOptions: options)
        }
    }
}

extension PersonController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let statusNum = data.numberOfStatusCell()
        if statusNum == 0 {
            return 1
        }
        return (statusNum - 1) / 3 + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isTableEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath) as! SSEmptyListHintCell
            cell.titleLbl.text = LS("还没有动态！")
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PersonStatusListGroupCell
        cell.indexPath = indexPath
        cell.delegate = self
        let rangeMin = indexPath.row * 3
        let rangeMax = min(rangeMin + 3, data.numberOfStatusCell())
        (rangeMin..<rangeMax).forEach({ cell.setImage(getStatus(atIdx: $0)?.coverURL!, atIdx: $0) })
        return cell
    }
    
    func getStatus(atIdx idx: Int) -> Status? {
        if user.isHost && selectedCar == nil {
            if idx == 0 {
                return nil
            } else {
                return data.getStatus(atIdx: idx - 1)
            }
        } else {
            return data.getStatus(atIdx: idx)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.width / 3
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.frame.height >= scrollView.contentSize.height {
            reqGetStatusList()
        }
    }
}

extension PersonController: PersonHeaderCarListDatasource {
    func personHeaderCarList() -> [SportCar] {
        return data.cars
    }
    
    func personHeaderSportCarSelectionChanged(intoCar newCar: SportCar?) {
        selectedCar = newCar
    }
    
    func personHeaderNeedAddCar() {
        let detail = ManufacturerOnlineSelectorController()
        detail.delegate = self
        present(detail.toNavWrapper(), animated: true, completion: nil)
    }
    
    func personHeaderCarNeedEdit() {
        let detail = SportCarInfoDetailController()
        detail.car = selectedCar!
        navigationController?.pushViewController(detail, animated: true)
    }
}

extension PersonController: SportCarBrandOnlineSelectorDelegate, SportCarSelectDetailProtocol {
    func sportCarBrandOnlineSelectorDidSelect(_ manufacture: String, carName: String, subName: String) {
        dismiss(animated: true, completion: nil)
        lp_start()
        SportCarRequester.sharedInstance.querySportCarWith(manufacture, carName: carName, subName: subName, onSuccess: { (json) in
            self.lp_stop()
            guard let data = json else {
                return
            }
            let carImgURL = SF(data["image_url"].stringValue)
            let headers = [LS("具体型号"), LS("爱车签名"), LS("价格"), LS("发动机"), LS("扭矩"), LS("车身结构"), LS("最高时速"), LS("百公里加速")]
            let contents = [carName, nil, data["price"].string, data["engine"].string, data["transmission"].string, data["body"].string, data["max_speed"].string, data["zeroTo60"].string]
            let detail = SportCarSelectDetailController()
            detail.delegate = self
            detail.headers = headers
            detail.carId = data["carID"].stringValue
            detail.contents = contents
            detail.carType = carName
            detail.carDisplayURL = URL(string: carImgURL ?? "")
            self.navigationController?.pushViewController(detail, animated: true)
        }) { (code) in
            self.lp_stop()
            self.showToast(LS("获取跑车数据失败"))
            }.registerForRequestManage(self)
    }
    
    func sportCarBrandOnlineSelectorDidCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func sportCarSelectDeatilDidAddCar(_ car: SportCar) {
        data.addCar(car)
        header.loadDataAndUpdateUI()
    }
}

extension PersonController: PersonStatusListGroupCellDelegate {
    func statusPressed(at idx: Int) {
        selectedIdx = idx
        let status: Status
        if selectedCar == nil && user.isHost {
            if idx == 0 {
                let release = StatusReleaseController()
                release.presenter = self
                present(release, animated: true, completion: nil)
                return
            } else {
                status = data.getStatus(atIdx: idx - 1)
            }
        } else {
            status = data.getStatus(atIdx: idx)
        }
        let detail = StatusDetailController(status: status)
        navigationController?.pushViewController(detail, animated: true)
    }
}

extension PersonController: UINavigationControllerDelegate, StatusCoverPresentable {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push where (fromVC == self && toVC.isKind(of: StatusDetailController.self)):
            let res = StatusCoverPresentAnimation()
            res.delegate = self
            return res
        case .pop where (fromVC.isKind(of: StatusDetailController.self) && toVC == self):
            let res = StatusCoverDismissAnimation()
            res.delegate = self
            return res
        default:
            return nil
        }
    }
    
    func initialCoverPosition() -> CGRect {
        let cell = tableView.cellForRow(at: IndexPath(row: selectedIdx / 3, section: 0)) as! PersonStatusListGroupCell
        let btn = cell.btns[selectedIdx % 3]
        var rect = cell.contentView.convert(btn.frame, to: navigationController!.view)
        rect.origin.x += 5
        return rect
    }
}

extension PersonController: PersonProfileProtocol {
    
    func headerDetailBtnPressed() {
        if user.isHost {
            let detail =  PersonMineInfoController()
            navigationController?.pushViewController(detail, animated: true)
        } else {
            let detail = PersonOtherInfoController()
            detail.user = user
            navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    func headerStatusNumPressed() {
        personHeaderSportCarSelectionChanged(intoCar: nil)
    }
    
    func headerFansNumPressed() {
        let fans = FansSelectController()
        fans.targetUser = user
        navigationController?.pushViewController(fans, animated: true)
    }
    
    func headerFollowsNumPressed() {
        let follows = FollowSelectController()
        follows.targetUser = user
        navigationController?.pushViewController(follows, animated: true)
    }
    
    func headerFollowBtnPressed() {
        followBtnPressed()
    }
   
    func followBtnPressed() {
        lp_start()
        AccountRequester2.sharedInstance.follow(user.ssidString, onSuccess: { (json) -> () in
            self.lp_stop()
            let followed = json!.boolValue
            self.user.followed = true
            self.header.userProfileView.setFollowState(followed)
        }, onError: { (code) -> () in
            self.lp_stop()
            self.showReqError(withCode: code)
        }).registerForRequestManage(self)
    }
}

extension PersonController: BMKLocationServiceDelegate, BMKMapViewDelegate {
    func didUpdate(_ userLocation: BMKUserLocation!) {
        if self.userLocation == nil {
            userAnno = BMKPointAnnotation()
            mapView.addAnnotation(userAnno)
        }
        
        let coor = userLocation.location.coordinate
        userAnno.coordinate = userLocation.location.coordinate
        self.userLocation = Location(latitude: coor.latitude, longitude: coor.longitude, description: "", city: "")
        let userLocInScreen = mapView.convert(userLocation.location.coordinate, toPointTo: mapView)
        let userLocWithOffset = CGPoint(x: userLocInScreen.x + header.frame.width / 4, y: userLocInScreen.y - header.frame.height / 3)
        let newCoordinate = mapView.convert(userLocWithOffset, toCoordinateFrom: mapView)
        let region = BMKCoordinateRegionMakeWithDistance(newCoordinate, 3000, 5000)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        let view = UserSelectAnnotationView(annotation: annotation, reuseIdentifier: "user_location")
        view?.annotation = annotation
        return view
    }
    
    
    func trackTargetUserLocation() {
        userAnno = BMKPointAnnotation()
        RadarRequester.sharedInstance.trackUser(user.ssidString, onSuccess: { (json) -> () in
            self.userLocation = Location(latitude: json!["lat"].doubleValue, longitude: json!["lon"].doubleValue, description: json!["description"].stringValue, city: json!["city"].stringValue)
            let loc = self.userLocation!.location
            self.userAnno.coordinate = loc
            let userLocInScreen = self.mapView.convert(loc, toPointTo: self.mapView)
            let rect = self.header.userProfileView.frame
            let userLocWithOffset = CGPoint(x: userLocInScreen.x, y: userLocInScreen.y - rect.height / 60)
            let newCoordinate = self.mapView.convert(userLocWithOffset, toCoordinateFrom: self.mapView)
            let region = BMKCoordinateRegionMakeWithDistance(newCoordinate, 3000, 5000)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { 
                self.mapView.setRegion(region, animated: true)
                self.mapView.addAnnotation(self.userAnno)
            })
            
        }, onError: { (code) -> () in
            self.showReqError(withCode: code)
        }).registerForRequestManage(self)
    }
}

protocol PersonStatusListGroupCellDelegate: class {
    func statusPressed(at idx: Int)
}


class PersonStatusListGroupCell: UITableViewCell {
    var btns: [UIButton] = []
    var indexPath: IndexPath!
    weak var delegate: PersonStatusListGroupCellDelegate!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureBtns()

        selectionStyle = .none
        backgroundColor = kGeneralTableViewBGColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func configureBtns() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2.5
        stack.distribution = .fillEqually
        stack.alignment = .center
        contentView.addSubview(stack)
        stack.snp.makeConstraints { (mk) in
            mk.edges.equalTo(UIEdgeInsetsMake(0, 5, 2.5, 5))
        }
        for idx in 0..<3 {
            let btn = UIButton()
            btn.addTarget(self, action: #selector(btnPressed(sender:)), for: .touchUpInside)
            btn.imageView?.contentMode = .scaleAspectFill
            btn.snp.makeConstraints({ (mk) in
                mk.height.equalTo(btn.snp.width)
            })
            btn.tag = idx
            stack.addArrangedSubview(btn)
            btns.append(btn)
        }
    }
    
    func setImage(_ im: URL?, atIdx idx: Int) {
        if im != nil {
            btns[idx % 3].kf.setImage(with: im!, for: .normal)
        } else {
            btns[idx % 3].setImage(UIImage(named: "release_status_in_person"), for: .normal)
        }
    }
    
    func setImages(_ images: [UIImage?]) {
        for (idx, im) in images.enumerated() {
            if im != nil {
                btns[idx].setImage(im, for: .normal)
            } else {
                btns[idx].setImage(UIImage(named: "release_status_in_person"), for: .normal)
            }
        }
    }
    
    func btnPressed(sender: UIButton) {
        let idx = indexPath.row * 3 + sender.tag
        delegate.statusPressed(at: idx)
    }
}
