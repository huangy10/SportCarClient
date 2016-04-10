//
//  ActivityMapCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/16.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

class MapCell: UITableViewCell {
    
    static let reuseIdentifier = "user_usable_map_cell"
    
    var map: BMKMapView!
    var centerSet: Bool = false
    var locBtn: UIButton!
    var locLbl: UILabel!
    var locDesIcon: UIImageView!
    var loc: CLLocationCoordinate2D?
    
    var trailingHeight: CGFloat = 0
    
    init (trailingHeight: CGFloat) {
        super.init(style: .Default, reuseIdentifier: MapCell.reuseIdentifier)
        self.trailingHeight = trailingHeight
        self.selectionStyle = .None
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("map deinit")
    }
    
    func createSubviews() {
        map = BMKMapView()
        self.contentView.addSubview(map)
        map.scrollEnabled = false
        map.zoomEnabled = false
        map.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.contentView).inset(UIEdgeInsetsMake(0, 0, -trailingHeight, 0))
        }
        //
        let locDesContainer = UIButton()
        locDesContainer.backgroundColor = UIColor.whiteColor()
        locDesContainer.layer.cornerRadius = 4
        locDesContainer.layer.shadowColor = UIColor.blackColor().CGColor
        locDesContainer.layer.shadowOpacity = 0.5
        locDesContainer.layer.shadowOffset = CGSizeMake(1, 1.5)
        self.contentView.addSubview(locDesContainer)
        locDesContainer.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.contentView)
            make.height.equalTo(50)
            make.width.equalTo(self.contentView).multipliedBy(0.776)
            make.top.equalTo(map!).offset(22)
        }
        locBtn = locDesContainer
        //
        locDesIcon = UIImageView(image: UIImage(named: "news_comment_icon"))
        locDesContainer.addSubview(locDesIcon)
        locDesIcon.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(20)
            make.left.equalTo(locDesContainer).offset(15)
            make.centerY.equalTo(locDesContainer)
        }
        //
        locLbl = UILabel()
        locLbl.textColor = UIColor.blackColor()
        locLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        locDesContainer.addSubview(locLbl)
        locLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(locDesIcon.snp_right).offset(17 )
            make.height.equalTo(locDesIcon)
            make.centerY.equalTo(locDesContainer)
            make.right.equalTo(locDesContainer).offset(-15)
        }
        //
        let marker = UIImageView(image: UIImage(named: "map_default_marker"))
        self.contentView.addSubview(marker)
        marker.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(map) //.offset(CGPointMake(0, -trailingHeight/2))
            make.size.equalTo(CGSizeMake(38, 74))
        }
    }
    
    func setMapCenter(center: CLLocationCoordinate2D) {
        loc = center
        let region = BMKCoordinateRegionMakeWithDistance(center, 3, 5)
        map.setRegion(region, animated: true)
        centerSet = true
    }
    
}
