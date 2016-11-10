//
//  MapAsFooter.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/11/10.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

protocol MapFooterDelegate: class {
    func mapFooterNavigatePressed()
}


class MapFooterView: UIView {
    
    weak var delegate: MapFooterDelegate!
    
    var map: BMKMapView!
    var locBtn: UIButton!
    var locDesIcon: UIImageView!
    var locDesLbl: UILabel!
    
    var centerCoordincate: CLLocationCoordinate2D!
    
    var trailingHeight: CGFloat = 0
    
    init (trailingHeight: CGFloat = 0) {
        super.init(frame: .zero)
        self.trailingHeight = trailingHeight
        
        configureMap()
        configureLocDisplay()
        configMapMarker()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func setCenterLocation(_ center: CLLocationCoordinate2D, withDes des: String) {
        let region = BMKCoordinateRegionMakeWithDistance(center, 3, 5)
        map.setRegion(region, animated: true)
        locDesLbl.text = des
    }
    
    func configureMap() {
        map = BMKMapView()
        addSubview(map)
        map.isScrollEnabled = false
        map.isZoomEnabled = false
        map.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsetsMake(0, 0, -trailingHeight, 0))
        }
    }
    
    func configureLocDisplay() {
        locBtn = addSubview(UIButton.self).config(self, selector: #selector(navigatePressed))
            .addShadow()
            .config(.white)
            .layout({ (mk) in
                mk.centerX.equalTo(self)
                mk.height.equalTo(50)
                mk.width.equalTo(self).multipliedBy(0.776)
                mk.top.equalTo(map).offset(22)
            })
        
        locDesIcon = locBtn.addSubview(UIImageView.self).config(UIImage(named: "location_mark_black"))
            .layout({ (mk) in
                mk.size.equalTo(20)
                mk.left.equalTo(locBtn).offset(15)
                mk.centerY.equalTo(locBtn)
            })
        locDesLbl = locBtn.addSubview(UILabel.self).config(14)
            .layout({ (mk) in
                mk.left.equalTo(locDesIcon.snp.right).offset(17)
                mk.centerY.equalTo(locBtn)
                mk.right.equalTo(locBtn).offset(-15)
            })
    }
    
    func configMapMarker() {
        let marker = addSubview(UIImageView.self).config(UIImage(named: "map_default_marker"))
            .layout { (mk) in
                mk.center.equalTo(map)
                mk.width.equalTo(38)
                mk.height.equalTo(74)
        }
        marker.contentMode = .scaleAspectFit
    }
    
    func navigatePressed() {
        delegate.mapFooterNavigatePressed()
    }
}
