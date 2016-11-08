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


class PersonController: UIViewController, RequestManageMixin, LoadingProtocol {
    var delayWorkItem: DispatchWorkItem?
    weak var homeDelegate: HomeDelegate?
    
    var header: PersonHeaderView!
    var tableView: UITableView!
    var refresh: UIRefreshControl!
    
    var data: PersonDataSourceDelegate!
    var user: User {
        return data.user
    }
    
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
            
            tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: header.requiredHeight())
            
            if data.numberOfStatus() == 0 {
                refresh.beginRefreshing()
                reqGetStatusList(overrideReqKey: "auto")
            } else {
                header.loadDataAndUpdateUI()
                tableView.reloadData()
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
        
        refresh.beginRefreshing()
        pullToRefresh()
    }
    
    func configureNavBar() {
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
        return LS(user.isHost ? "我" : "个人信息")
    }
    
    func configureTableView() {
        tableView = UITableView()
        tableView.backgroundColor = kGeneralTableViewBGColor
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        tableView.register(PersonStatusListGroupCell.self, forCellReuseIdentifier: "cell")
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
        let settings = PersonMineSettings()
        navigationController?.pushViewController(settings, animated: true)
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
            self.parseStatusData(json!.arrayValue, forCar: curSelectedCar)
            self.tableView.reloadData()
            
            self.decrTaskCountDown()
        }, onError: { (code) -> () in
            self.showReqError(withCode: code)
            self.decrTaskCountDown(withSuccessFlag: true)
        }).registerForRequestManage(self, forKey: reqKeyFromFunctionName(withExtraID: overrideReqKey))
    }
    
    func parseStatusData(_ json: [JSON], forCar car: SportCar?) {
        var buf: [Status] = []
        for data in json {
            let status = try! MainManager.sharedManager.getOrCreate(data) as Status
            buf.append(status)
        }
        data.updateStatusList(forCar: car, withData: buf)
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
}

extension PersonController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let statusNum = data.numberOfStatusCell()
        if statusNum == 0 {
            return 0
        }
        return (statusNum - 1) / 3 + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        likeBtnPressed()
    }
   
    func likeBtnPressed() {
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
