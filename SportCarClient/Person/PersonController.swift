//
//  PersonController.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/9.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SwiftyJSON
import Dollar
import Alamofire

class PersonBasicController: UICollectionViewController, UICollectionViewDelegateFlowLayout, SportCarViewListDelegate, SportCarInfoCellDelegate, SportCarSelectDetailProtocol, SportCarBrandOnlineSelectorDelegate, LoadingProtocol, RequestManageMixin {
    internal var delayWorkItem: DispatchWorkItem?
    var onGoingRequest: [String : Request] = [:]

    weak var homeDelegate: HomeDelegate?
    // 显示的用户的信息
    var data: PersonDataSource!
    
    var header: PersonHeaderMine!
    var totalHeaderHeight: CGFloat = 0
    var carsViewList: SportsCarViewListController!
    
    var carsViewListShowAddBtn: Bool = true
    var locationService: BMKLocationService?
    var userLocation: BMKUserLocation?
    var userAnno: BMKPointAnnotation!
    
    var isRoot: Bool = false
    
    var homeBtn: BackToHomeBtn!
    
    var needReloadUserInfo: Bool = false
    weak var selectedStatusCell: UICollectionViewCell?
    
    weak var oldNavDelegate: UINavigationControllerDelegate?
    
    var refreshControl: UIRefreshControl!
    
    deinit {
        clearAllRequest()
        NotificationCenter.default.removeObserver(self)
    }
    
    init(user: User) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 2.5
        flowLayout.minimumLineSpacing = 2.5
        super.init(collectionViewLayout: flowLayout)
        data = PersonDataSource()
        data.user = user
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSubviews()
        configureRefreshControl()
        navSettings()
        configureNotficationObserveBehavior()
        locationService = BMKLocationService()
        // 发出网络请求
        loadAccountInfo()
        
