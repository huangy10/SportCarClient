//
//  SportscarAuth.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/1.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//
//  跑车认证
//

import UIKit
import Spring


class SportscarAuthController: PersonMineSettingsAuthController, LoadingProtocol {
    
    let kDistrictSet = ["京", "沪", "晋", "冀", "鄂", "豫", "鲁", "贵", "陕", "赣", "苏", "湘", "桂", "甘", "闽", "粤", "辽", "黑", "云", "宁", "新", "川", "渝", "蒙", "吉", "琼", "藏", "青", "甲", "乙"]
    /// 汽车所属区域选择
    var districtPickerContainer: UIView!
    var districtPicker: UIPickerView!
    var districtLabel: UILabel!
    var districtBtn: UIButton!
    /// 车牌号输入
    var carLicense: UITextField!
    var car: SportCar!
    
    override func navTitle() -> String {
        return LS("爱车认证")
    }
    
    override func navRightBtnPressed() {
        for idx in 0..<2 {
            if selectedImages[idx] == nil {
                self.showToast(LS("请完整提供要求的信息"))
                return
            }
        }
        guard let carLicenseNum = carLicense.text , carLicenseNum.length > 0 else {
            self.showToast(LS("请完整提供要求的信息"))
            return
        }
        pp_showProgressView()
        lp_start()
        let licenseNum = districtLabel.text! + carLicenseNum
        SportCarRequester.sharedInstance.authenticate(sportscar: car.ssidString, driveLicense: selectedImages[0]!, carLicense: selectedImages[1]!, licenseNum: licenseNum, onSuccess: { (json) in
            self.lp_stop()
            self.pp_hideProgressView()
            self.showToast(LS("认证申请已经成功发送"))
            _ = self.navigationController?.popViewController(animated: true)
            }, onProgress: { (progress) in
                self.pp_updateProgress(progress)
            }) { (code) in
                self.lp_stop()
                self.pp_hideProgressView()
                self.showToast(LS("认证申请发送失败"))
        }
    }
    
    override func getStaticLabelContentForIndex(_ index: Int) -> String {
        return [LS("上传驾驶证"), LS("上传行驶证"), LS("上传带牌照的人车合影")][index]
    }
    
    override func createSubviews() {
        super.createSubviews()
        // 调整中间一块的布局
        descriptionLabel.snp.remakeConstraints { (make) -> Void in
            make.left.equalTo(self.view).offset(15)
            make.right.equalTo(self.view).offset(-15)
            make.top.equalTo(privilegeBoard.snp.bottom)
            make.height.equalTo(90)
        }
        createDistrictPicker()
        
        driverLicenseOnlyForNow()
    }
    
    override func createImagesImputPanel() -> UIView {
        let container = super.createImagesImputPanel()
        let exampleImage = UIImageView(image: UIImage(named: "sports_car_auth_example"))
        container.addSubview(exampleImage)
        exampleImage.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(container)
            make.top.equalTo(staticLabel1.snp.bottom).offset(5)
            make.right.equalTo(imageBtn1.snp.left).offset(-24)
            make.bottom.equalTo(imageBtn1)
        }
        exampleImage.contentMode = .scaleAspectFit
        return container
    }
    
    override func createDescriptionLabel() -> UIView {
        let container = UIView()
        let districtStaticLbl = UILabel()
        districtStaticLbl.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
        districtStaticLbl.textColor = kTextGray54
        districtStaticLbl.text = LS("车牌地区")
        container.addSubview(districtStaticLbl)
        districtStaticLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(container)
            make.top.equalTo(container)
        }
        let arrow = UIImageView(image: UIImage(named: "account_profile_down_arrow"))
        container.addSubview(arrow)
        arrow.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(container)
            make.centerY.equalTo(districtStaticLbl)
            make.size.equalTo(CGSize(width: 15, height: 9))
        }
        districtLabel = UILabel()
        districtLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
        districtLabel.textColor = UIColor.black
        districtLabel.textAlignment = .right
        districtLabel.text = "京"
        container.addSubview(districtLabel)
        districtLabel.snp.makeConstraints { (make) -> Void in
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
        //
        districtBtn = UIButton()
        container.addSubview(districtBtn)
        districtBtn.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(container)
            make.top.equalTo(container)
            make.right.equalTo(container)
            make.bottom.equalTo(sepLine1)
        }
        districtBtn.addTarget(self, action: #selector(SportscarAuthController.showDistrictPicker), for: .touchUpInside)
        //
        let licenseStaticLbl = UILabel()
        licenseStaticLbl.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
        licenseStaticLbl.textColor = kTextGray54
        licenseStaticLbl.text = LS("车牌号")
        container.addSubview(licenseStaticLbl)
        licenseStaticLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(sepLine1)
            make.top.equalTo(sepLine1).offset(22)
        }
