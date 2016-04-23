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
        self.inputFields.each { (view) in
            view?.resignFirstResponder()
        }
        // check integrity of the data
        guard let actName = nameInput.text where actName.length > 0 else {
            showToast(LS("请填写活动名称"), onSelf: true)
            return
        }
        guard let actDes = desInput.text where actDes.length > 0 else {
            showToast(LS("请填写活动描述"), onSelf: true)
            return
        }
        guard let posterImage = poster else {
            showToast(LS("请选择活动海报"), onSelf: true)
            return
        }
        guard let loc = userLocation else {
            showToast(LS("无法获取当前位置"), onSelf: true)
            return
        }
        guard let startAtDate = startAt, let endAtDate = endAt else {
            showToast(LS("请设置活动时间"), onSelf: true)
            return
        }
        let clubLimitID = clubLimit?.ssidString
        var selectedUserIDs: [String]? = nil
        if selectedUser.count > 0 {
            selectedUserIDs = selectedUser.map { $0.ssidString }
        }
        let toast = showStaticToast(LS("发布中..."))
        pp_showProgressView()
        ActivityRequester.requester.createNewActivity(actName, des: actDes, informUser: selectedUserIDs, maxAttend: maxAttend, startAt: startAtDate, endAt: endAtDate, clubLimit: clubLimitID, poster: posterImage, lat: loc.latitude, lon: loc.longitude, loc_des: locDescription ?? "", onSuccess: { (json) in
            self.presenter?.dismissViewControllerAnimated(true, completion: {
                self.presenter?.showToast(LS("发布成功"))
            })
            if let mine = self.actHomeController?.mine {
                mine.refreshControl.beginRefreshing()
                mine.getLatestActData()
            }
            self.hideToast(toast)
            self.pp_hideProgressView()
            }, onProgress: { (progress) in
                self.pp_updateProgress(progress)
        }) { (code) in
            self.showToast(LS("发布失败，请检查网络设置"), onSelf: true)
            self.pp_hideProgressView()
        }
    }
    
    func presentFrom(controller: UIViewController) {
        presenter = controller
        let wrapper = BlackBarNavigationController(rootViewController: self)
        presenter?.presentViewController(wrapper, animated: true, completion: nil)
    }
}
