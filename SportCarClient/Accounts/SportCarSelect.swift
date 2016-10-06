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
import Alamofire

class SportCarSelectController: InputableViewController, SportCarBrandOnlineSelectorDelegate {
    
    var sportCarDisplay: UIImageView?
    var brandSelectBtn: UIButton?
    var signatureInput: UITextField?
    
    var reqOnfly: Request?
    
    // MARK: Navigation设置
    func navigationBarSettings() {
        self.navigationItem.title = NSLocalizedString("补充信息", comment: "")
        self.navigationItem.leftBarButtonItem = navBarLeftBtn()
        self.navigationItem.rightBarButtonItem = navBarRigthBtn()
    }
    
    func navBarLeftBtn() -> UIBarButtonItem! {
        let backBtn = UIButton()
        backBtn.setBackgroundImage(UIImage(named: "account_header_back_btn"), for: .normal)
        backBtn.addTarget(self, action: #selector(SportCarSelectController.backBtnPressed), for: .touchUpInside)
        backBtn.frame = CGRect(x: 0, y: 0, width: 10.2, height: 18)
        
        let leftBtnItem = UIBarButtonItem(customView: backBtn)
        return leftBtnItem
    }
    
    func navBarRigthBtn() -> UIBarButtonItem! {
        let nextStepBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 42, height: 16))
        nextStepBtn.setTitle(NSLocalizedString("下一步", comment: ""), for: .normal)
        nextStepBtn.setTitleColor(kHighlightedRedTextColor, for: .normal)
        nextStepBtn.titleLabel?.font = kBarTextFont
        nextStepBtn.addTarget(self, action: #selector(SportCarSelectController.nextBtnPressed), for: .touchUpInside)
        let rightBtnItem = UIBarButtonItem(customView: nextStepBtn)
        return rightBtnItem
    }
    
    func backBtnPressed() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func nextBtnPressed() {
        
    }
    
