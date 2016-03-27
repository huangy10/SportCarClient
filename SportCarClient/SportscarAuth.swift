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


class SportscarAuthController: PersonMineSettingsAuthController, UIPickerViewDataSource, UIPickerViewDelegate {
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
        return LS("跑车认证")
    }
    
    override func navRightBtnPressed() {
        for im in self.selectedImages {
            if im == nil {
                self.showToast(LS("请完整提供要求的信息"))
                return
            }
        }
        guard let carLicenseNum = carLicense.text where carLicenseNum.length > 0 else {
            self.showToast(LS("请完整提供要求的信息"))
            return
        }
        let requester = SportCarRequester.sharedSCRequester
        pp_showProgressView()
        requester.authenticateSportscar(car.ssidString, driveLicense: selectedImages[0]!, photo: selectedImages[2]!, idCard: selectedImages[1]!, licenseNum: districtLabel.text! + carLicenseNum, onSuccess: { (json) -> () in
            self.pp_hideProgressView()
            self.showToast(LS("认证申请已经成功发送"))
            }, onProgress: { (progress) -> () in
                self.pp_updateProgress(progress)
            }) { (code) -> () in
                self.pp_hideProgressView()
                self.showToast(LS("认证申请发送失败"))
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func getStaticLabelContentForIndex(index: Int) -> String {
        return [LS("上传驾驶证"), LS("上传身份证"), LS("上传带牌照的人车合影")][index]
    }
    
    override func createSubviews() {
        super.createSubviews()
        // 调整中间一块的布局
        descriptionLabel.snp_remakeConstraints { (make) -> Void in
            make.left.equalTo(self.view).offset(15)
            make.right.equalTo(self.view).offset(-15)
            make.top.equalTo(privilegeBoard.snp_bottom)
            make.height.equalTo(90)
        }
        createDistrictPicker()
    }
    
    override func createImagesImputPanel() -> UIView {
        let container = super.createImagesImputPanel()
        let exampleImage = UIImageView(image: UIImage(named: "sports_car_auth_example"))
        container.addSubview(exampleImage)
        exampleImage.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(container)
            make.top.equalTo(staticLabel1.snp_bottom).offset(5)
            make.right.equalTo(imageBtn1.snp_left).offset(-24)
            make.height.equalTo(exampleImage.snp_width).multipliedBy(0.67)
        }
        return container
    }
    
    override func createDescriptionLabel() -> UIView {
        let container = UIView()
        let districtStaticLbl = UILabel()
        districtStaticLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        districtStaticLbl.textColor = UIColor(white: 0.72, alpha: 1)
        districtStaticLbl.text = LS("车牌地区")
        container.addSubview(districtStaticLbl)
        districtStaticLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(container)
            make.top.equalTo(container)
        }
        let arrow = UIImageView(image: UIImage(named: "account_profile_down_arrow"))
        container.addSubview(arrow)
        arrow.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(container)
            make.centerY.equalTo(districtStaticLbl)
            make.size.equalTo(CGSizeMake(15, 9))
        }
        districtLabel = UILabel()
        districtLabel.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        districtLabel.textColor = UIColor.blackColor()
        districtLabel.textAlignment = .Right
        districtLabel.text = "京"
        container.addSubview(districtLabel)
        districtLabel.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(arrow.snp_left).offset(-11)
            make.centerY.equalTo(districtStaticLbl)
        }
        let sepLine1 = UIView()
        sepLine1.backgroundColor = UIColor(white: 0.945, alpha: 1)
        container.addSubview(sepLine1)
        sepLine1.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(districtStaticLbl)
            make.right.equalTo(arrow)
            make.top.equalTo(districtStaticLbl.snp_bottom).offset(11)
            make.height.equalTo(1)
        }
        //
        districtBtn = UIButton()
        container.addSubview(districtBtn)
        districtBtn.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(container)
            make.top.equalTo(container)
            make.right.equalTo(container)
            make.bottom.equalTo(sepLine1)
        }
        districtBtn.addTarget(self, action: "showDistrictPicker", forControlEvents: .TouchUpInside)
        //
        let licenseStaticLbl = UILabel()
        licenseStaticLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        licenseStaticLbl.textColor = UIColor(white: 0.72, alpha: 1)
        licenseStaticLbl.text = LS("车牌号")
        container.addSubview(licenseStaticLbl)
        licenseStaticLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(sepLine1)
            make.top.equalTo(sepLine1).offset(22)
        }
        let arrow2 = UIImageView(image: UIImage(named: "account_btn_next_icon"))
        container.addSubview(arrow2)
        arrow2.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(arrow)
            make.centerY.equalTo(licenseStaticLbl)
            make.size.equalTo(CGSizeMake(9, 15))
        }
        carLicense = UITextField()
        carLicense.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        carLicense.placeholder = LS("请填写车牌号")
        carLicense.textColor = UIColor.blackColor()
        carLicense.textAlignment = .Right
        carLicense.delegate = self
        inputFields.append(carLicense)
        container.addSubview(carLicense)
        carLicense.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(districtLabel)
            make.centerY.equalTo(licenseStaticLbl)
            make.height.equalTo(licenseStaticLbl)
            make.width.equalTo(100)
        }
        let sepLine2 = UIView()
        sepLine2.backgroundColor = UIColor(white: 0.945, alpha: 1)
        container.addSubview(sepLine2)
        sepLine2.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(sepLine1)
            make.right.equalTo(sepLine1)
            make.top.equalTo(licenseStaticLbl.snp_bottom).offset(11)
            make.height.equalTo(0.5)
        }
        return container
    }
    
    func createDistrictPicker() {
        let superview = self.view
        districtPickerContainer = UIView()
        districtPickerContainer.backgroundColor = UIColor(white: 0.945, alpha: 1)
        superview.addSubview(districtPickerContainer)
        districtPickerContainer.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(superview.snp_bottom)
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.height.equalTo(234)
        }
        //
        let pickerHeader = UIView()
        pickerHeader.backgroundColor = UIColor(white: 0.92, alpha: 1)
        districtPickerContainer.addSubview(pickerHeader)
        pickerHeader.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(districtPickerContainer)
            make.right.equalTo(districtPickerContainer)
            make.left.equalTo(districtPickerContainer)
            make.height.equalTo(35)
        }
        //
        let pickerTitle = UILabel()
        pickerTitle.text = LS("选择车牌地区")
        pickerTitle.font = UIFont.systemFontOfSize(14)
        pickerHeader.addSubview(pickerTitle)
        pickerTitle.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(pickerHeader).offset(20)
            make.centerY.equalTo(pickerHeader)
        }
        //
        let doneBtn = UIButton()
        doneBtn.setTitle(LS("完成"), forState: .Normal)
        doneBtn.setTitleColor(kHighlightedRedTextColor, forState: .Normal)
        doneBtn.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        pickerHeader.addSubview(doneBtn)
        doneBtn.addTarget(self, action: "donePickDistrictBtnPressed", forControlEvents: .TouchUpInside)
        doneBtn.snp_makeConstraints { (make) -> Void in
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
        districtPicker.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(districtPickerContainer)
            make.top.equalTo(pickerHeader.snp_bottom)
            make.left.equalTo(districtPickerContainer)
            make.bottom.equalTo(districtPickerContainer)
        }
    }
    
    func donePickDistrictBtnPressed() {
        let index = districtPicker.selectedRowInComponent(0)
        districtLabel.text = kDistrictSet[index]
        hideDistrictPicker()
    }
    
    func showDistrictPicker() {
        districtBtn.enabled = false
        tapper?.enabled = true
        districtPickerContainer.snp_remakeConstraints { (make) -> Void in
            make.right.equalTo(self.view)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.height.equalTo(234)
        }
        SpringAnimation.spring(0.3) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    func hideDistrictPicker() {
        districtBtn.enabled = true
        tapper?.enabled = false
        districtPickerContainer.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(self.view)
            make.left.equalTo(self.view)
            make.top.equalTo(self.view.snp_bottom)
            make.height.equalTo(234)
        }
        SpringAnimation.spring(0.3) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    override func dismissKeyboard() {
        super.dismissKeyboard()
        hideDistrictPicker()
    }
    
}

// MARK: - privide data for district picker
extension SportscarAuthController {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return kDistrictSet.count
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFontOfSize(15, weight: UIFontWeightLight)
        titleLabel.textAlignment = .Center
        titleLabel.text = kDistrictSet[row]
        titleLabel.textColor = UIColor.blackColor()
        return titleLabel
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
}

