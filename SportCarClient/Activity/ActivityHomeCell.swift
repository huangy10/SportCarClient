//
//  ActivityHomeCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/13.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class ActivityCell: UICollectionViewCell {
    static let reuseIdentifier = "activity_cell"
    
    var act: Activity! {
        didSet {
            loadDataAndUpdateUI()
        }
    }
    
    var container: UIView!
    var cover: UIImageView!
    var coverMask: UIImageView!
    var actNameLbl: UILabel!
    var actStartDateLbl: UILabel!
    var doneMark: UIImageView!
    var avatar: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        self.contentView.backgroundColor = UIColor.clear
        
        container = self.contentView.addSubview(UIView.self)
            .layout({ (make) in
                make.edges.equalTo(self.contentView)
            })
        cover = container.addSubview(UIImageView.self).config(nil)
            .layout({ (make) in
                make.edges.equalTo(container)
            })
        cover.contentMode = .scaleAspectFill
        coverMask = container.addSubview(UIImageView.self).config(UIImage(named: "activityMask"))
            .layout({ (make) in
                make.bottom.equalTo(cover)
                make.centerX.equalTo(cover)
                make.width.equalTo(cover)
                make.height.equalTo(cover.snp.width).multipliedBy(0.66)
            })
        avatar = container.addSubview(UIImageView.self).config(nil)
            .layout({ (make) in
                make.left.equalTo(cover).offset(15)
                make.size.equalTo(16)
                make.bottom.equalTo(cover).offset(-10)
            }).toRound(8)
        actStartDateLbl = container.addSubview(UILabel.self)
            .config(12, fontWeight: UIFontWeightRegular, textColor: UIColor(white: 1, alpha: 0.7), textAlignment: .left, text: "", multiLine: false)
            .layout({ (make) in
                make.left.equalTo(avatar.snp.right).offset(5)
                make.centerY.equalTo(avatar)
            })
        actNameLbl = container.addSubview(UILabel.self)
            .config(16, fontWeight: UIFontWeightSemibold, textColor: UIColor.white, textAlignment: .left, text: "", multiLine: false)
            .layout({ (make) in
                make.left.equalTo(avatar)
                make.right.equalTo(container).offset(-15)
                make.bottom.equalTo(avatar.snp.top).offset(-5)
            })
        doneMark = container.addSubview(UIImageView.self).config(UIImage(named: "activity_done"))
            .layout({ (make) in
                make.top.equalTo(cover).offset(10)
                make.right.equalTo(cover).offset(-13)
                make.size.equalTo(CGSize(width: 44, height: 18.5))
            })
        self.contentView.clipsToBounds = false
        self.contentView.addShadow(3, color: UIColor.black, opacity: 0.4, offset: CGSize(width: 0, height: 2.5))
    }

    fileprivate func loadDataAndUpdateUI() {
        cover.kf.setImage(with: act.posterURL!)
        avatar.kf.setImage(with: act.user!.avatarURL!)
        actNameLbl.text = act.name
        actStartDateLbl.text = act.startAt?.stringDisplay()
        if act.endAt!.compare(Date()) == .orderedAscending{
            doneMark.isHidden = false
        }else{
            doneMark.isHidden = true
        }
    }
}