        // 第三个响应：开始获取的动态列表，每次获取十个
        AccountRequester2.sharedInstance.getStatusListSimplified(data.user.ssidString, carID: nil, dateThreshold: Date(), limit: 10, onSuccess: { (json) -> () in
            //
            self.jsonDataHandler(json!, container: &self.data.statusList)
            self.collectionView?.reloadData()
            }) { (code) -> () in
                self.showToast(LS("网络访问错误:\(code)"))
        }.registerForRequestManage(self)
    }
    
    func configureNotficationObserveBehavior() {
        NotificationCenter.default.addObserver(self, selector: #selector(PersonBasicController.onStatusDelete(_:)), name: NSNotification.Name(rawValue: kStatusDidDeletedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSportCarDeleted(_:)), name: NSNotification.Name(rawValue: kCarDeletedNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onAccountInfoChanged(_:)), name: NSNotification.Name(rawValue: kAccountInfoChanged), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        // 
        locationService?.delegate = self
        locationService?.startUserLocationService()
        header.map.delegate = self
        header.map.viewWillAppear()
        header.loadDataAndUpdateUI()
        collectionView?.reloadData()
        
        if isRoot {
            homeBtn.unreadStatusChanged()
        }
        
        if needReloadUserInfo {
            needReloadUserInfo = false
            loadAccountInfo()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationService?.delegate = nil
        locationService?.stopUserLocationService()
        header.map.delegate = self
        header.map.viewWillDisappear()
    }
    
    func onAccountInfoChanged(_ notification: Foundation.Notification) {
        needReloadUserInfo = true
    }
    
    func loadAccountInfo() {
        let requester = AccountRequester2.sharedInstance
        // 这个请求是保证当前用户的数据是最新的，而hostuser中的数据可以暂时先直接拿来展示
        requester.getProfileDataFor(data.user.ssidString, onSuccess: { (json) -> () in
            let hostUser = self.data.user!
            try! hostUser.loadDataFromJSON(json!, detailLevel: 1)
            self.header.user = hostUser
            self.header.loadDataAndUpdateUI()
            self.refreshControl.endRefreshing()
        }) { (code) -> () in
            self.showToast(LS("网络访问错误:\(code)"))
            self.refreshControl.endRefreshing()
        }.registerForRequestManage(self, forKey: reqKeyFromFunctionName(withExtraID: "info"))
        // 获取认证车辆的列表
        requester.getAuthedCarsList(data.user.ssidString, onSuccess: { (json) -> () in
            self.data.handleAuthedCarsJSONResponse(json!, user: self.data.user)
            self.data.selectedCar = self.data.cars.first()
            self.carsViewList.cars = self.data.cars
            // 默认选择第一辆认证的车辆
            self.carsViewList.selectedCar = self.data.cars.first()
            self.carsViewList.collectionView?.reloadData()
            self.collectionView?.reloadData()
        }) { (code) -> () in
            self.showToast(LS("车辆关注列表获取失败"))
        }.registerForRequestManage(self, forKey: reqKeyFromFunctionName(withExtraID: "cars"))
    }
    
    func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadAccountInfo), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
    }

    
    /**
     重写这个方法来替换header所用的类型,header必须是PersonheaderMine的基类
     
     - returns: header对象
     */
    func getPersonInfoPanel() -> PersonHeaderMine {
        let screenWidth = self.view.frame.width
        totalHeaderHeight = 773.0 / 750 * screenWidth
        let header = PersonHeaderMine()
        header.detailBtn.addTarget(self, action: #selector(PersonBasicController.detailBtnPressed), for: .touchUpInside)
        
        header.fanslistBtn.addTarget(self, action: #selector(PersonBasicController.fanslistPressed), for: .touchUpInside)
        header.followlistBtn.addTarget(self, action: #selector(PersonBasicController.followlistPressed), for: .touchUpInside)
        header.statuslistBtn.addTarget(self, action: #selector(PersonBasicController.statuslistPressed), for: .touchUpInside)
        
        
        // 我们希望为『我的』页面加上对kStatusNewNotification的监听，而不希望『他人』也监听这个，故在这里加上
        NotificationCenter.default.addObserver(self, selector: #selector(onStatusNew(_:)), name: NSNotification.Name(rawValue: kStatusNewNotification), object: nil)
        
        return header
    }
    
    func createSubviews() {
        let superview = self.view!
        collectionView?.backgroundColor = kGeneralTableViewBGColor
        collectionView?.alwaysBounceVertical = true
        //
        let screenWidth = superview.frame.width
        let authCarListHeight: CGFloat = 62
        header = getPersonInfoPanel()
        collectionView?.addSubview(header)
        header.frame = CGRect(x: 0, y: -totalHeaderHeight, width: screenWidth, height: totalHeaderHeight - authCarListHeight)
        header.user = data.user
        //
        carsViewList = SportsCarViewListController()
        carsViewList.showAddBtn = carsViewListShowAddBtn
        carsViewList.delegate = self
        let carsView = carsViewList.view!
        collectionView?.addSubview(carsView)
        carsView.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.top.equalTo(header.snp.bottom)
            make.height.equalTo(authCarListHeight)
        }
        //
//        let sepLine = UIView()
//        sepLine.backgroundColor = kTextGray28
//        carsView.addSubview(sepLine)
//        sepLine.snp.makeConstraints { (make) -> Void in
//            make.left.equalTo(carsView)
//            make.right.equalTo(carsView)
//            make.top.equalTo(carsView)
//            make.height.equalTo(0.5)
//        }
//        //
//        let sepLine2 = UIView()
//        sepLine2.backgroundColor = kTextGray28
//        carsView.addSubview(sepLine2)
//        sepLine2.snp.makeConstraints { (make) -> Void in
//            make.left.equalTo(carsView)
//            make.right.equalTo(carsView)
//            make.bottom.equalTo(carsView)
//            make.height.equalTo(0.5)
//        }
        //
        collectionView?.contentInset = UIEdgeInsetsMake(totalHeaderHeight - 20, 0, 0, 0)
        collectionView?.register(PersonStatusListCell.self, forCellWithReuseIdentifier: PersonStatusListCell.reuseIdentifier)
        collectionView?.register(SportCarInfoCell.self, forCellWithReuseIdentifier: SportCarInfoCell.reuseIdentifier)
        collectionView?.register(PersonStatusHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: PersonStatusHeader.reuseIdentifier)
        collectionView?.register(PersonAddStatusCell.self, forCellWithReuseIdentifier: PersonAddStatusCell.reuseIdentifier)
    }
    
    func navSettings() {
//        navigationItem.title = LS("我")
//        if isRoot {
//            homeBtn = BackToHomeBtn()
//            homeBtn.addTarget(self, action: #selector(navLeftBtnPressed), for: .touchUpInside)
//            self.navigationItem.leftBarButtonItem = homeBtn.wrapToBarBtn()
//        } else {
//            let backBtn = UIButton().config(self, selector: #selector(navLeftBtnPressed), image: UIImage(named: "account_header_back_btn"), contentMode: .scaleAspectFit)
//                .setFrame(CGRect(x: 0, y: 0, width: 15, height: 15))
//            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
//            
//        }
//        
//        let setting = UIButton().config(self, selector: #selector(navRightBtnPressed))
//            .setFrame(CGRect(x: 0, y: 0, width: 44, height: 44))
//        setting.addSubview(UIImageView.self).config(UIImage(named: "person_setting"), contentMode: .scaleAspectFit)
//            .layout { (make) in
//                make.centerY.equalTo(setting)
//                make.right.equalTo(setting)
//                make.size.equalTo(20)
//        }
//        setting.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: setting)
        
        navigationItem.title = getNavTitle()
        navigationItem.leftBarButtonItem = getNavLeftBtn()
        navigationItem.rightBarButtonItem = getNavRightBtn()
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
        return LS("我")
    }
    
    func navRightBtnPressed() {
        let settings = PersonMineSettings()
        self.navigationController?.pushViewController(settings, animated: true)
    }
    
    func navLeftBtnPressed() {
        if homeDelegate != nil {
            homeDelegate?.backToHome(nil)
        }else {
            navigationController?.delegate = oldNavDelegate
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if data.selectedCar == nil {
            return 1
        }else {
            return 2
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if data.selectedCar == nil {
            if data.user.isHost {
                return data.statusList.count + 1
            } else {
                return data.statusList.count
            }
        }else {
            if section == 0 {
                return 1
            }else {
                return data.statusDict[data.selectedCar!.ssidString]!.count
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if data.selectedCar == nil {
            if data.user.isHost {
                // 是当前用户，显示添加动态按钮
                if (indexPath as NSIndexPath).row == 0 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PersonAddStatusCell.reuseIdentifier, for: indexPath) as! PersonAddStatusCell
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PersonStatusListCell.reuseIdentifier, for: indexPath) as! PersonStatusListCell
                    let status = data.statusList[(indexPath as NSIndexPath).row - 1]
                    let statusImages = status.image
                    let statusCover = statusImages?.split(delimiter: ";").first()
//                    cell.cover.kf_setImageWithURL(SFURL(statusCover!)!)
                    cell.cover.kf.setImage(with: SFURL(statusCover!)!)
                    return cell
                }
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PersonStatusListCell.reuseIdentifier, for: indexPath) as! PersonStatusListCell
                let status = data.statusList[(indexPath as NSIndexPath).row]
                let statusImages = status.image
                let statusCover = statusImages?.split(delimiter: ";").first()
//                cell.cover.kf_setImageWithURL(SFURL(statusCover!)!)
                cell.cover.kf.setImage(with: SFURL(statusCover!)!)
                return cell
            }
        }else {
            if (indexPath as NSIndexPath).section == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SportCarInfoCell.reuseIdentifier, for: indexPath) as! SportCarInfoCell
                cell.car = data.selectedCar
                cell.delegate = self
                cell.mine = data.user.isHost
                cell.loadDataAndUpdateUI()
                return cell
            }else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PersonStatusListCell.reuseIdentifier, for: indexPath) as! PersonStatusListCell
                let statusList = data.statusDict[data.selectedCar!.ssidString]!
                let status = statusList[(indexPath as NSIndexPath).row]
                let statusImages = status.image
                let statusCover = statusImages?.split(delimiter: ";").first()
//                cell.cover.kf_setImageWithURL(SFURL(statusCover!)!)
                cell.cover.kf.setImage(with: SFURL(statusCover!)!)
                return cell
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var status: Status!
        // 找出选中的status
        if data.selectedCar == nil {
            if data.user.isHost {
                if (indexPath as NSIndexPath).row == 0 {
                    // show the status release view
                    let release = StatusReleaseController()
                    release.presenter = self
                    self.present(release.toNavWrapper(), animated: true, completion: nil)
                    return
                } else {
                    status = data.statusList[(indexPath as NSIndexPath).row - 1]
                }
            } else {
                status = data.statusList[(indexPath as NSIndexPath).row]
            }
        }else {
            if (indexPath as NSIndexPath).section == 0 {
                return
            }
            status = data.statusDict[data.selectedCar!.ssidString]![(indexPath as NSIndexPath).row]
        }
        selectedStatusCell = collectionView.cellForItem(at: indexPath)
        let detail = StatusDetailController(status: status)
//        detail.loadAnimated = false
        self.navigationController?.pushViewController(detail, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        if data.selectedCar == nil {
            return CGSize(width: screenWidth / 3 - 5, height: screenWidth / 3 - 5)
        }else {
            if (indexPath as NSIndexPath).section == 0 {
                return SportCarInfoCell.getPreferredSizeForSignature(data.selectedCar!.signature ?? "", carName: data.selectedCar!.name!, withAudioWave: data.selectedCar?.audioURL != nil)
            }else{
                return CGSize(width: screenWidth / 3 - 5, height: screenWidth / 3 - 5)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if data.selectedCar == nil {
            return CGSize.zero
        }else {
            if section == 0 {
                return CGSize.zero
            }else {
                return CGSize(width: UIScreen.main.bounds.width, height: 44)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if data.selectedCar == nil || section == 1 {
            return UIEdgeInsetsMake(5, 5, 5, 5)
        }
        return UIEdgeInsets.zero
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PersonStatusHeader.reuseIdentifier, for: indexPath) as! PersonStatusHeader
        header.titleLbl.text = LS("动态")
        return header
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.height - 1 {
            loadMoreStatusData()
        }
    }
}

// MARK: - About map
extension PersonBasicController: BMKLocationServiceDelegate, BMKMapViewDelegate {
    func didUpdate(_ userLocation: BMKUserLocation!) {
        if self.userLocation == nil {
            userAnno = BMKPointAnnotation()
            header.map.addAnnotation(userAnno)
        }
        userAnno.coordinate = userLocation.location.coordinate
        self.userLocation = userLocation
        let userLocInScreen = header.map.convert(userLocation.location.coordinate, toPointTo: header.map)
        let userLocWithOffset = CGPoint(x: userLocInScreen.x + header.frame.width / 4, y: userLocInScreen.y - header.frame.height / 3)
        let newCoordinate = header.map.convert(userLocWithOffset, toCoordinateFrom: header.map)
        let region = BMKCoordinateRegionMakeWithDistance(newCoordinate, 3000, 5000)

        header.map.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        let view = UserSelectAnnotationView(annotation: annotation, reuseIdentifier: "user_location")
        view?.annotation = annotation
        return view
    }
}

extension PersonBasicController {
    
    func didSelect(sportCar car: SportCar?) {
        if data.selectedCar == nil && car == nil {
            // 
            carsViewList.selectAllStatus(true)
        } else if car == nil {
            carsViewList.selectAllStatus(false)
        }
        data.selectedCar = car
        // 当car是nil时，代表显示所有的动态，直接
        self.collectionView?.reloadData()
    }

    func needAddSportCar() {
        // show sportcar brand select controller
//        let detail = SportCarBrandSelecterController()
//        detail.delegate = self
//        let nav = BlackBarNavigationController(rootViewController: detail)
//        self.presentViewController(nav, animated: true, completion: nil)
        let detail = ManufacturerOnlineSelectorController()
        detail.delegate = self
        present(detail.toNavWrapper(), animated: true, completion: nil)   
    }
    
    /**
     按下跑车编辑按钮
     */
    func carNeedEdit(_ own: SportCar) {
        let detail = SportCarInfoDetailController()
        detail.car = own
        self.navigationController?.pushViewController(detail, animated: true)
    }
    
    /**
     头像旁边的详情按钮按下
     */
    func detailBtnPressed() {
        let detail = PersonMineInfoController()
        self.navigationController?.pushViewController(detail, animated: true)
    }
    
//    func brandSelected(manufacturer: String?, carType: String?) {
//        self.dismissViewControllerAnimated(true, completion: nil)
//        if manufacturer == nil || carType == nil {
//            return
//        }
//
//        let toast = showStaticToast(LS("获取跑车数据中..."))
//        SportCarRequester.sharedInstance.querySportCarWith(manufacturer!, carName: carType!, onSuccess: { (data) -> () in
//            self.hideToast(toast)
//            guard let data = data else {
//                return
//            }
//            let carImgURL = SF(data["image_url"].stringValue)
//            let headers = [LS("具体型号"), LS("爱车签名"), LS("价格"), LS("发动机"), LS("扭矩"), LS("车身结构"), LS("最高时速"), LS("百公里加速")]
//            let contents = [carType, nil, data["price"].string, data["engine"].string, data["transmission"].string, data["body"].string, data["max_speed"].string, data["zeroTo60"].string]
//            let detail = SportCarSelectDetailController()
//            detail.delegate = self
//            detail.headers = headers
//            detail.carId = data["carID"].stringValue
//            detail.contents = contents
//            detail.carType = carType
//            detail.carDisplayURL = NSURL(string: carImgURL ?? "")
//            self.navigationController?.pushViewController(detail, animated: true)
//            }) { (code) -> () in
//                // 弹窗说明错误
//                self.hideToast(toast)
//                self.showToast(LS("获取跑车数据失败"))
//        }
//    }
    
    func sportCarBrandOnlineSelectorDidCancel() {
        dismiss(animated: true, completion: nil)
    }
    
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
    
    func sportCarSelectDeatilDidAddCar(_ car: SportCar) {
        data.addCar(car)
        carsViewList.cars = data.cars
        carsViewList.selectedCar = car
        carsViewList.collectionView?.reloadData()
        self.collectionView?.reloadData()
    }
}

extension PersonBasicController: UINavigationControllerDelegate {
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
}

extension PersonBasicController: StatusCoverPresentable {
    func initialCoverPosition() -> CGRect {
        return selectedStatusCell!.convert(selectedStatusCell!.bounds, to: navigationController!.view)
    }
}

// MARK: - Utilities
extension PersonBasicController {
    
    /**
     json数据处理器
     
     - parameter json:      json数据
     - parameter container: 输入输出，容纳生成的status对象的数组
     */
    func jsonDataHandler(_ json: JSON, container: inout [Status]) {
        let data = json.arrayValue
        for statusJSON in data {
            let newStatus: Status = try! MainManager.sharedManager.getOrCreate(statusJSON)
            container.append(newStatus)
        }
        container = $.uniq(container, by: { $0.ssid })
        container.sort { (s1, s2) -> Bool in
            switch s1.createdAt!.compare(s2.createdAt!) {
            case .orderedAscending:
                return false
            default:
                return true
            }
        }
    }
    
    func loadMoreStatusData() {
        if data.selectedCar != nil{
            let selectedCarID = data.selectedCar!.ssidString
            let targetStatusList = data.statusDict[selectedCarID]
            var dateThreshold = Date()
            if targetStatusList!.count > 0 {
                dateThreshold = targetStatusList!.last!.createdAt!
            }
            let statusRequester = AccountRequester2.sharedInstance
            _ = statusRequester.getStatusListSimplified(data.user.ssidString, carID: selectedCarID, dateThreshold: dateThreshold, limit: 10, onSuccess: { (json) -> () in
                self.jsonDataHandler(json!, container: &(self.data.statusDict[selectedCarID]!))
                self.collectionView?.reloadData()
                }, onError: { (code) -> () in
            }).registerForRequestManage(self)
        }else {
            let targetStatusList = data.statusList
            var dateThreshold = Date()
            if targetStatusList.count > 0 {
                dateThreshold = targetStatusList.last!.createdAt!
            }
            let statusRequester = AccountRequester2.sharedInstance
            _ = statusRequester.getStatusListSimplified(data.user.ssidString, carID: nil, dateThreshold: dateThreshold, limit: 10, onSuccess: { (json) -> () in
                self.jsonDataHandler(json!, container: &(self.data.statusList))
                self.collectionView?.reloadData()
                }, onError: { (code) -> () in
            }).registerForRequestManage(self)
        }
    }
    
    func onStatusDelete(_ notification: Foundation.Notification) {
        // TODO: implement this
        // For now, just ignore this todo
        if let status = (notification as NSNotification).userInfo?[kStatusKey] as? Status {
            data.deleteStatus(status)
            DispatchQueue.main.async(execute: { 
                self.collectionView?.reloadData()
            })
        }
        
    }
    
    func onStatusNew(_ notification: Foundation.Notification) {
        guard let status = (notification as NSNotification).userInfo?[kStatusKey] as? Status else {
            return
        }
        
        data.newStatus(status)
        needReloadUserInfo = true
        DispatchQueue.main.async { 
            self.collectionView?.reloadData()
        }
    }
    
    func onSportCarDeleted(_ notification: Foundation.Notification) {
        if notification.name.rawValue == kCarDeletedNotification {
            if let car = (notification as NSNotification).userInfo?[kSportcarKey] as? SportCar{
                data.deleteCar(car)
                data.selectedCar = nil
                self.carsViewList.cars = data.cars
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                    self.carsViewList.collectionView?.reloadData()
                })
            }
        }
    }
    
    func fanslistPressed() {
        let fans = FansSelectController()
        fans.targetUser = data.user
        self.navigationController?.pushViewController(fans, animated: true)
    }
    
    func followlistPressed() {
        let follow = FollowSelectController()
        follow.targetUser = data.user
        self.navigationController?.pushViewController(follow, animated: true)
    }
    
    func statuslistPressed() {
        carsViewList.selectedCar = nil
        carsViewList.collectionView?.reloadData()
        didSelect(sportCar: nil)
    }
}

class PersonAddStatusCell: UICollectionViewCell {
    static let reuseIdentifier = "person_add_status_cell"
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        self.contentView.clipsToBounds = true
        self.contentView.addSubview(UIImageView.self)
            .config(UIImage(named: "release_status_in_person"), contentMode: .scaleAspectFill)
            .layout { (make) in
                make.edges.equalTo(self.contentView)
        }
    }
}

class PersonStatusListCell: UICollectionViewCell {
    static let reuseIdentifier = "person_status_list_cell"
    var cover: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        cover = UIImageView()
        cover.contentMode = .scaleAspectFill
        cover.clipsToBounds = true
        self.contentView.addSubview(cover)
        cover.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self.contentView)
        }
    }
}
