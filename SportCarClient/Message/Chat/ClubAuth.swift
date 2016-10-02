//
//  ClubAuth.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/4.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class ClubAuthController: AuthBasicController, CityElementSelectDelegate, ProgressProtocol, PersonMineSinglePropertyModifierDelegate {
    
    var club: Club!
    
    var districtLbl: UILabel!
    var descriptionLbl: UILabel!
    // for ProgressProtocol
    var pp_progressView: UIProgressView?
    
    override func navTitle() -> String {
        return LS("俱乐部认证")
    }
    
    override func navRightBtnPressed() {
        // send request to server
        guard let district = districtLbl.text , district != "" else {
            showToast(LS("请选择活跃地区"))
            return
        }
        guard let desc = descriptionLbl.text , desc != "" else {
            showToast(LS("请填写俱乐部简介"))
            return
        }
        self.pp_showProgressView()
        _ = ClubRequester.sharedInstance.clubAuth(
            club.ssidString,
            district: district,
            description: desc,
            onSuccess: { (json) -> () in
                self.pp_hideProgressView()
                self.showToast(LS("俱乐部认证申请已成功发送"))
            }, onProgress: { (progress) -> () in
                self.pp_updateProgress(progress)
            }) { (code) -> () in
                self.showToast(LS("俱乐部认证申请发送失败"))
                self.pp_hideProgressView()
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func titleForRightNavBtn() -> String {
        return LS("认证")
    }
    
    override func getHeightForPrivilegeBoard() -> CGFloat {
        return 103
    }
    
    override func getHeightForDescriptionLable() -> CGFloat {
        return 90
    }
    
    override func getHeightForImageInputPanel() -> CGFloat {
        return 150
    }
    
    override func createPrivilegeBoard() -> UIView {
        let container = UIView()
        let image1 = UIImageView(image: UIImage(named: "privilege_show_avatar_logo"))
        container.addSubview(image1)
        image1.contentMode = .scaleAspectFit
        image1.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(container.snp.centerX).offset(-40)
            make.size.equalTo(37)
            make.top.equalTo(container).offset(22)
        }
        let static1 = ss_createLabel(
            UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight),
            textColor: UIColor.black,
            textAlignment: .center,
            text: LS("头像旁俱乐部LOGO")
        )
        container.addSubview(static1)
        static1.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(image1)
            make.top.equalTo(image1.snp.bottom).offset(11)
        }
        let image2 = UIImageView(image: UIImage(named: "privilege_allow_start_activity"))
        image2.contentMode = .scaleAspectFit
        container.addSubview(image2)
        image2.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(container.snp.centerX).offset(40)
            make.size.equalTo(37)
            make.top.equalTo(container).offset(22)
        }
        let static2 = ss_createLabel(
            UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight),
            textColor: UIColor.black,
            textAlignment: .center,
            text: LS("可以发布活动")
        )
        container.addSubview(static2)
        static2.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(image2)
            make.top.equalTo(image2.snp.bottom).offset(11)
        }
        return container
    }
    
    override func createDescriptionLabel() -> UIView {
        let container = UIView()
        let districtStaticLbl = ss_createLabel(
            UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight),
            textColor: UIColor(white: 0.72, alpha: 1),
            textAlignment: .left,
            text: LS("活跃地区")
        )
        container.addSubview(districtStaticLbl)
        districtStaticLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(container)
            make.top.equalTo(container)
        }
        let arrow = UIImageView(image: UIImage(named: "account_btn_next_icon"))
        container.addSubview(arrow)
        arrow.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(container)
            make.centerY.equalTo(districtStaticLbl)
            make.size.equalTo(CGSize(width: 9, height: 15))
        }
        districtLbl = ss_createLabel(
            UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight),
            textColor: UIColor.black,
            textAlignment: .right,
            text: LS("北京市")
        )
        container.addSubview(districtLbl)
        districtLbl.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(arrow.snp.left).offset(-11)
            make.centerY.equalTo(districtStaticLbl)
        }
        let sepLine1 = UIView()
        sepLine1.backgroundColor = UIColor(white: 0.945, alpha: 1)
        container.addSubview(sepLine1)
        sepLine1.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(districtStaticLbl)
            make.right.equalTo(arrow)
            make.top.equalTo(districtStaticLbl.snp.bottom).offset(11)
            make.height.equalTo(1)
        }
        let districtSelectBtn = UIButton()
        container.addSubview(districtSelectBtn)
        districtSelectBtn.addTarget(self, action: #selector(ClubAuthController.districtSelectBtnPressed), for: .touchUpInside)
        districtSelectBtn.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(container)
            make.top.equalTo(container)
            make.right.equalTo(container)
            make.bottom.equalTo(sepLine1)
        }
        let desStaticLbl = ss_createLabel(
            UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight),
            textColor: UIColor(white: 0.72, alpha: 1),
            textAlignment: .right,
            text: LS("本群简介"))
        container.addSubview(desStaticLbl)
        desStaticLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(sepLine1)
            make.top.equalTo(sepLine1).offset(22)
        }
        let arrow2 = UIImageView(image: UIImage(named: "account_btn_next_icon"))
        container.addSubview(arrow2)
        arrow2.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(arrow)
            make.centerY.equalTo(desStaticLbl)
            make.size.equalTo(CGSize(width: 9, height: 15))
        }
        descriptionLbl = ss_createLabel(
            UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight),
            textColor: UIColor.black,
            textAlignment: .right,
            text: LS("待补充")
        )
        container.addSubview(descriptionLbl)
        descriptionLbl.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(districtLbl)
            make.centerY.equalTo(desStaticLbl)
            make.left.equalTo(desStaticLbl.snp.right).offset(30)
        }
        let sepLine2 = UIView()
        sepLine2.backgroundColor = UIColor(white: 0.945, alpha: 1)
        container.addSubview(sepLine2)
        sepLine2.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(sepLine1)
            make.right.equalTo(sepLine1)
            make.top.equalTo(desStaticLbl.snp.bottom).offset(11)
            make.height.equalTo(0.5)
        }
        let desEditBtn = UIButton()
        desEditBtn.addTarget(self, action: #selector(ClubAuthController.desEditBtnPressed), for: .touchUpInside)
        container.addSubview(desEditBtn)
        desEditBtn.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(desStaticLbl)
            make.right.equalTo(arrow2)
            make.top.equalTo(sepLine1.snp.bottom)
            make.bottom.equalTo(sepLine2)
        }
        return container
    }
    
    override func createImagesImputPanel() -> UIView {
        let container = UIView()
        let label = ss_createLabel(
            UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight),
            textColor: UIColor(white: 0.72, alpha: 1),
            textAlignment: .left,
            text: "1. 头像应为企业商标/标识或品牌Logo\n2.昵称应为俱乐部的全称或无歧义简称\n3.昵称不能仅包含一个通用性描述词语，不可过度修饰\n4.俱乐部人数满100人，认证用户50人以上\n5.有完整的俱乐部简介")
        label.numberOfLines = 0
        container.addSubview(label)
        label.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(container)
            make.right.equalTo(container)
            make.top.equalTo(container)
        }
        return container
    }
    
    func districtSelectBtnPressed() {
        let citySelect = CityElementSelectController()
        citySelect.maxLevel = 1
        citySelect.delegate = self
        self.navigationController?.pushViewController(citySelect, animated: true)
    }
    
    func desEditBtnPressed() {
        let modifier = PersonMineSinglePropertyModifierController()
        modifier.focusedIndexPath = IndexPath()
        modifier.propertyName = LS("俱乐部简介")
        modifier.delegate = self
        self.navigationController?.pushViewController(modifier, animated: true)
    }
    
    func cityElementSelectDidSelect(_ dataSource: CityElementSelectDataSource) {
        _ = self.navigationController?.popToViewController(self, animated: true)
        districtLbl.text = dataSource.selectedCity
    }
    
    func cityElementSelectDidCancel() {
        _ = self.navigationController?.popToViewController(self, animated: true)
    }
    
    func didModify(_ newValue: String?, indexPath: IndexPath) {
        descriptionLbl.text = newValue
    }
    
    func modificationCancelled() {
        
    }
}
