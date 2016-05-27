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
    var actNameLbl: UILabel!
    var actStartDateLbl: UILabel!
    var doneMark: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        self.contentView.backgroundColor = UIColor.clearColor()
        container = self.contentView.addSubview(UIView.self).config(UIColor.whiteColor())
            .addShadow()
            .layout({ (make) in
                make.edges.equalTo(self.contentView)
            })
        cover = container.addSubview(UIImageView.self).config(nil)
        cover.layout({ (make) in
                make.right.equalTo(container)
                make.left.equalTo(container)
                make.top.equalTo(container)
                make.height.equalTo(cover.snp_width).multipliedBy(0.588)
            })
        actNameLbl = container.addSubview(UILabel.self)
            .config(17, fontWeight: UIFontWeightSemibold, textColor: UIColor.blackColor(), multiLine: false)
            .layout({ (make) in
                make.top.equalTo(cover.snp_bottom).offset(15)
                make.left.equalTo(container).offset(12)
                make.right.equalTo(container).offset(-12)
            })
        let sepLine = container.addSubview(UIView.self).config(UIColor.blackColor())
            .layout { (make) in
                make.left.equalTo(actNameLbl)
                make.top.equalTo(actNameLbl.snp_bottom).offset(6)
                make.width.equalTo(26)
                make.height.equalTo(2)
        }
        actStartDateLbl = container.addSubview(UILabel.self)
            .config(12, textColor: UIColor(white: 0.72, alpha: 1))
            .layout({ (make) in
                make.left.equalTo(sepLine)
                make.top.equalTo(sepLine.snp_bottom).offset(20)
            })
        doneMark = container.addSubview(UIImageView.self).config(UIImage(named: "activity_done"))
            .layout({ (make) in
                make.bottom.equalTo(cover).offset(-7)
                make.right.equalTo(cover).offset(-13)
                make.size.equalTo(CGSizeMake(44, 18.5))
            })
        self.clipsToBounds = false
        self.addShadow()
    }
    
    private func loadDataAndUpdateUI() {
        cover.kf_setImageWithURL(act.posterURL!)
        actNameLbl.text = act.name
        actStartDateLbl.text = act.startAt?.stringDisplay()
        if act.endAt!.compare(NSDate()) == .OrderedAscending{
            doneMark.hidden = false
        }else{
            doneMark.hidden = true
        }
    }
}