//        let arrow2 = UIImageView(image: UIImage(named: "account_btn_next_icon"))
//        container.addSubview(arrow2)
//        arrow2.snp.makeConstraints { (make) -> Void in
//            make.right.equalTo(arrow)
//            make.centerY.equalTo(licenseStaticLbl)
//            make.size.equalTo(CGSize(width: 9, height: 15))
//        }
//        arrow2.isHidden = true
        carLicense = UITextField()
        carLicense.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
        carLicense.placeholder = LS("请填写车牌号")
        carLicense.textColor = UIColor.black
        carLicense.textAlignment = .right
        carLicense.delegate = self
        inputFields.append(carLicense)
        container.addSubview(carLicense)
        carLicense.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(arrow)
            make.centerY.equalTo(licenseStaticLbl)
            make.height.equalTo(licenseStaticLbl)
            make.width.equalTo(100)
        }
        let sepLine2 = UIView()
        sepLine2.backgroundColor = UIColor(white: 0.945, alpha: 1)
        container.addSubview(sepLine2)
        sepLine2.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(sepLine1)
            make.right.equalTo(sepLine1)
            make.top.equalTo(licenseStaticLbl.snp.bottom).offset(11)
            make.height.equalTo(0.5)
        }
        return container
    }
    
    func createDistrictPicker() {
        let superview = self.view!
        districtPickerContainer = UIView()
        districtPickerContainer.backgroundColor = UIColor(white: 0.945, alpha: 1)
        superview.addSubview(districtPickerContainer)
        districtPickerContainer.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(superview.snp.bottom)
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.height.equalTo(234)
        }
        //
        let pickerHeader = UIView()
        pickerHeader.backgroundColor = UIColor(white: 0.92, alpha: 1)
        districtPickerContainer.addSubview(pickerHeader)
        pickerHeader.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(districtPickerContainer)
            make.right.equalTo(districtPickerContainer)
            make.left.equalTo(districtPickerContainer)
            make.height.equalTo(35)
        }
        //
        let pickerTitle = UILabel()
        pickerTitle.text = LS("选择车牌地区")
        pickerTitle.font = UIFont.systemFont(ofSize: 14)
        pickerHeader.addSubview(pickerTitle)
        pickerTitle.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(pickerHeader).offset(20)
            make.centerY.equalTo(pickerHeader)
        }
        //
        let doneBtn = UIButton()
        doneBtn.setTitle(LS("完成"), for: .normal)
        doneBtn.setTitleColor(kHighlightedRedTextColor, for: .normal)
        doneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
        pickerHeader.addSubview(doneBtn)
        doneBtn.addTarget(self, action: #selector(SportscarAuthController.donePickDistrictBtnPressed), for: .touchUpInside)
        doneBtn.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(pickerHeader).offset(-20)
            make.centerY.equalTo(pickerHeader)
            make.height.equalTo(pickerHeader)
            make.width.equalTo(30)
        }
        //
        districtPicker = UIPickerView()
        districtPicker.delegate = self
        districtPicker.dataSource = self
        districtPickerContainer.addSubview(districtPicker)
        districtPicker.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(districtPickerContainer)
            make.top.equalTo(pickerHeader.snp.bottom)
            make.left.equalTo(districtPickerContainer)
            make.bottom.equalTo(districtPickerContainer)
        }
    }
    
    func donePickDistrictBtnPressed() {
        let index = districtPicker.selectedRow(inComponent: 0)
        districtLabel.text = kDistrictSet[index]
        hideDistrictPicker()
    }
    
    func showDistrictPicker() {
        districtBtn.isEnabled = false
        tapper?.isEnabled = true
        districtPickerContainer.snp.remakeConstraints { (make) -> Void in
            make.right.equalTo(self.view)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.height.equalTo(234)
        }
        SpringAnimation.spring(duration: 0.3) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    func hideDistrictPicker() {
        districtBtn.isEnabled = true
        tapper?.isEnabled = false
        districtPickerContainer.snp.remakeConstraints { (make) -> Void in
            make.right.equalTo(self.view)
            make.left.equalTo(self.view)
            make.top.equalTo(self.view.snp.bottom)
            make.height.equalTo(234)
        }
        SpringAnimation.spring(duration: 0.3) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    override func dismissKeyboard() {
        super.dismissKeyboard()
        hideDistrictPicker()
    }
    
    func driverLicenseOnlyForNow() {
//        imageBtn2.isHidden = true
        imageBtn3.isHidden = true
//        staticLabel2.isHidden = true
        staticLabel3.isHidden = true
        
    }
}

// MARK: - privide data for district picker
extension SportscarAuthController: UIPickerViewDataSource, UIPickerViewDelegate  {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return kDistrictSet.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        titleLabel.textAlignment = .center
        titleLabel.text = kDistrictSet[row]
        titleLabel.textColor = UIColor.black
        return titleLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
}

