//
//  BillboardCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/8/15.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class BillboardCell: UITableViewCell {
    var club: Club!
    var order: Int = 0
    var orderChange: Int = 0
    
    // ===============================
    var container: UIView!
    var icon: UIImageView!
    var nameLbl: UILabel!
    var descriLbl: UILabel!
    var upAndDownStaticLbl: UILabel!
    var upAndDownLbl: UILabel!
    var upAndDownIcon: UIImageView!
    var newMarkerLbl: UILabel!
    var orderLbl: UILabel!
    var sepLine: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        configSelf()
        configureContrainer()
        configureClubInfo()
        configureOrderLbl()
        configureOrderDisplay()
        configureSepLine()
    }
    
    func configSelf() {
        selectionStyle = .none
    }
    
    func configureContrainer() {
        container = contentView.addSubview(UIView.self)
            .config(UIColor.white)
            .layout({ (make) in
                make.top.equalTo(contentView)
                make.left.equalTo(contentView).offset(10)
                make.right.equalTo(contentView).offset(-10)
                make.bottom.equalTo(contentView)
            })
        contentView.backgroundColor = UIColor(white: 0, alpha: 0.06)
    }
    
    func configureOrderLbl() {
//        orderStaticLbl = contentView.addSubview(UILabel)
//            .config(12, fontWeight: UIFontWeightRegular, textColor: UIColor(white: 0, alpha: 0.38), textAlignment: .Left, text: LS("排名"))
//            .layout({ (make) in
//                make.centerY.equalTo(nameLbl)
//                make.left.equalTo(container).offset(11)
//            })
        orderLbl = contentView.addSubview(UILabel.self)
        orderLbl.font = getOrderTextFont(17)
        orderLbl.textColor = UIColor(white: 0, alpha: 0.2)
        orderLbl.snp.makeConstraints { (make) in
            make.left.equalTo(container).offset(11)
            make.centerY.equalTo(icon)
        }
    }
    
    func configureClubInfo() {
        icon = contentView.addSubview(UIImageView.self)
            .layout({ (make) in
                make.centerY.equalTo(contentView).offset(-3)
                make.left.equalTo(container).offset(40)
                make.size.equalTo(45)
            })
        icon.layer.cornerRadius = 22.5
        icon.clipsToBounds = true
        nameLbl = contentView.addSubview(UILabel.self)
            .config(14, fontWeight: UIFontWeightRegular, textColor: UIColor.black, textAlignment: .left)
            .layout({ (make) in
                make.left.equalTo(icon.snp.right).offset(13)
                make.top.equalTo(icon).offset(3)
            })
        descriLbl = contentView.addSubview(UILabel.self)
            .config(12, fontWeight: UIFontWeightRegular, textColor: UIColor(white: 0, alpha: 0.58), textAlignment: .left)
            .layout({ (make) in
                make.left.equalTo(nameLbl)
                make.bottom.equalTo(icon).offset(-2)
            })
    }
    
    func configureOrderDisplay() {
        upAndDownStaticLbl = contentView.addSubview(UILabel.self)
            .config(10, fontWeight: UIFontWeightRegular, textColor: UIColor(white: 0, alpha: 0.38), textAlignment: .right)
            .layout({ (make) in
                make.centerY.equalTo(nameLbl)
                make.right.equalTo(container).offset(-13)
            })
        upAndDownStaticLbl.text = LS("升降")
        upAndDownLbl = contentView.addSubview(UILabel.self)
            .config(10, fontWeight: UIFontWeightRegular, textColor: UIColor.black, textAlignment: .right)
            .layout({ (make) in
                make.right.equalTo(upAndDownStaticLbl)
                make.top.equalTo(descriLbl)
            })
        upAndDownIcon = contentView.addSubview(UIImageView.self)
            .layout({ (make) in
                make.right.equalTo(upAndDownLbl.snp.left).offset(-4)
                make.centerY.equalTo(upAndDownLbl)
                make.size.equalTo(8)
            })
        newMarkerLbl = contentView.addSubview(UILabel.self)
            .config(12, fontWeight: UIFontWeightRegular, textColor: UIColor.RGB(255, 21, 21), textAlignment: .center, text: "new")
            .layout({ (make) in
                make.centerX.equalTo(upAndDownStaticLbl)
                make.bottom.equalTo(upAndDownLbl)
            })
        newMarkerLbl.isHidden = true
    }
    
    func configureSepLine() {
        sepLine = contentView.addSubview(UIView.self)
            .config(UIColor(white: 0, alpha: 0.12))
            .layout({ (make) in
                make.right.equalTo(container)
                make.bottom.equalTo(container)
                make.left.equalTo(icon)
                make.height.equalTo(0.5)
            })
    }
    
    func setData(_ club: Club, order: Int, orderChange: Int, new: Bool) {
        self.club = club
        self.order = order
        self.orderChange = orderChange
        
        icon.kf.setImage(with: club.logoURL!)
        nameLbl.text = getNameLblContent()
        descriLbl.text = getDescriLblContent()
        orderLbl.text = "\(order)"
        upAndDownLbl.text = "\(abs(orderChange))"
        if new {
            newMarkerLbl.isHidden = false
            upAndDownLbl.isHidden = true
            upAndDownIcon.isHidden = true
        } else {
            newMarkerLbl.isHidden = true
            upAndDownIcon.isHidden = false
            upAndDownLbl.isHidden = false
            if orderChange > 0 {
                upAndDownIcon.image = UIImage(named: "order_change_up")
                upAndDownLbl.textColor = UIColor.RGB(255, 21, 21)
            } else if orderChange < 0 {
                upAndDownIcon.image = UIImage(named: "order_change_down")
                upAndDownLbl.textColor = UIColor.RGB(100, 170, 2)
            } else {
                upAndDownIcon.image = UIImage(named: "order_change_stay")
                upAndDownLbl.textColor = UIColor(white: 0, alpha: 0.2)
            }
        }
    }
    
    func getOrderTextFont(_ size: CGFloat) -> UIFont {
        let fontName = UIFont.fontNames(forFamilyName: "Titillium Web")
        return UIFont(name: fontName[0], size: size)!
//        return UIFont.systemFontOfSize(size, weight: UIFontWeightSemibold)
    }
    
    func getNameLblContent() -> String {
        return "\(club.name!) (\(club.memberNum))"
    }
    
    func getDescriLblContent() -> String {
        if club.city == "" {
            return "价值\(club.value/10000)万"
        } else {
            return "\(club.city!) 价值\(club.value/10000)万"
        }
    }
}

