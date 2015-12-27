//
//  SportCarPicker.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/13.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

class SportCarSelectController: InputableViewController, SportCarBrandSelecterControllerDelegate {
    
    var sportCarDisplay: UIImageView?
    var brandSelectBtn: UIButton?
    var signatureInput: UITextField?
    
    // MARK: Navigation设置
    func navigationBarSettings() {
        self.navigationItem.title = NSLocalizedString("补充信息", comment: "")
        self.navigationItem.leftBarButtonItem = navBarLeftBtn()
        self.navigationItem.rightBarButtonItem = navBarRigthBtn()
    }
    
    func navBarLeftBtn() -> UIBarButtonItem! {
        let backBtn = UIButton()
        backBtn.setBackgroundImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        backBtn.addTarget(self, action: "backBtnPressed", forControlEvents: .TouchUpInside)
        backBtn.frame = CGRect(x: 0, y: 0, width: 10.2, height: 18)
        
        let leftBtnItem = UIBarButtonItem(customView: backBtn)
        return leftBtnItem
    }
    
    func navBarRigthBtn() -> UIBarButtonItem! {
        let nextStepBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 42, height: 16))
        nextStepBtn.setTitle(NSLocalizedString("下一步", comment: ""), forState: .Normal)
        nextStepBtn.setTitleColor(kHighlightedRedTextColor, forState: .Normal)
        nextStepBtn.titleLabel?.font = kBarTextFont
        nextStepBtn.addTarget(self, action: "nextBtnPressed", forControlEvents: .TouchUpInside)
        let rightBtnItem = UIBarButtonItem(customView: nextStepBtn)
        return rightBtnItem
    }
    
    func backBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func nextBtnPressed() {
        
    }
    
    // 
    override func createSubviews() {
        super.createSubviews()
        navigationBarSettings()
        let superview = self.view
        superview.backgroundColor = UIColor.whiteColor()
        //
        sportCarDisplay = UIImageView(image: UIImage(named: "account_car_select_placeholder"))
        superview.addSubview(sportCarDisplay!)
        sportCarDisplay?.snp_makeConstraints(closure: { (make) -> Void in
            make.width.equalTo(superview).multipliedBy(0.5)
            make.left.equalTo(superview)
            make.top.equalTo(superview)
            make.height.equalTo(sportCarDisplay!.snp_width).multipliedBy(0.58)
        })
        //
        let selectBtn = UIButton()
        selectBtn.setTitle(NSLocalizedString("请选择品牌型号", comment: ""), forState: .Normal)
        selectBtn.setTitleColor(UIColor(white: 0.72, alpha: 1), forState: .Normal)
        selectBtn.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        selectBtn.titleLabel?.textAlignment = .Center
        superview.addSubview(selectBtn)
        selectBtn.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(sportCarDisplay!.snp_right)
            make.right.equalTo(superview)
            make.centerY.equalTo(sportCarDisplay!)
            make.height.equalTo(44)
        }
        selectBtn.addTarget(self, action: "selectSportCarBrandPressed", forControlEvents: .TouchUpInside)
        brandSelectBtn = selectBtn
        //
        let btnIcon = UIImageView(image: UIImage(named: "account_btn_next_icon"))
        selectBtn.addSubview(btnIcon)
        btnIcon.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(selectBtn).offset(-15)
            make.centerY.equalTo(selectBtn)
            make.size.equalTo(CGSize(width: 9, height: 15))
        }
        //
        let signatureLbl = UILabel()
        signatureLbl.text = NSLocalizedString("跑车签名", comment: "")
        signatureLbl.textColor = UIColor(white: 0.72, alpha: 1)
        signatureLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightLight)
        signatureLbl.textAlignment = .Left
        superview.addSubview(signatureLbl)
        signatureLbl.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(sportCarDisplay!.snp_bottom).offset(22)
            make.height.equalTo(34)
            make.width.equalTo(134)
            make.left.equalTo(superview).offset(15)
        }
        
        signatureInput = UITextField()
        signatureInput?.delegate = self
        signatureInput?.placeholder = NSLocalizedString("为爱车写一段签名吧(选填)", comment: "")
        signatureInput?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        self.inputFields.append(signatureInput)
        superview.addSubview(signatureInput!)
        signatureInput?.snp_makeConstraints(closure: { (make) -> Void in
            make.centerY.equalTo(signatureLbl)
            make.left.equalTo(signatureLbl.snp_right)
            make.right.equalTo(superview).offset(-15)
            make.height.equalTo(signatureLbl)
        })
        
        let signatureIcon = UIImageView(image: UIImage(named: "account_btn_next_icon"))
        signatureInput?.addSubview(signatureIcon)
        signatureIcon.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(signatureInput!)
            make.centerY.equalTo(signatureInput!)
            make.size.equalTo(CGSize(width: 9, height: 15))
        }
        
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.92, alpha: 1)
        superview.addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(signatureLbl)
            make.right.equalTo(signatureInput!)
            make.height.equalTo(1)
            make.top.equalTo(signatureLbl.snp_bottom).offset(11)
        }
        
        let plzSelectLbl = UILabel()
        plzSelectLbl.text = NSLocalizedString("请选择一辆您拥有或者关注的跑车", comment: "")
        plzSelectLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightLight)
        plzSelectLbl.textAlignment = .Center
        plzSelectLbl.textColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(plzSelectLbl)
        plzSelectLbl.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.centerY.equalTo(superview)
            make.width.equalTo(superview)
            make.height.equalTo(24)
        }
    }
    
    func selectSportCarBrandPressed() {
        let select = SportCarBrandSelecterController()
        select.delegate = self
        let nav = BlackBarNavigationController(rootViewController: select)
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    // MARK: 弹出的跑车选择列表的代理
    func brandSelected(manufacturer: String?, carType: String?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        if manufacturer == nil || carType == nil {
            return
        }
        brandSelectBtn?.setTitle(LS("获取跑车资料中..."), forState: .Normal)
        brandSelectBtn?.enabled = false
        let requester = SportCarRequester.sharedSCRequester
        requester.querySportCarWith(manufacturer!, carName: carType!, onSuccess: { (data) -> () in
            let carImgURL = SF(data["image_url"].stringValue)
            let headers = [LS("具体型号"), LS("跑车签名"), LS("价格"), LS("发动机"), LS("变速箱"), LS("车身结构"), LS("最高时速"), LS("百公里加速")]
            let contents = [carType, self.signatureInput?.text, data["price"].string, data["engine"].string, data["transmission"].string, data["body"].string, data["max_speed"].string, data["zeroTo60"].string]
            let detail = SportCarSelectDetailController()
            print("\(data)")
            detail.headers = headers
            detail.carId = data["car_id"].stringValue
            detail.contents = contents
            detail.carType = carType
            detail.carDisplayURL = NSURL(string: carImgURL ?? "")
            
            self.navigationController?.pushViewController(detail, animated: true)
            self.brandSelectBtn?.enabled = true
            }) { (code) -> () in
                // 弹窗说明错误
                let alert = UIAlertController(title: LS("载入跑车数据失败"), message: nil, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: LS("取消"), style: .Cancel, handler: { (action) -> Void in
                    self.brandSelectBtn?.setTitle(LS("重选跑车"), forState: .Normal)
                }))
                self.brandSelectBtn?.enabled = true
        }
    }
}


