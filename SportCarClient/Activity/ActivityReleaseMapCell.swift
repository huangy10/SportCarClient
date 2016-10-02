//
//  ActivityReleaseMapCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/19.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class ActivityReleaseMapCell: UITableViewCell {
    
    static let reuseIdentifier = "activity_release_map_cell"
    
    var map:BMKMapView!
//    var locInput: UITextField!
    var locDisplay: UILabel!
    var mapAnno: BMKPointAnnotation!
    
    var trailingHeight: CGFloat = 0
    
    var onInvokeLocationSelect: (()->())? = nil
    
    init (trailingHeight: CGFloat) {
        super.init(style: .default, reuseIdentifier: MapCell.reuseIdentifier)
        self.trailingHeight = trailingHeight
        self.selectionStyle = .none
        createSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self.contentView
        superview.backgroundColor = UIColor.white
        //
        map = BMKMapView()
        superview.addSubview(map)
        map.viewWillAppear()
        map.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self.contentView).inset(UIEdgeInsetsMake(0, 0, -trailingHeight, 0))
        }
        //
        
//        let locInputContainer = UIView()
//        locInputContainer.backgroundColor = UIColor.whiteColor()
//        locInputContainer.layer.shadowColor = UIColor.blackColor().CGColor
//        locInputContainer.layer.shadowOpacity = 0.5
//        locInputContainer.layer.shadowOffset = CGSizeMake(1, 1.5)
//        superview.addSubview(locInputContainer)
//        locInputContainer.snp_makeConstraints { (make) -> Void in
//            make.centerX.equalTo(superview)
//            make.height.equalTo(50)
//            make.width.equalTo(superview).multipliedBy(0.776)
//            make.top.equalTo(map).offset(22)
//        }
        
        let locInputContainer = superview.addSubview(UIButton.self)
            .config(self, selector: #selector(contentInputPressed))
            .config(UIColor.white)
            .addShadow()
            .layout { (make) in
                make.centerX.equalTo(superview)
                make.height.equalTo(50)
                make.width.equalTo(superview).multipliedBy(0.776)
                make.top.equalTo(map).offset(22)
        }
        //
        let locIcon = UIImageView(image: UIImage(named: "news_comment_icon"))
        locInputContainer.addSubview(locIcon)
        locIcon.snp.makeConstraints { (make) -> Void in
            make.size.equalTo(22)
            make.left.equalTo(locInputContainer).offset(15)
            make.centerY.equalTo(locInputContainer)
        }
        //
//        let wrapper = UIScrollView()
//        locInputContainer.addSubview(wrapper)
//        wrapper.snp_makeConstraints { (make) -> Void in
//            make.left.equalTo(locIcon.snp_right).offset(17)
//            make.height.equalTo(locIcon)
//            make.centerY.equalTo(locInputContainer)
//            make.right.equalTo(locInputContainer).offset(-15)
//        }
        //
        let marker = UIImageView(image: UIImage(named: "map_default_marker"))
        marker.contentMode = .scaleAspectFit
        superview.addSubview(marker)
        marker.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(map)
            make.size.equalTo(CGSize(width: 38, height: 74))
        }
        //
//        locInput = UITextField()
//        locInput.textColor = UIColor.blackColor()
//        locInput.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
//        wrapper.addSubview(locInput)
//        locInput.autoresizingMask = [.FlexibleHeight , .FlexibleWidth]
        
        locDisplay = locInputContainer.addSubview(UILabel.self)
            .config(14).layout({ (make) in
                make.left.equalTo(locIcon.snp.right).offset(17)
                make.height.equalTo(locIcon)
                make.centerY.equalTo(locInputContainer)
                make.right.equalTo(locInputContainer).offset(-15)
            })
    }
    
    func contentInputPressed() {
        if let handler = self.onInvokeLocationSelect {
            handler()
        } else {
            assertionFailure()
        }
    }
}