    // 
    override func createSubviews() {
        super.createSubviews()
        navigationBarSettings()
        let superview = self.view!
        superview.backgroundColor = UIColor.white
        //
        sportCarDisplay = UIImageView(image: UIImage(named: "account_car_select_placeholder"))
        superview.addSubview(sportCarDisplay!)
        sportCarDisplay?.snp.makeConstraints({ (make) -> Void in
            make.width.equalTo(superview).multipliedBy(0.5)
            make.left.equalTo(superview)
            make.top.equalTo(superview)
            make.height.equalTo(sportCarDisplay!.snp.width).multipliedBy(0.58)
        })
        //
        let selectBtn = UIButton()
        selectBtn.setTitle(NSLocalizedString("请选择品牌型号", comment: ""), for: .normal)
        selectBtn.setTitleColor(UIColor(white: 0.72, alpha: 1), for: .normal)
        selectBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
        selectBtn.titleLabel?.textAlignment = .center
        superview.addSubview(selectBtn)
        selectBtn.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(sportCarDisplay!.snp.right)
            make.right.equalTo(superview)
            make.centerY.equalTo(sportCarDisplay!)
            make.height.equalTo(44)
        }
        selectBtn.addTarget(self, action: #selector(SportCarSelectController.selectSportCarBrandPressed), for: .touchUpInside)
        brandSelectBtn = selectBtn
        //
        let btnIcon = UIImageView(image: UIImage(named: "account_btn_next_icon"))
        selectBtn.addSubview(btnIcon)
        btnIcon.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(selectBtn).offset(-15)
            make.centerY.equalTo(selectBtn)
            make.size.equalTo(CGSize(width: 9, height: 15))
        }
        //
        let signatureLbl = UILabel()
        signatureLbl.text = NSLocalizedString("跑车签名", comment: "")
        signatureLbl.textColor = UIColor(white: 0.72, alpha: 1)
        signatureLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight)
        signatureLbl.textAlignment = .left
        superview.addSubview(signatureLbl)
        signatureLbl.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(sportCarDisplay!.snp.bottom).offset(22)
            make.height.equalTo(34)
            make.width.equalTo(134)
            make.left.equalTo(superview).offset(15)
        }
        
        signatureInput = UITextField()
        signatureInput?.delegate = self
        signatureInput?.placeholder = NSLocalizedString("为爱车写一段签名吧(选填)", comment: "")
        signatureInput?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
        self.inputFields.append(signatureInput)
        superview.addSubview(signatureInput!)
        signatureInput?.snp.makeConstraints({ (make) -> Void in
            make.centerY.equalTo(signatureLbl)
            make.left.equalTo(signatureLbl.snp.right)
            make.right.equalTo(superview).offset(-15)
            make.height.equalTo(signatureLbl)
        })
        
        let signatureIcon = UIImageView(image: UIImage(named: "account_btn_next_icon"))
        signatureInput?.addSubview(signatureIcon)
        signatureIcon.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(signatureInput!)
            make.centerY.equalTo(signatureInput!)
            make.size.equalTo(CGSize(width: 9, height: 15))
        }
        
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.92, alpha: 1)
        superview.addSubview(sepLine)
        sepLine.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(signatureLbl)
            make.right.equalTo(signatureInput!)
            make.height.equalTo(1)
            make.top.equalTo(signatureLbl.snp.bottom).offset(11)
        }
        
        let plzSelectLbl = UILabel()
        plzSelectLbl.text = NSLocalizedString("请选择一辆您拥有或者关注的跑车", comment: "")
        plzSelectLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight)
        plzSelectLbl.textAlignment = .center
        plzSelectLbl.textColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(plzSelectLbl)
        plzSelectLbl.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.centerY.equalTo(superview)
            make.width.equalTo(superview)
            make.height.equalTo(24)
        }
    }
    
    func selectSportCarBrandPressed() {
        if let req = reqOnfly {
            req.cancel()
        }
        let select = ManufacturerOnlineSelectorController()
        select.delegate = self
        let nav = BlackBarNavigationController(rootViewController: select)
        self.present(nav, animated: true, completion: nil)
    }
    
    // MARK: 弹出的跑车选择列表的代理
    func brandSelected(_ manufacturer: String?, carType: String?) {
        self.dismiss(animated: true, completion: nil)
        if manufacturer == nil || carType == nil {
            return
        }
        brandSelectBtn?.setTitle(LS("获取跑车资料中..."), for: .normal)
        brandSelectBtn?.isEnabled = false
//        reqOnfly = SportCarRequester.sharedInstance.querySportCarWith(manufacturer!, carName: carType!, onSuccess: { (data) -> () in
//            guard let data = data else {
//                return
//            }
//            let carImgURL = SF(data["image_url"].stringValue)
//            let headers = [LS("具体型号"), LS("跑车签名"), LS("价格"), LS("发动机"), LS("扭矩"), LS("车身结构"), LS("最高时速"), LS("百公里加速")]
//            let contents = [carType, self.signatureInput?.text, data["price"].string, data["engine"].string, data["transmission"].string, data["body"].string, data["max_speed"].string, data["zeroTo60"].string]
//            let detail = SportCarSelectDetailController()
//            detail.headers = headers
//            detail.carId = data["carID"].stringValue
//            detail.contents = contents
//            detail.carType = carType
//            detail.carDisplayURL = NSURL(string: carImgURL ?? "")
//            
//            self.navigationController?.pushViewController(detail, animated: true)
//            self.brandSelectBtn?.enabled = true
//            }) { (code) -> () in
//                // 弹窗说明错误
//                let alert = UIAlertController(title: LS("载入跑车数据失败"), message: nil, preferredStyle: .Alert)
//                alert.addAction(UIAlertAction(title: LS("取消"), style: .Cancel, handler: { (action) -> Void in
//                    self.brandSelectBtn?.setTitle(LS("重选跑车"), forState: .Normal)
//                }))
//                self.brandSelectBtn?.enabled = true
//        }
    }
    
    func sportCarBrandOnlineSelectorDidCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func sportCarBrandOnlineSelectorDidSelect(_ manufacture: String, carName: String, subName: String) {
        dismiss(animated: true, completion: nil)
        brandSelectBtn?.setTitle(LS("获取跑车资料中"), for: .normal)
        brandSelectBtn?.isEnabled = false
        
        reqOnfly = SportCarRequester.sharedInstance.querySportCarWith(manufacture, carName: carName, subName: subName, onSuccess: { (json) in
            guard let data = json else {
                return
            }
            self.brandSelectBtn?.setTitle(LS("请选择品牌型号"), for: .normal)
            self.brandSelectBtn?.isEnabled = true
            
            let carImgURL = SF(data["image_url"].stringValue)
            let headers = [LS("具体型号"), LS("跑车签名"), LS("价格"), LS("发动机"), LS("扭矩"), LS("车身结构"), LS("最高时速"), LS("百公里加速")]
            let contents = [carName, self.signatureInput?.text, data["price"].string, data["engine"].string, data["transmission"].string, data["body"].string, data["max_speed"].string, data["zeroTo60"].string]
            let detail = SportCarSelectDetailController()
            detail.headers = headers
            detail.carId = data["carID"].stringValue
            detail.contents = contents
            detail.carType = carName
            detail.carDisplayURL = URL(string: carImgURL ?? "")
            
            self.navigationController?.pushViewController(detail, animated: true)
            self.brandSelectBtn?.isEnabled = true
            }, onError: { (code) in
                self.brandSelectBtn?.setTitle(LS("请选择品牌型号"), for: .normal)
                self.brandSelectBtn?.isEnabled = true
                
                let alert = UIAlertController(title: LS("载入跑车数据失败"), message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: LS("取消"), style: .cancel, handler: { (action) -> Void in
                    self.brandSelectBtn?.setTitle(LS("重选跑车"), for: .normal)
                }))
                self.brandSelectBtn?.isEnabled = true
        })
    }
}


