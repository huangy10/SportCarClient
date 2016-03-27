//
//  ActivityReleasePresentable.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/4.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class ActivityReleasePresentableController: ActivityReleaseController {
    /// The view controller who present this controller
    weak var presenter: UIViewController?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if presenter == nil {
            assertionFailure("Present this controller by calling presentFrom:")
        }
    }
    
    deinit {
        print("deinit activity release presentable")
    }
    
    override func navLeftBtnPressed() {
        presenter?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func navRightBtnPressed() {
        //        self.navigationController?.popViewControllerAnimated(true)
        self.inputFields.each { (view) -> () in
            view?.resignFirstResponder()
        }
        // Check integrity of the data to be sent
        guard let actName = board.actNameInput.text where actName != "" else{
            self.showToast(LS("请填写活动名称"))
            return
        }
        
        guard let actDes = board.actDesInput.text where board.actDesEditStart else {
            self.showToast(LS("请填写活动描述"))
            return
        }
        
        guard let posterImage = self.poster else{
            self.showToast(LS("请选择活动海报"))
            return
        }
        
        if userLocation == nil{
            self.showToast(LS("无法获取当前位置"))
            return
        }
        
        if startAtDate == nil {
            self.showToast(LS("请选择活动开始时间"))
            return
        }
        
        if endAtDate == nil {
            self.showToast(LS("请选择活动截止时间"))
            return
        }
        
        var informUser: [String]? = nil
        if board.informOfUsers.count > 0 {
            informUser = board.informOfUsers.map({ (user) -> String in
                return user.ssidString
            })
        }
        
        // make the request
        let requester = ActivityRequester.requester
        self.pp_showProgressView()
        let clubLimitIDString: String? = clubLimitID == nil ? nil : "\(clubLimitID!)"
        requester.createNewActivity(actName, des: actDes, informUser: informUser, maxAttend: attendNum, startAt: startAtDate!, endAt: endAtDate!, clubLimit: clubLimitIDString, poster: posterImage, lat: userLocation!.latitude, lon: userLocation!.longitude, loc_des: locDescriptin ?? "", onSuccess: { (json) -> () in
            // TODO: send a global notification to make corresponding activity list update
            self.pp_hideProgressView()
                self.presenter?.dismissViewControllerAnimated(true, completion: nil)
            
            }, onProgress: { (progress) -> () in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.pp_updateProgress(progress)
                })
            }) { (code) -> () in
                self.pp_hideProgressView()
                print(code)
        }
    }
    
    func presentFrom(controller: UIViewController) {
        presenter = controller
        let wrapper = BlackBarNavigationController(rootViewController: self)
        presenter?.presentViewController(wrapper, animated: true, completion: nil)
    }
}
