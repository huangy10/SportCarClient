//
//  PersonController.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/9.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SwiftyJSON

class PersonBasicController: UICollectionViewController, UICollectionViewDelegateFlowLayout, SportCarViewListDelegate, SportCarInfoCellDelegate {
    // 显示的用户的信息
    var data: PersonDataSource!
    
    var header: PersonHeaderMine!
    var totalHeaderHeight: CGFloat = 0
    var carsViewList: SportsCarViewListController!
    
    init(user: User) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
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
        createSubviews()
        
        // 发出网络请求
        let requester = PersonRequester.requester
        
        // 这个请求是保证当前用户的数据是最新的，而hostuser中的数据可以暂时先直接拿来展示
        requester.getProfileDataFor(data.user.userID!, onSuccess: { (json) -> () in
            let hostUser = self.data.user
            hostUser.loadValueFromJSONWithProfile(json!)
            self.header.user = hostUser
            self.header.loadDataAndUpdateUI()
            }) { (code) -> ()? in
                print(code)
        }
        // 获取认证车辆的列表
        requester.getAuthedCars(data.user.userID!, onSuccess: { (json) -> () in
            self.data.handleAuthedCarsJSONResponse(json!, user: self.data.user)
            self.carsViewList.owns = self.data.owns
            self.carsViewList.collectionView?.reloadData()
            }) { (code) -> () in
                print(code)
        }
        // 第三个响应：开始获取的动态列表，每次获取十个
        let statusRequester = StatusRequester.SRRequester
        statusRequester.getStatusListSimplified(data.user.userID!, carID: nil, dateThreshold: NSDate(), limit: 10, onSuccess: { (json) -> () in
            //
            self.jsonDataHandler(json!, container: &self.data.statusList)
            self.collectionView?.reloadData()
            }) { (code) -> () in
                print(code)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    /**
     重写这个方法来替换header所用的类型,header必须是PersonheaderMine的基类
     
     - returns: header对象
     */
    func getPersonInfoPanel() -> PersonHeaderMine {
        let screenWidth = self.view.frame.width
        totalHeaderHeight = 848.0 / 750 * screenWidth
        let header = PersonHeaderMine()
        header.navRightBtn.addTarget(self, action: "navRightBtnPressed", forControlEvents: .TouchUpInside)
        header.navLeftBtn.addTarget(self, action: "navLeftBtnPressed", forControlEvents: .TouchUpInside)
        return header
    }
    
    func createSubviews() {
        let superview = self.view
        collectionView?.backgroundColor = UIColor.whiteColor()
        //
        let screenWidth = superview.frame.width
        let authCarListHeight: CGFloat = 62
        header = getPersonInfoPanel()
        collectionView?.addSubview(header)
//        header.snp_makeConstraints { (make) -> Void in
//            make.top.equalTo(collectionView!)
//            make.left.equalTo(superview)
//            make.right.equalTo(superview)
//            make.height.equalTo(header.snp_width).multipliedBy(0.968)
//        }
        // TODO: 这里手动添加了status bar的高度值
        header.frame = CGRectMake(0, -totalHeaderHeight, screenWidth, totalHeaderHeight - authCarListHeight)
        header.detailBtn.addTarget(self, action: "detailBtnPressed", forControlEvents: .TouchUpInside)
        //
        carsViewList = SportsCarViewListController()
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
    
    func navRightBtnPressed() {
        let settings = PersonMineSettings()
        self.navigationController?.pushViewController(settings, animated: true)
    }
    
    func navLeftBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
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
                return data.statusDict[data.selectedCar!.car!.carID!]!.count
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
                cell.own = data.selectedCar
                cell.delegate = self
                cell.loadDataAndUpdateUI()
                return cell
            }else {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PersonStatusListCell.reuseIdentifier, forIndexPath: indexPath) as! PersonStatusListCell
                let statusList = data.statusDict[data.selectedCar!.car!.carID!]!
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
            status = data.statusDict[data.selectedCar!.car!.carID!]![indexPath.row]
        }
        let detail = StatusDetailController(status: status)
        detail.loadAnimated = false
        self.navigationController?.pushViewController(detail, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = UIScreen.mainScreen().bounds.width
        if data.selectedCar == nil {
            return CGSizeMake(screenWidth / 2, screenWidth / 2)
        }else {
            if indexPath.section == 0 {
                return SportCarInfoCell.getPreferredSizeForSignature(data.selectedCar!.signature ?? "", carName: data.selectedCar!.car!.name!)
            }else{
                return CGSizeMake(screenWidth / 2, screenWidth / 2)
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

extension PersonBasicController {
    
    func didSelectSportCar(own: SportCarOwnerShip?) {
        data.selectedCar = own
        // 当car是nil时，代表显示所有的动态，直接
        collectionView?.reloadData()
    }
    
    func needAddSportCar() {
        
    }
    
    /**
     按下跑车编辑按钮
     */
    func carNeedEdit(own: SportCarOwnerShip) {
        let detail = SportCarInfoDetailController()
        detail.own = own
        self.navigationController?.pushViewController(detail, animated: true)
    }
    
    /**
     头像旁边的详情按钮按下
     */
    func detailBtnPressed() {
        let detail = PersonMineInfoController()
        self.navigationController?.pushViewController(detail, animated: true)
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
            let newStatus = Status.objects.getOrCreate(statusJSON).0
            container.append(newStatus!)
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
            let selectedCarID = data.selectedCar!.car!.carID!
            let targetStatusList = data.statusDict[selectedCarID]
            var dateThreshold = NSDate()
            if targetStatusList!.count > 0 {
                dateThreshold = targetStatusList!.last()!.createdAt!
            }
            let statusRequester = StatusRequester.SRRequester
            statusRequester.getStatusListSimplified(data.user.userID!, carID: selectedCarID, dateThreshold: dateThreshold, limit: 10, onSuccess: { (json) -> () in
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
            statusRequester.getStatusListSimplified(data.user.userID!, carID: nil, dateThreshold: dateThreshold, limit: 10, onSuccess: { (json) -> () in
                self.jsonDataHandler(json!, container: &(self.data.statusList))
                self.collectionView?.reloadData()
                }, onError: { (code) -> () in
                    print(code)
            })
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
        cover.contentMode = .ScaleAspectFill
        cover.clipsToBounds = true
        self.contentView.addSubview(cover)
        cover.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.contentView)
        }
    }
}
