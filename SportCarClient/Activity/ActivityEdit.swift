//
//  ActivityEdit.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/27.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation

class ActivityEditController: ActivityReleaseController {
    var act: Activity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitial()
    }
    
    override func viewWillAppear(animated: Bool) {
        geoSearch?.delegate = self
        mapView.viewWillAppear()
        mapView.zoomLevel = 16
        mapView.setCenterCoordinate(userLocation!, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        geoSearch?.delegate = nil
        mapView.delegate = nil
        mapView.viewWillDisappear()
    }
    
    func setInitial() {
        startAt = act.startAt
        endAt = act.endAt
        nameInput.text = act.name
        desInput.text = act.actDescription
        maxAttend = Int(act.maxAttend)
        desWordCountLbl.text = "\(act.actDescription!.length)/40"
        imagePickerBtn.kf_setImageWithURL(act.posterURL!, forState: .Normal, placeholderImage: nil)
        imagePickerBtn.kf_setImageWithURL(act.posterURL!, forState: .Normal, placeholderImage: nil, optionsInfo: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
            self.poster = image
        }
        userLocation = act.location?.coordinate
        self.tableView.reloadData()
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
        ActivityRequester.sharedInstance.activityEdit(
            self.act.ssidString, name: actName, des: actDes, informUser: selectedUserIDs, maxAttend: maxAttend, startAt: startAtDate, endAt: endAtDate, clubLimit: clubLimitID, poster: posterImage, lat: loc.latitude, lon: loc.longitude, loc_des: locDescription ?? "", onSuccess: { (json) in
                self.navigationController?.popViewControllerAnimated(true)
                if let mine = self.actHomeController?.mine {
                    mine.refreshControl.beginRefreshing()
                    mine.getLatestActData()
                }
                self.hideToast(toast)
                self.pp_hideProgressView()
                if let presenter = self.presentingViewController {
                    presenter.showToast(LS("修改成功"))
                } else {
                    self.showToast(LS("修改成功!"))
                }
                
            }, onProgress: { (progress) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.pp_updateProgress(progress)
                })
        }) { (code) in
            dispatch_async(dispatch_get_main_queue(), {
                self.hideToast(toast)
                self.showToast(LS("修改失败，请检查网络设置"), onSelf: true)
                self.pp_hideProgressView()
            })
        }
    }
}