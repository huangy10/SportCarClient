//
//  ActivityReleaseCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/17.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class ActivityReleaseCell: UITableViewCell {
    
    static let reuseIdentifier = "activity_release_cell"
    
    var staticLbl: UILabel!
    var infoInput: UITextField!
    var arrowIcon: UIImageView!
    var staticInfoLabel: UILabel!
    
    var arrowDirection: String = "left"{
        didSet {
            switch arrowDirection {
            case "left":
                break
            case "down":
                break
            default:
                break
            }
        }
    }
    
    var editable: Bool = true{
        didSet {
            if editable {
                infoInput.hidden = false
                staticInfoLabel.hidden = true
            }else {
                infoInput.hidden = true
                staticInfoLabel.hidden = false
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self.contentView
        self.backgroundColor = UIColor.whiteColor()
        //
        staticLbl = UILabel()
        staticLbl.textColor = UIColor(white: 0.72, alpha: 1)
        staticLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        superview.addSubview(staticLbl)
        staticLbl.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(superview)
            make.left.equalTo(superview).offset(15)
        }
        //
        arrowIcon = UIImageView(image: UIImage(named: "account_btn_next_icon"))
        superview.addSubview(arrowIcon)
        arrowIcon.contentMode = .ScaleAspectFit
        arrowIcon.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(superview)
            make.size.equalTo(15)
        }
        //
        let wrapper = UIScrollView()
        superview.addSubview(wrapper)
        wrapper.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(arrowIcon.snp_left).offset(-15)
            make.centerY.equalTo(superview)
            make.left.equalTo(staticLbl.snp_right)
            make.height.equalTo(staticLbl)
        }
        //
        infoInput = UITextField()
        infoInput.textColor = UIColor.blackColor()
        infoInput.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        wrapper.addSubview(infoInput)
        infoInput.textAlignment = .Right
        infoInput.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(wrapper)
            make.size.equalTo(wrapper)
//            make.right.equalTo(arrowIcon.snp_left).offset(-15)
//            make.centerY.equalTo(superview)
//            make.left.equalTo(staticLbl.snp_right)
//            make.height.equalTo(staticLbl)
        }
        staticInfoLabel = UILabel()
        staticInfoLabel.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        staticInfoLabel.userInteractionEnabled = false
        staticInfoLabel.textColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(staticInfoLabel)
        staticInfoLabel.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(wrapper)
        }
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.933, alpha: 1)
        superview.addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(staticLbl.snp_bottom).offset(11)
            make.right.equalTo(superview).offset(-15)
            make.left.equalTo(superview).offset(15)
            make.height.equalTo(0.5)
        }
    }
}