class BillboardFirstThree: BillboardCell {
    var greatMark: UIView!
    var orderStaticLbl: UILabel!
    
    override func createSubviews() {
        greatMark = contentView.addSubview(UIView.self)
        super.createSubviews()
        contentView.bringSubview(toFront: greatMark)
        greatMark.snp.makeConstraints { (make) in
            make.left.equalTo(container)
            make.bottom.equalTo(icon).offset(-3)
            make.size.equalTo(CGSize(width: 2.5, height: 40))
        }
        contentView.layoutIfNeeded()
    }
//    
//    func configureGreatMark() {
//        greatMark = contentView.addSubview(UIView)
//            .layout({ (make) in
//                make.left.equalTo(content)
//                make.bottom.equalTo(icon)
//                make.size.equalTo(CGSizeMake(2.5, 40))
//            })
//    }
    
    override func configureOrderLbl() {
        orderStaticLbl = contentView.addSubview(UILabel.self)
            .config(12, fontWeight: UIFontWeightRegular, textColor: UIColor(white: 0, alpha: 0.38), textAlignment: .left, text: LS("排名"))
            .layout({ (make) in
                make.left.equalTo(container).offset(12)
                make.top.equalTo(greatMark)
            })
        orderLbl = contentView.addSubview(UILabel.self)
        orderLbl.font = UIFont.systemFont(ofSize: 32, weight: UIFontWeightSemibold)
        orderLbl.snp.makeConstraints { (make) in
            make.left.equalTo(container).offset(12)
            make.bottom.equalTo(greatMark)
            make.top.equalTo(orderStaticLbl.snp.bottom)
            make.right.equalTo(icon.snp.left)
        }
    }
    
    override func configureContrainer() {
        container = contentView.addSubview(UIView.self)
            .config(UIColor.white)
            .addShadow()
            .layout({ (make) in
                make.top.equalTo(contentView)
                make.left.equalTo(contentView).offset(10)
                make.right.equalTo(contentView).offset(-10)
                make.bottom.equalTo(contentView).offset(-5)
            })
        contentView.backgroundColor = UIColor(white: 0, alpha: 0.06)
    }
    
    override func configureSepLine() {
        // do nothing
    }
    
    override func setData(_ club: Club, order: Int, orderChange: Int, new: Bool) {
        super.setData(club, order: order, orderChange: orderChange, new: new)
        if order == 1 {
            orderLbl.textColor = UIColor.RGB(255, 0, 0, alpha: 0.87)
            orderLbl.font = getOrderTextFont(32)
        } else if order == 2 {
            orderLbl.textColor = UIColor.RGB(255, 193, 92)
            orderLbl.font = getOrderTextFont(27)
        } else {
            orderLbl.textColor = UIColor(white: 0, alpha: 0.38)
            orderLbl.font = getOrderTextFont(22)
        }
        greatMark.backgroundColor = orderLbl.textColor
    }
}
