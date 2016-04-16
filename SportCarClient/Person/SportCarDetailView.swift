//
//  SportCarDetailView.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/13.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

let kSportsCarInfoDetailStaticLabelString1 = [LS("品牌型号"), LS("跑车签名")]
let kSportsCarInfoDetailStaticLabelString2 = [LS("价格"), LS("发动机"), LS("变速箱"), LS("最高车速"), LS("百公里加速")]


class SportCarInfoDetailController: UITableViewController, UITextFieldDelegate, SinglePropertyModifierDelegate {
    
    var car: SportCar!
    
    weak var toast: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()

        SportCarAuthHeader.registerTableView(tableView)
        SSCommonHeader.registerTableView(tableView)
        SSPropertyCell.registerTableView(tableView)
        SSPropertyInputableCell.registerTableView(tableView)
        
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
        navLeftBtn.addTarget(self, action: #selector(SportCarInfoDetailController.navLeftBtnPressed), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        //
        let rightItem = UIBarButtonItem(title: LS("删除"), style: .Done, target: self, action: #selector(SportCarInfoDetailController.navRightBtnPressed))
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func navLeftBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func navRightBtnPressed() {
        // TODO: 删除该跑车
        toast = showConfirmToast(
            LS("删除"), message: LS("确认删除爱车?"),
            target: self,
            confirmSelector: #selector(confirmDelete),
            cancelSelector: #selector(hideConfirmToast as ()->()),
            onSelf: false
        )
//        self.navigationController?.popViewControllerAnimated(true)
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
        return 50
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = tableView.ss_reusableHeader(SportCarAuthHeader)
            header.titleLbl.text = LS("爱车型号")
            header.authed = car.identified
            header.authBtn.addTarget(self, action: #selector(SportCarInfoDetailController.carAuthBtnPressed), forControlEvents: .TouchUpInside)
            return header
        }else{
            let header = tableView.ss_reusableHeader(SSCommonHeader.self)
            header.titleLbl.text = LS("性能参数")
            return header
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 2 {
            let cell = tableView.ss_reuseablePropertyCell(SSPropertyInputableCell.self, forIndexPath: indexPath)
            cell.staticLbl.text = LS("爱车签名")
            cell.extraSettings(self, text: car.signature, placeholder: LS("请输入爱车签名"))
            cell.inputable = false
            return cell
        }
        let cell = tableView.ss_reuseablePropertyCell(SSPropertyCell.self, forIndexPath: indexPath)
        cell.editable = false
        if indexPath.section == 0 {
            cell.staticLbl.text = kSportsCarInfoDetailStaticLabelString1[indexPath.row]
            switch indexPath.row {
            case 0:
                cell.infoLbl.text = car.name
            case 1:
                cell.infoLbl.text = car.signature
            default:
                assertionFailure()
            }
        } else {
            cell.staticLbl.text = kSportsCarInfoDetailStaticLabelString2[indexPath.row]
            switch  indexPath.row {
            case 0:
                cell.infoLbl.text = car.price
                break
            case 1:
                cell.infoLbl.text = car.engine
                break
            case 2:
                cell.infoLbl.text = car.torque
                break
            case 3:
                cell.infoLbl.text = car.maxSpeed
                break
            case 4:
                cell.infoLbl.text = car.zeroTo60
                break
            default:
                break
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 1 && indexPath.section == 0 {
            SinglePropertyModifierController(propertyName: LS("爱车签名"), delegate: self, forcusedIndexPath: indexPath).pushFromViewController(self)
        }
    }
    
    func carAuthBtnPressed() {
        if car.identified {
            self.showToast(LS("您的爱车已认证"))
        }else {
            let detail = SportscarAuthController()
            detail.car = car
            self.navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    func confirmDelete() {
        hideConfirmToast()
        // TODO: send request to the server
    }
    /**
     hide the confirm toast
     */
    func hideConfirmToast() {
        if let t = toast {
            hideConfirmToast(t)
        }
    }
    
    func singlePropertyModifierDidCancelled() {
        // 
    }
    
    func singlePropertyModifierDidModify(newValue: String?, forIndexPath indexPath: NSIndexPath) {
        // TODO: update single property to server
        car.signature = newValue
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
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
        carImage.contentMode = .ScaleAspectFill
        carImage.clipsToBounds = true
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
