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
    
    var toast: UIView?
    var rp_currentRequest: Request?
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        carsViewListShowAddBtn = false
        super.viewDidLoad()
        navSettings()
        trackTargetUserLocation()
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Override this to disable self.locating
        rp_cancelRequest()
    }
    
    func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = LS("个人信息")
        //
        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        backBtn.frame = CGRect(x: 0, y: 0, width: 10.5, height: 18)
        backBtn.addTarget(self, action: "navLeftBtnPressed", forControlEvents: .TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        //
        let shareBtn = UIButton()
        shareBtn.setImage(UIImage(named: "status_detail_other_operation"), forState: .Normal)
        shareBtn.imageView?.contentMode = .ScaleAspectFit
        shareBtn.frame = CGRect(x: 0, y: 0, width: 24, height: 214)
        shareBtn.addTarget(self, action: "navRightBtnPressed", forControlEvents: .TouchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareBtn)
        //
    }
    
    override func navRightBtnPressed() {
        let report = ReportBlacklistViewController(parent: self)
        self.presentViewController(report, animated: false, completion: nil)
    }
    
    override func navLeftBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /*
     基于basic改造而来，主要是替换了用户信息面板的类
    */
    
    override func getPersonInfoPanel() -> PersonHeaderMine {
        let panel = PersonHeaderOther()
        totalHeaderHeight = 906 / 750 * self.view.frame.width
        panel.followBtn.addTarget(self, action: "followBtnPressed:", forControlEvents: .TouchUpInside)
        panel.chatBtn.addTarget(self, action: "chatBtnPressed", forControlEvents: .TouchUpInside)
        panel.locBtn.addTarget(self, action: "locateBtnPressed", forControlEvents: .TouchUpInside)
        //
        if data.user.followed {
            panel.followBtn.setImage(UIImage(named: "person_followed"), forState: .Normal)
            panel.followBtnTmpImage.image = UIImage(named: "person_followed")
        }
        panel.fanslistBtn.addTarget(self, action: "fanslistPressed", forControlEvents: .TouchUpInside)
        panel.followlistBtn.addTarget(self, action: "followlistPressed", forControlEvents: .TouchUpInside)
        panel.statuslistBtn.addTarget(self, action: "statuslistPressed", forControlEvents: .TouchUpInside)
        panel.detailBtn.addTarget(self, action: "detailBtnPressed", forControlEvents: .TouchUpInside)
        return panel
    }
    
    func followBtnPressed(sender: UIButton) {
        let requester = PersonRequester.requester
        requester.follow(self.data.user.userID!, onSuccess: { (json) -> () in
            let board = self.header as! PersonHeaderOther
            
            if json!.boolValue {
                board.followBtnTmpImage.image = UIImage(named: "person_add_follow")
                board.followBtn.setImage(UIImage(named: "person_followed"), forState: .Normal)
            }else{
                board.followBtnTmpImage.image = UIImage(named: "person_followed")
                board.followBtn.setImage(UIImage(named: "person_add_follow"), forState: .Normal)
            }
            board.followBtnTmpImage.hidden = false
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                board.followBtnTmpImage.layer.opacity = 0
                }, completion: { (_) -> Void in
                    board.followBtnTmpImage.hidden = false
            })
            }) { (code) -> () in
                print(code)
        }
    }
    
    func chatBtnPressed() {
        if let room = self.navigationController?.viewControllers.fetch(-3) as? ChatRoomController where room.targetUser == self.data.user{
            self.navigationController?.popViewControllerAnimated(true)
            return
        }

        ChatRecordDataSource.sharedDataSource.start()
        let room = ChatRoomController()
        ChatRecordDataSource.sharedDataSource.curRoom = room
        room.targetUser = data.user
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
        toast = self.showConfirmToast(LS("跳转到地图导航?"), target: self, confirmSelector: "openMapToNavigate", cancelSelector: "hideToast")
    }
    
    func hideToast() {
        if toast != nil {
            self.hideToast(toast!)
        }
    }
    
    func openMapToNavigate() {
        self.hideToast(toast!)
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
            let options: [String: AnyObject] = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                MKLaunchOptionsMapTypeKey: NSNumber(unsignedInteger: MKMapType.Standard.rawValue)]
            MKMapItem.openMapsWithItems([target], launchOptions: options)
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
        } else {
            rp_currentRequest = RadarRequester.requester.trackUser(data.user.userID!, onSuccess: { (json) -> () in
                self.userLoc = Location(latitude: json!["lat"].doubleValue, longitude: json!["lon"].doubleValue, description: json!["description"].stringValue)
                self.userAnno.coordinate = self.userLoc!.location
                let region = BMKCoordinateRegionMakeWithDistance(self.userLoc!.location, 3000, 5000)
                self.header.map.setRegion(region, animated: true)
                }) { (code) -> () in
                    print(code)
            }
        }
    }
}
