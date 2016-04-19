//
//  PersonController.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/9.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SwiftyJSON

class PersonBasicController: UICollectionViewController, UICollectionViewDelegateFlowLayout, SportCarViewListDelegate, SportCarInfoCellDelegate, SportCarBrandSelecterControllerDelegate, BMKLocationServiceDelegate, BMKMapViewDelegate, SportCarSelectDetailProtocol {
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
    
    deinit {
        print("deinit person basic controller")
    }
    
    init(user: User) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Vertical
        flowLayout.minimumInteritemSpacing = 2.5
        flowLayout.minimumLineSpacing = 2.5
        super.init(collectionViewLayout: flowLayout)
        
        data = PersonDataSource()
        data.user = user
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PersonBasicController.onStatusDelete(_:)), name: kStatusDidDeletedNotification, object: nil)
        
        createSubviews()
        navSettings()
        
        locationService = BMKLocationService()
        
        // 发出网络请求
        let requester = PersonRequester.requester
        
        // 这个请求是保证当前用户的数据是最新的，而hostuser中的数据可以暂时先直接拿来展示
        requester.getProfileDataFor(data.user.ssidString, onSuccess: { (json) -> () in
            let hostUser = self.data.user
            try! hostUser.loadDataFromJSON(json!, detailLevel: 1)
            self.header.user = hostUser
            self.header.loadDataAndUpdateUI()
            }) { (code) -> ()? in
                print(code)
        }
        // 获取认证车辆的列表
        requester.getAuthedCars(data.user.ssidString, onSuccess: { (json) -> () in
            self.data.handleAuthedCarsJSONResponse(json!, user: self.data.user)
            self.data.selectedCar = self.data.cars.first()
            self.carsViewList.cars = self.data.cars
            // 默认选择第一辆认证的车辆
            self.carsViewList.selectedCar = self.data.cars.first()
            self.carsViewList.collectionView?.reloadData()
            self.collectionView?.reloadData()
            }) { (code) -> () in
                print(code)
        }
        // 第三个响应：开始获取的动态列表，每次获取十个
        let statusRequester = StatusRequester.SRRequester
        statusRequester.getStatusListSimplified(data.user.ssidString, carID: nil, dateThreshold: NSDate(), limit: 10, onSuccess: { (json) -> () in
            //
            self.jsonDataHandler(json!, container: &self.data.statusList)
            self.collectionView?.reloadData()
            }) { (code) -> () in
                print(code)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
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
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        locationService?.delegate = nil
        locationService?.stopUserLocationService()
        header.map.delegate = self
        header.map.viewWillDisappear()
    }
    
    /**
     重写这个方法来替换header所用的类型,header必须是PersonheaderMine的基类
     
     - returns: header对象
     */
    func getPersonInfoPanel() -> PersonHeaderMine {
        let screenWidth = self.view.frame.width
        totalHeaderHeight = 773.0 / 750 * screenWidth
        let header = PersonHeaderMine()
        header.detailBtn.addTarget(self, action: #selector(PersonBasicController.detailBtnPressed), forControlEvents: .TouchUpInside)
        
        header.fanslistBtn.addTarget(self, action: #selector(PersonBasicController.fanslistPressed), forControlEvents: .TouchUpInside)
        header.followlistBtn.addTarget(self, action: #selector(PersonBasicController.followlistPressed), forControlEvents: .TouchUpInside)
        header.statuslistBtn.addTarget(self, action: #selector(PersonBasicController.statuslistPressed), forControlEvents: .TouchUpInside)
        return header
    }
    
    func createSubviews() {
        let superview = self.view
        collectionView?.backgroundColor = UIColor(red: 0.157, green: 0.173, blue: 0.184, alpha: 1)
        //
        let screenWidth = superview.frame.width
        let authCarListHeight: CGFloat = 62
        header = getPersonInfoPanel()
        collectionView?.addSubview(header)
        // TODO: 这里手动添加了status bar的高度值
        header.frame = CGRectMake(0, -totalHeaderHeight, screenWidth, totalHeaderHeight - authCarListHeight)
        header.user = data.user
        //
        carsViewList = SportsCarViewListController()
        carsViewList.showAddBtn = carsViewListShowAddBtn
        carsViewList.delegate = self
        let carsView = carsViewList.view
        collectionView?.addSubview(carsView)
        carsView.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.top.equalTo(header.snp_bottom)
            make.height.equalTo(authCarListHeight)
        }
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.72, alpha: 1)
        carsView.addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(carsView)
            make.right.equalTo(carsView)
            make.top.equalTo(carsView)
            make.height.equalTo(0.5)
        }
        //
        let sepLine2 = UIView()
        sepLine2.backgroundColor = UIColor(white: 0.72, alpha: 1)
        carsView.addSubview(sepLine2)
        sepLine2.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(carsView)
            make.right.equalTo(carsView)
            make.bottom.equalTo(carsView)
            make.height.equalTo(0.5)
        }
        //
        collectionView?.contentInset = UIEdgeInsetsMake(totalHeaderHeight - 20, 0, 0, 0)
        collectionView?.registerClass(PersonStatusListCell.self, forCellWithReuseIdentifier: PersonStatusListCell.reuseIdentifier)
        collectionView?.registerClass(SportCarInfoCell.self, forCellWithReuseIdentifier: SportCarInfoCell.reuseIdentifier)
        collectionView?.registerClass(PersonStatusHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: PersonStatusHeader.reuseIdentifier)
    }
    
    func navSettings() {
        navigationItem.title = LS("我")
        if isRoot {
            homeBtn = BackToHomeBtn()
            homeBtn.addTarget(self, action: #selector(navLeftBtnPressed), forControlEvents: .TouchUpInside)
            self.navigationItem.leftBarButtonItem = homeBtn.wrapToBarBtn()
        } else {
            let backBtn = UIButton().config(self, selector: #selector(navLeftBtnPressed), image: UIImage(named: "account_header_back_btn"), contentMode: .ScaleAspectFit)
                .setFrame(CGRectMake(0, 0, 15, 15))
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
            
        }
//        let backBtn = UIButton().config(self, selector: #selector(navLeftBtnPressed), image: UIImage(named: "home_back"), contentMode: .ScaleAspectFit)
//            .setFrame(CGRectMake(0, 0, 15, 15))
//        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        
        let setting = UIButton().config(self, selector: #selector(navRightBtnPressed))
            .setFrame(CGRectMake(0, 0, 44, 44))
        setting.addSubview(UIImageView).config(UIImage(named: "person_setting"), contentMode: .ScaleAspectFit)
            .layout { (make) in
                make.centerY.equalTo(setting)
                make.right.equalTo(setting)
                make.size.equalTo(20)
        }
        setting.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: setting)
    }
    
    func navRightBtnPressed() {
        let settings = PersonMineSettings()
        self.navigationController?.pushViewController(settings, animated: true)
    }
    
    func navLeftBtnPressed() {
        if homeDelegate != nil {
            homeDelegate?.backToHome(nil, screenShot: self.getScreenShotBlurred(false))
        }else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if data.selectedCar == nil {
            return 1
        }else {
            return 2
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if data.selectedCar == nil {
            return data.statusList.count
        }else {
            if section == 0 {
                return 1
            }else {
                return data.statusDict[data.selectedCar!.ssidString]!.count
            }
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if data.selectedCar == nil {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PersonStatusListCell.reuseIdentifier, forIndexPath: indexPath) as! PersonStatusListCell
            let status = data.statusList[indexPath.row]
            let statusImages = status.image
            let statusCover = statusImages?.split(";").first()
            cell.cover.kf_setImageWithURL(SFURL(statusCover!)!)
            return cell
        }else {
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SportCarInfoCell.reuseIdentifier, forIndexPath: indexPath) as! SportCarInfoCell
                cell.car = data.selectedCar
                cell.delegate = self
                cell.mine = data.user.isHost
                cell.loadDataAndUpdateUI()
                return cell
            }else {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PersonStatusListCell.reuseIdentifier, forIndexPath: indexPath) as! PersonStatusListCell
                let statusList = data.statusDict[data.selectedCar!.ssidString]!
                let status = statusList[indexPath.row]
                let statusImages = status.image
                let statusCover = statusImages?.split(";").first()
                cell.cover.kf_setImageWithURL(SFURL(statusCover!)!)
                return cell
            }
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // 找出选中的status
        var status: Status
        if data.selectedCar == nil {
            status = data.statusList[indexPath.row]
        }else {
            if indexPath.section == 0 {
                return
            }
            status = data.statusDict[data.selectedCar!.ssidString]![indexPath.row]
        }
        let detail = StatusDetailController(status: status)
        detail.loadAnimated = false
        self.navigationController?.pushViewController(detail, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = UIScreen.mainScreen().bounds.width
        if data.selectedCar == nil {
            return CGSizeMake(screenWidth / 3 - 5, screenWidth / 3 - 5)
        }else {
            if indexPath.section == 0 {
                return SportCarInfoCell.getPreferredSizeForSignature(data.selectedCar!.signature ?? "", carName: data.selectedCar!.name!)
            }else{
                return CGSizeMake(screenWidth / 3 - 5, screenWidth / 3 - 5)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if data.selectedCar == nil {
            return CGSizeZero
        }else {
            if section == 0 {
                return CGSizeZero
            }else {
                return CGSizeMake(UIScreen.mainScreen().bounds.width, 44)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if data.selectedCar == nil || section == 1 {
            return UIEdgeInsetsMake(5, 5, 5, 5)
        }
        return UIEdgeInsetsZero
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

        let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: PersonStatusHeader.reuseIdentifier, forIndexPath: indexPath) as! PersonStatusHeader
        header.titleLbl.text = LS("动态")
        return header
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.height - 1 {
            loadMoreStatusData()
        }
    }
}

// MARK: - About map
extension PersonBasicController {
    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
        if self.userLocation == nil {
            userAnno = BMKPointAnnotation()
            header.map.addAnnotation(userAnno)
        }
        userAnno.coordinate = userLocation.location.coordinate
        self.userLocation = userLocation
        let userLocInScreen = header.map.convertCoordinate(userLocation.location.coordinate, toPointToView: header.map)
        let userLocWithOffset = CGPointMake(userLocInScreen.x + header.frame.width / 4, userLocInScreen.y - header.frame.height / 3)
        let newCoordinate = header.map.convertPoint(userLocWithOffset, toCoordinateFromView: header.map)
        let region = BMKCoordinateRegionMakeWithDistance(newCoordinate, 3000, 5000)

        header.map.setRegion(region, animated: true)
    }
    
    func mapView(mapView: BMKMapView!, viewForAnnotation annotation: BMKAnnotation!) -> BMKAnnotationView! {
        let view = UserSelectAnnotationView(annotation: annotation, reuseIdentifier: "user_location")
        view.annotation = annotation
        return view
    }
}

extension PersonBasicController {
    
    func didSelectSportCar(own: SportCar?) {
        if data.selectedCar == nil && own == nil {
            // 
            carsViewList.selectAllStatus(true)
        } else if own == nil {
            carsViewList.selectAllStatus(false)
        }
        data.selectedCar = own
        // 当car是nil时，代表显示所有的动态，直接
        self.collectionView?.reloadData()
    }

    func needAddSportCar() {
        // show sportcar brand select controller
        let detail = SportCarBrandSelecterController()
        detail.delegate = self
        let nav = BlackBarNavigationController(rootViewController: detail)
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    /**
     按下跑车编辑按钮
     */
    func carNeedEdit(own: SportCar) {
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
    
    func brandSelected(manufacturer: String?, carType: String?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        if manufacturer == nil || carType == nil {
            return
        }

        let toast = showStaticToast(LS("获取跑车数据中..."))
        let requester = SportCarRequester.sharedSCRequester
        requester.querySportCarWith(manufacturer!, carName: carType!, onSuccess: { (data) -> () in
            self.hideToast(toast)
            let carImgURL = SF(data["image_url"].stringValue)
            let headers = [LS("具体型号"), LS("跑车签名"), LS("价格"), LS("发动机"), LS("扭矩"), LS("车身结构"), LS("最高时速"), LS("百公里加速")]
            let contents = [carType, nil, data["price"].string, data["engine"].string, data["transmission"].string, data["body"].string, data["max_speed"].string, data["zeroTo60"].string]
            let detail = SportCarSelectDetailController()
            detail.delegate = self
            detail.headers = headers
            detail.carId = data["carID"].stringValue
            detail.contents = contents
            detail.carType = carType
            detail.carDisplayURL = NSURL(string: carImgURL ?? "")
            self.navigationController?.pushViewController(detail, animated: true)
            }) { (code) -> () in
                // 弹窗说明错误
                self.hideToast(toast)
                self.showToast(LS("获取跑车数据失败"))
        }
    }
    
    func sportCarSelectDeatilDidAddCar(car: SportCar) {
        data.addCar(car)
        carsViewList.cars = data.cars
        carsViewList.selectedCar = car
        carsViewList.collectionView?.reloadData()
    }
}

// MARK: - Utilities
extension PersonBasicController {
    
    /**
     json数据处理器
     
     - parameter json:      json数据
     - parameter container: 输入输出，容纳生成的status对象的数组
     */
    func jsonDataHandler(json: JSON, inout container: [Status]) {
        let data = json.arrayValue
        for statusJSON in data {
            let newStatus: Status = try! MainManager.sharedManager.getOrCreate(statusJSON)
            container.append(newStatus)
        }
        container.sortInPlace { (s1, s2) -> Bool in
            switch s1.createdAt!.compare(s2.createdAt!) {
            case .OrderedAscending:
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
            var dateThreshold = NSDate()
            if targetStatusList!.count > 0 {
                dateThreshold = targetStatusList!.last()!.createdAt!
            }
            let statusRequester = StatusRequester.SRRequester
            statusRequester.getStatusListSimplified(data.user.ssidString, carID: selectedCarID, dateThreshold: dateThreshold, limit: 10, onSuccess: { (json) -> () in
                self.jsonDataHandler(json!, container: &(self.data.statusDict[selectedCarID]!))
                self.collectionView?.reloadData()
                }, onError: { (code) -> () in
                    print(code)
            })
        }else {
            let targetStatusList = data.statusList
            var dateThreshold = NSDate()
            if targetStatusList.count > 0 {
                dateThreshold = targetStatusList.last()!.createdAt!
            }
            let statusRequester = StatusRequester.SRRequester
            statusRequester.getStatusListSimplified(data.user.ssidString, carID: nil, dateThreshold: dateThreshold, limit: 10, onSuccess: { (json) -> () in
                self.jsonDataHandler(json!, container: &(self.data.statusList))
                self.collectionView?.reloadData()
                }, onError: { (code) -> () in
                    print(code)
            })
        }
    }
    
    func onStatusDelete(notification: NSNotification) {
        // TODO: implement this
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
        didSelectSportCar(nil)
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
        cover.contentMode = .ScaleAspectFill
        cover.clipsToBounds = true
        self.contentView.addSubview(cover)
        cover.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.contentView)
        }
    }
}
