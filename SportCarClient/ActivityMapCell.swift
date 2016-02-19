//
//  ActivityMapCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/16.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Mapbox


class MapCell: UITableViewCell, MGLMapViewDelegate {
    
    static let reuseIdentifier = "user_usable_map_cell"
    
    var map: MGLMapView!
    var locBtn: UIButton!
    var locLbl: UILabel!
    
    var mapAnno: MGLPointAnnotation?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        map = MGLMapView(frame: CGRectZero, styleURL: kMapStyleURL)
        self.contentView.addSubview(map)
        map.scrollEnabled = false
        map.rotateEnabled = false
        map.delegate = self
        map.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.contentView)
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
        let locDesIcon = UIImageView(image: UIImage(named: "news_comment_icon"))
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
    }
    
    func setMapCenter(center: CLLocationCoordinate2D) {
        map.setCenterCoordinate(center, zoomLevel: 12, animated: true)
        if mapAnno == nil {
            mapAnno = MGLPointAnnotation()
            mapAnno?.coordinate = center
            map.addAnnotation(mapAnno!)
        }
    }
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("user_current_location")
        
        if annotationImage == nil {
            annotationImage = MGLAnnotationImage(image: UIImage(named: "map_default_marker")!, reuseIdentifier: "user_current_location")
        }
        
        return annotationImage
    }
}
