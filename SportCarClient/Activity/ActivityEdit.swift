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
        mapView?.viewWillAppear()
        if !setCenterFlag {
            let region = BMKCoordinateRegionMakeWithDistance(self.userLocation!, 3, 5)
            setCenterFlag = true
            mapView?.setRegion(region, animated: true)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        geoSearch?.delegate = nil
        mapView?.delegate = nil
        mapView?.viewWillDisappear()
    }
    
    func setInitial() {
        startAtDate = act.startAt
        startAt = act.startAt!.stringDisplay()!
        endAtDate = act.endAt
        endAt = act.endAt!.stringDisplay()!
        board.actNameInput.text = act.name
        board.actDesInput.text = act.actDescription
        board.actDesInputWordCount.text = "\(act.actDescription!.length)/40"
        board.posterLbl.hidden = true
        board.posterBtn.kf_setImageWithURL(act.posterURL!, forState: .Normal)
        userLocation = act.location?.coordinate
        self.tableView.reloadData()
    }

    override func navRightBtnPressed() {
        
    }
}