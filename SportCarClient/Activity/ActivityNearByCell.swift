//
//  ActivityNearByCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/14.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class ActivityNearByCell: UICollectionViewCell {
    
    static let reuseIdentifier = "activity_near_by_cell"
    
    var act: Activity!
    
    var container: UIView!
    var cover: UIImageView!
    var actNameLbl: UILabel!
    var actStartDateLbl: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //
    func createSubviews() {
        var superview = self.contentView
        superview.backgroundColor = UIColor.clear
        //
        container = UIView()
        container.backgroundColor = UIColor.white
        superview.addSubview(container)
        container.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
         superview = container
        //
        cover = UIImageView()
        cover.contentMode = .scaleAspectFill
        cover.clipsToBounds = true
        superview.addSubview(cover)
        cover.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.top.equalTo(superview)
            make.height.equalTo(cover.snp_width).multipliedBy(0.588)
        }
        //
        actNameLbl = UILabel()
        actNameLbl.textColor = UIColor.black
        actNameLbl.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightSemibold)
        actNameLbl.numberOfLines = 0
        superview.addSubview(actNameLbl)
        actNameLbl.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(cover.snp_bottom).offset(15)
            make.left.equalTo(superview).offset(12)
            make.right.equalTo(superview).offset(-12)
        }
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor.black
        superview.addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(actNameLbl)
            make.top.equalTo(actNameLbl.snp_bottom).offset(6)
            make.width.equalTo(26)
            make.height.equalTo(2)
        }
        //
        actStartDateLbl = UILabel()
        actStartDateLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        actStartDateLbl.textColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(actStartDateLbl)
        actStartDateLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(sepLine)
            make.top.equalTo(sepLine.snp_bottom).offset(20)
        }
        //
        self.clipsToBounds = false
        self.layer.addDefaultShadow()
    }
    
    func loadDataAndUpdateUI() {
        cover.kf_setImageWithURL(SFURL(act.poster!)!)
        actNameLbl.text = act.name
        actStartDateLbl.text = act.startAt?.stringDisplay()
    }
}
