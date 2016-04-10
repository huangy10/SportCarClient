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
        let region = BMKCoordinateRegionMakeWithDistance(self.userLocation!, 3, 5)
        mapView.setRegion(region, animated: true)
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
        desWordCountLbl.text = "\(act.actDescription!.length)/40"
        imagePickerBtn.kf_setImageWithURL(act.posterURL!, forState: .Normal, placeholderImage: nil)
        userLocation = act.location?.coordinate
        self.tableView.reloadData()
    }

    override func navRightBtnPressed() {
        
    }
}