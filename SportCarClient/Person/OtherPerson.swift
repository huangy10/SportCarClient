//
//  OtherPerson.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/11.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON
import Alamofire


class PersonOtherController: PersonBasicController, RequestProtocol {
    
    // backOffLocation
    var backOffLocation: Location?
    var userLoc: Location?
    
    var rp_currentRequest: Request?
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        header.map.delegate = self
    }
    
    override func viewDidLoad() {
        carsViewListShowAddBtn = false
        super.viewDidLoad()
        navSettings()
        trackTargetUserLocation()
    }
    
    override func configureNotficationObserveBehavior() {
        // do nothing
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Override this to disable self.locating
        rp_cancelRequest()
        header.map.delegate = nil
    }
    
    override func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = LS("个人信息")
        //
        let backBtn = UIButton().config(
            self, selector: #selector(navLeftBtnPressed),
            image: UIImage(named: "account_header_back_btn"))
            .setFrame(CGRect(x: 0, y: 0, width: 10.5, height: 18))
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        //
        let shareBtn = UIButton().config(
            self, selector: #selector(navRightBtnPressed),
            image: UIImage(named: "status_detail_other_operation"))
            .setFrame(CGRect(x: 0, y: 0, width: 24, height: 214))
        shareBtn.imageView?.contentMode = .scaleAspectFit
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareBtn)
        //
    }
    
    override func navRightBtnPressed() {
//        let report = ReportBlacklistViewController(userID: data.user.ssid, parent: self)
//        self.presentViewController(report, animated: false, completion: nil)
        let block = BlockUserController(user: data.user)
        block.presentFromRootViewController()
    }
    
    override func navLeftBtnPressed() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    /*
     基于basic改造而来，主要是替换了用户信息面板的类
    */
    
    override func getPersonInfoPanel() -> PersonHeaderMine {
        let panel = PersonHeaderOther()
        totalHeaderHeight = 920 / 750 * self.view.frame.width
        panel.followBtn.addTarget(self, action: #selector(PersonOtherController.followBtnPressed(_:)), for: .touchUpInside)
        panel.chatBtn.addTarget(self, action: #selector(PersonOtherController.chatBtnPressed), for: .touchUpInside)
        panel.locBtn.addTarget(self, action: #selector(PersonOtherController.locateBtnPressed), for: .touchUpInside)
        //
        if data.user.followed {
            panel.followBtn.setImage(UIImage(named: "person_followed"), for: UIControlState())
            panel.followBtnTmpImage.image = UIImage(named: "person_followed")
        }
        panel.fanslistBtn.addTarget(self, action: #selector(fanslistPressed), for: .touchUpInside)
        panel.followlistBtn.addTarget(self, action: #selector(followlistPressed), for: .touchUpInside)
        panel.statuslistBtn.addTarget(self, action: #selector(statuslistPressed), for: .touchUpInside)
        panel.detailBtn.addTarget(self, action: #selector(PersonBasicController.detailBtnPressed), for: .touchUpInside)
        return panel
    }
    
    func followBtnPressed(_ sender: UIButton) {
        let requester = AccountRequester2.sharedInstance
        lp_start()
        _ = requester.follow(self.data.user.ssidString, onSuccess: { (json) -> () in
            self.lp_stop()
            let board = self.header as! PersonHeaderOther
            
            if json!.boolValue {
                board.followBtnTmpImage.image = UIImage(named: "person_add_follow")
                board.followBtn.setImage(UIImage(named: "person_followed"), for: UIControlState())
            }else{
                board.followBtnTmpImage.image = UIImage(named: "person_followed")
                board.followBtn.setImage(UIImage(named: "person_add_follow"), for: UIControlState())
            }
            board.followBtnTmpImage.isHidden = false
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                board.followBtnTmpImage.layer.opacity = 0
                }, completion: { (_) -> Void in
                    board.followBtnTmpImage.isHidden = false
            })
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: kAccountInfoChanged), object: nil)
            }) { (code) -> () in
                self.lp_stop()
                self.showToast("Access Error: \(code)")
        }
    }
    
    func chatBtnPressed() {
        if self.navigationController!.viewControllers.count > 3, let room = self.navigationController?.viewControllers.fetch(index: -3) as? ChatRoomController , room.targetUser == self.data.user{
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        let room = ChatRoomController()
        room.targetUser = data.user
        room.chatCreated = false
        self.navigationController?.pushViewController(room, animated: true)
    }
    
    func locateBtnPressed() {
        guard userLoc != nil else {
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
        let center = userLoc!.location
        end.pt = center
        let targetName = userLoc!.description
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
    
    override func detailBtnPressed() {
        let detail = PersonOtherInfoController()
        detail.user = data.user
        self.navigationController?.pushViewController(detail, animated: true)
    }
    
    func trackTargetUserLocation() {
        userAnno = BMKPointAnnotation()
        if backOffLocation != nil {
            userAnno.coordinate = backOffLocation!.location
            let region = BMKCoordinateRegionMakeWithDistance(backOffLocation!.location, 3000, 5000)
            header.map.setRegion(region, animated: true)
            userLoc = backOffLocation
            header.map.addAnnotation(userAnno)
        } else {
            rp_currentRequest = RadarRequester.sharedInstance.trackUser(data.user.ssidString, onSuccess: { (json) -> () in
                self.userLoc = Location(latitude: json!["lat"].doubleValue, longitude: json!["lon"].doubleValue, description: json!["description"].stringValue, city: json!["city"].stringValue)
                self.userAnno.coordinate = self.userLoc!.location
                let userLocInScreen = self.header.map.convert(self.userLoc!.location, toPointTo: self.header.map)
                let userLocWithOffset = CGPoint(x: userLocInScreen.x + self.header.frame.width / 40, y: userLocInScreen.y - self.header.frame.height / 60)
                let newCoordinate = self.header.map.convert(userLocWithOffset, toCoordinateFrom: self.header.map)
                let region = BMKCoordinateRegionMakeWithDistance(newCoordinate, 3000, 5000)
//                let region = BMKCoordinateRegionMakeWithDistance(self.userLoc!.location, 3000, 5000)
                self.header.map.setRegion(region, animated: true)
                self.header.map.addAnnotation(self.userAnno)
                }) { (code) -> () in
                    self.showToast(LS("无法获取他/她的位置"))
            }
        }
    }
}
