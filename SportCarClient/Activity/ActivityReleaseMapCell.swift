//
//  ActivityReleaseMapCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/19.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Mapbox


class ActivityReleaseMapCell: UITableViewCell, MGLMapViewDelegate {
    
    static let reuseIdentifier = "activity_release_map_cell"
    
    var map: MGLMapView!
    var locInput: UITextField!
    var mapAnno: MGLPointAnnotation?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self.contentView
        superview.backgroundColor = UIColor.whiteColor()
        //
        map = MGLMapView(frame: CGRectZero, styleURL: kMapStyleURL)
        superview.addSubview(map)
        map.scrollEnabled = false
        map.rotateEnabled = false
        map.delegate = self
        map.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self)
        }
        //
        let locInputContainer = UIView()
        locInputContainer.backgroundColor = UIColor.whiteColor()
        locInputContainer.layer.cornerRadius = 4
        locInputContainer.layer.shadowColor = UIColor.blackColor().CGColor
        locInputContainer.layer.shadowOpacity = 0.5
        locInputContainer.layer.shadowOffset = CGSizeMake(1, 1.5)
        locInputContainer.backgroundColor = UIColor.blueColor()
        superview.addSubview(locInputContainer)
        locInputContainer.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.height.equalTo(50)
            make.width.equalTo(superview).multipliedBy(0.776)
            make.top.equalTo(map).offset(22)
        }
        //
        let locIcon = UIImageView(image: UIImage(named: "news_comment_icon"))
        locInputContainer.addSubview(locIcon)
        locIcon.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(22)
            make.left.equalTo(locInputContainer).offset(15)
            make.centerY.equalTo(locInputContainer)
        }
        //
        let wrapper = UIScrollView()
        locInputContainer.addSubview(wrapper)
        wrapper.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(locIcon.snp_right).offset(17)
            make.height.equalTo(locIcon)
            make.centerY.equalTo(locInputContainer)
            make.right.equalTo(locInputContainer).offset(-15)
        }
        //
        locInput = UITextField()
        locInput.backgroundColor = UIColor.redColor()
        locInput.textColor = UIColor.blackColor()
        locInput.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        wrapper.addSubview(locInput)
        locInput.autoresizingMask = [.FlexibleHeight , .FlexibleWidth]
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