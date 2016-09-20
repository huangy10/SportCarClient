//
//  CustomDatePicker.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/19.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import Spring

protocol CustomDatePickerDelegate: class {
    
    func dateDidPicked(_ date: Date)
    
    func datePickCancel()
}


class CustomDatePicker: UIView {
    
    weak var delegate: CustomDatePickerDelegate?
    
    var header: UIView!
    var doneBtn: UIButton!
    var picker: UIDatePicker!
    var pickerTitleLbl: UILabel!
    
    static let requiredHegiht = 234
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubview() {
        let superview = self
        self.backgroundColor = UIColor.white
        //
        header = UIView()
        header.backgroundColor = UIColor(white: 0.92, alpha: 1)
        superview.addSubview(header)
        header.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(superview)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.height.equalTo(35)
        }
        //
        pickerTitleLbl = UILabel()
        pickerTitleLbl.font = UIFont.systemFont(ofSize: 14)
        pickerTitleLbl.textColor = UIColor.black
        header.addSubview(pickerTitleLbl)
        pickerTitleLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(header).offset(20)
            make.centerY.equalTo(header)
            make.width.equalTo(30)
        }
        //
        doneBtn = UIButton()
        doneBtn.setTitle(LS("完成"), for: UIControlState())
        doneBtn.setTitleColor(kHighlightedRedTextColor, for: UIControlState())
        doneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
        doneBtn.addTarget(self, action: #selector(CustomDatePicker.doneBtnPressed), for: .touchUpInside)
        superview.addSubview(doneBtn)
        doneBtn.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(header).offset(-20)
            make.centerY.equalTo(header)
            make.height.equalTo(header)
            make.width.equalTo(30)
        }
        //
        picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.minimumDate = Date()
        picker.setDate(Date(), animated: true)
        superview.addSubview(picker)
        picker.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.top.equalTo(header.snp_bottom)
            make.bottom.equalTo(superview)
        }
    }
    
    func doneBtnPressed() {
        delegate?.dateDidPicked(picker.date)
    }
    
    func reset() {
        let now = Date()
        picker.minimumDate = now
        picker.setDate(now, animated: false)
    }
    
    func show(_ date: Date? = nil) {
        self.snp_remakeConstraints { (make) in
            make.right.equalTo(self.superview!)
            make.left.equalTo(self.superview!)
            make.bottom.equalTo(self.superview!)
            make.height.equalTo(CustomDatePicker.requiredHegiht)
        }
        if date != nil {
            picker.setDate(date!, animated: false)
        }
        SpringAnimation.spring(0.3) { 
            self.superview?.layoutIfNeeded()
        }
    }
    
    func hide() {
        self.snp_remakeConstraints { (make) in
            make.right.equalTo(self.superview!)
            make.left.equalTo(self.superview!)
            make.top.equalTo(self.superview!.snp_bottom)
            make.height.equalTo(CustomDatePicker.requiredHegiht)
        }
        SpringAnimation.spring(0.3) { 
            self.superview?.layoutIfNeeded()
        }
    }
}
