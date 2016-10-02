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
    var wrapper: UIScrollView!
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
                wrapper.isHidden = false
                staticInfoLabel.isHidden = true
            }else {
                wrapper.isHidden = true
                staticInfoLabel.isHidden = false
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
        self.selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self.contentView
        self.backgroundColor = UIColor.white
        //
        staticLbl = UILabel()
        staticLbl.textColor = UIColor(white: 0.72, alpha: 1)
        staticLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        superview.addSubview(staticLbl)
        staticLbl.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(superview)
            make.left.equalTo(superview).offset(15)
        }
        //
        arrowIcon = UIImageView(image: UIImage(named: "account_btn_next_icon"))
        superview.addSubview(arrowIcon)
        arrowIcon.contentMode = .scaleAspectFit
        arrowIcon.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(superview)
            make.size.equalTo(15)
        }
        //
        wrapper = UIScrollView()
        superview.addSubview(wrapper)
        wrapper.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(arrowIcon.snp.left).offset(-15)
            make.centerY.equalTo(superview)
            make.left.equalTo(staticLbl.snp.right)
            make.height.equalTo(staticLbl)
        }
        wrapper.isUserInteractionEnabled = false
        //
        infoInput = UITextField()
        infoInput.textColor = UIColor.black
        infoInput.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        wrapper.addSubview(infoInput)
        infoInput.textAlignment = .right
        infoInput.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(wrapper)
            make.size.equalTo(wrapper)
        }
        
        staticInfoLabel = UILabel()
        staticInfoLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        staticInfoLabel.textColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(staticInfoLabel)
        staticInfoLabel.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(wrapper)
        }
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.933, alpha: 1)
        superview.addSubview(sepLine)
        sepLine.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(staticLbl.snp.bottom).offset(11)
            make.right.equalTo(superview).offset(-15)
            make.left.equalTo(superview).offset(15)
            make.height.equalTo(0.5)
        }
    }
}
