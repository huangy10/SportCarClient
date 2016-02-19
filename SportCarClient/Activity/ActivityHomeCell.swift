//
//  ActivityHomeCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/13.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class ActivityHomeCell: UITableViewCell {
    
    static let reuseIdentifier = "activity_home_cell"
    var act: Activity!
    
    var container: UIView!
    var actCover: UIImageView!
    var backMaskView: BackMaskView!
    var actNameLbl: UILabel!
    var startDateLbl: UILabel!
    var doneIcon: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        self.contentView.backgroundColor = UIColor(red: 0.157, green: 0.173, blue: 0.184, alpha: 1)
        container = UIView()
        container.backgroundColor = UIColor.whiteColor()
        self.contentView.addSubview(container)
        container.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.contentView).inset(UIEdgeInsetsMake(10, 10, 0, 10))
        }
        let superview = container
        //
        actCover = UIImageView()
        superview.addSubview(actCover)
        actCover.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        // 284 + 166
        backMaskView = BackMaskView()
        backMaskView.centerHegiht = 112
        backMaskView.ratio = -0.162
        backMaskView.backgroundColor = UIColor.clearColor()
        superview.addSubview(backMaskView)
        backMaskView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        //
        startDateLbl = UILabel()
        startDateLbl.textColor = UIColor(white: 0.72, alpha: 1)
        startDateLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        superview.addSubview(startDateLbl)
        startDateLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(15)
            make.bottom.equalTo(superview).offset(-14)
        }
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor.blackColor()
        superview.addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(startDateLbl)
            make.bottom.equalTo(startDateLbl.snp_top).offset(-15)
            make.width.equalTo(26)
            make.height.equalTo(2)
        }
        //
        actNameLbl = UILabel()
        actNameLbl.textColor = UIColor.blackColor()
        actNameLbl.font = UIFont.systemFontOfSize(17, weight: UIFontWeightSemibold)
        actNameLbl.numberOfLines = 0
        superview.addSubview(actNameLbl)
        actNameLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(sepLine)
            make.bottom.equalTo(sepLine.snp_top).offset(-6)
            make.width.equalTo(superview).multipliedBy(0.5)
        }
        //
        doneIcon = UIImageView(image: UIImage(named: "activity_done"))
        superview.addSubview(doneIcon)
        doneIcon.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-26)
            make.bottom.equalTo(superview).offset(-6)
            make.size.equalTo(CGSizeMake(100, 85))
        }
        doneIcon.hidden = true
    }
    
    func loadDataAndUpdateUI() {
        actCover.kf_setImageWithURL(SFURL(act.poster!)!)
        actNameLbl.text = act.name
        startDateLbl.text = act.startAt?.stringDisplay()
        if act.endAt!.compare(NSDate()) == .OrderedAscending{
            doneIcon.hidden = false
        }else{
            doneIcon.hidden = true
        }
    }
    
    func setContentInset(insetValue: CGFloat) {
        container.snp_updateConstraints { (make) -> Void in
            make.edges.equalTo(self.contentView).inset(UIEdgeInsetsMake(insetValue, insetValue, 0, insetValue))
        }
    }
}