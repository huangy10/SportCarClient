//
//  SportCarDetailView.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/13.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

let kSportsCarInfoDetailStaticLabelString1 = [LS("品牌型号"), LS("跑车全称"), LS("跑车签名")]
let kSportsCarInfoDetailStaticLabelString2 = [LS("价格"), LS("发动机"), LS("变速箱"), LS("最高车速"), LS("百公里加速")]


class SportCarInfoDetailController: UITableViewController {
    
    var own: SportCarOwnerShip!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        //
        tableView.registerClass(SportCarInfoDetailHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.registerClass(PrivateChatSettingsHeader.self, forHeaderFooterViewReuseIdentifier: "text_header")
        tableView.registerClass(PrivateChatSettingsCommonCell.self, forCellReuseIdentifier: PrivateChatSettingsCommonCell.reuseIdentifier)
        tableView.separatorStyle = .None
        tableView.rowHeight = 50
    }
    
    func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = LS("跑车详情")
        //
        let navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        navLeftBtn.frame = CGRectMake(0, 0, 9, 15)
        navLeftBtn.addTarget(self, action: "navLeftBtnPressed", forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        //
        let rightItem = UIBarButtonItem(title: LS("删除"), style: .Done, target: self, action: "navRightBtnPressed")
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func navLeftBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func navRightBtnPressed() {
        // TODO: 删除该跑车
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return kSportsCarInfoDetailStaticLabelString1.count
        }else{
            return kSportsCarInfoDetailStaticLabelString2.count
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return UIScreen.mainScreen().bounds.width * 0.588 / 2
        }
        else{
            return 50
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! SportCarInfoDetailHeader
            header.carImage.kf_setImageWithURL(SFURL(own.car!.image!)!)
            header.carNameLbl.text = own.car?.name
            header.authBtn.addTarget(self, action: "carAuthBtnPressed", forControlEvents: .TouchUpInside)
            if own.identified {
                header.carAuthStatusIcon.image = UIImage(named: "auth_status_authed")
            }else{
                header.carAuthStatusIcon.image = UIImage(named: "auth_status_unauthed")
            }
            return header
        }else{
            let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("text_header") as! PrivateChatSettingsHeader
            header.titleLbl.text = LS("性能参数")
            return header
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsCommonCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsCommonCell
        cell.boolSelect.hidden = true
        cell.selectionStyle = .None
        if indexPath.section == 0{
            cell.staticLbl.text = kSportsCarInfoDetailStaticLabelString1[indexPath.row]
            switch indexPath.row {
            case 0:
                cell.editable = false
                cell.infoLbl.text = own.car?.name
                break
            case 1:
                cell.editable = true
                cell.infoLbl.text = own.car?.name
                break
            case 2:
                cell.editable = true
                cell.infoLbl.text = own.signature
                break
            default:
                break
            }
        }else{
            cell.staticLbl.text = kSportsCarInfoDetailStaticLabelString2[indexPath.row]
            cell.editable = true
            switch indexPath.row {
            case 0:
                cell.infoLbl.text = own.car?.price
                break
            case 1:
                cell.infoLbl.text = own.car?.engine
                break
            case 2:
                cell.infoLbl.text = own.car?.transimission
                break
            case 3:
                cell.infoLbl.text = own.car?.max_speed
                break
            case 4:
                cell.infoLbl.text = own.car?.zeroTo60
                break
            default:
                break
            }
        }
        return cell
    }
    
    func carAuthBtnPressed() {
        if own.identified {
            // TODO: 显示toast您的爱车已经认证
            self.showToast(LS("您的爱车已认证"))
        }else {
            let detail = SportscarAuthController()
            self.navigationController?.pushViewController(detail, animated: true)
        }
    }
}

class SportCarInfoDetailHeader: UITableViewHeaderFooterView {
    
    var carImage: UIImageView!
    var carNameLbl: UILabel!
    var carAuthStatusIcon: UIImageView!
    var statementLbl: UILabel!
    
    var authBtn: UIButton!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        createSubViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubViews() {
        let superview = self.contentView
        superview.backgroundColor = UIColor.whiteColor()
        //
        carImage = UIImageView()
        superview.addSubview(carImage)
        carImage.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.top.equalTo(superview)
            make.bottom.equalTo(superview)
            make.width.equalTo(superview).multipliedBy(0.5)
        }
        //
        carNameLbl = UILabel()
        carNameLbl.textColor = UIColor.blackColor()
        carNameLbl.font = UIFont.systemFontOfSize(19, weight: UIFontWeightSemibold)
        superview.addSubview(carNameLbl)
        carNameLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(carImage.snp_right).offset(15)
            make.top.equalTo(superview).offset(16)
        }
        //
        carAuthStatusIcon = UIImageView()
        superview.addSubview(carAuthStatusIcon)
        carAuthStatusIcon.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(carNameLbl)
            make.top.equalTo(carNameLbl.snp_bottom).offset(10)
            make.size.equalTo(CGSizeMake(44, 18.5))
        }
        //
        statementLbl = UILabel()
        statementLbl.textColor = UIColor(white: 0.72, alpha: 1)
        statementLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        statementLbl.text = LS("认证可以获得什么？")
        superview.addSubview(statementLbl)
        statementLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(carNameLbl)
            make.top.equalTo(carAuthStatusIcon.snp_bottom).offset(8)
        }
        //
        let arrowIcon = UIImageView(image: UIImage(named: "account_btn_next_icon"))
        superview.addSubview(arrowIcon)
        arrowIcon.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(superview)
            make.size.equalTo(CGSizeMake(9, 15))
        }
        //
        authBtn = UIButton()
        superview.addSubview(authBtn)
        authBtn.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(carImage.snp_right)
            make.right.equalTo(superview)
            make.top.equalTo(superview)
            make.bottom.equalTo(superview)
        }
    }
    
    
}
