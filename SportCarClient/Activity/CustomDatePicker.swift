//
//  CustomDatePicker.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/19.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
protocol CustomDatePickerDelegate: class {
    
    func dateDidPicked(date: NSDate)
    
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
        self.backgroundColor = UIColor.whiteColor()
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
        pickerTitleLbl.font = UIFont.systemFontOfSize(14)
        pickerTitleLbl.textColor = UIColor.blackColor()
        header.addSubview(pickerTitleLbl)
        pickerTitleLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(header).offset(20)
            make.centerY.equalTo(header)
            make.width.equalTo(30)
        }
        //
        doneBtn = UIButton()
        doneBtn.setTitle(LS("完成"), forState: .Normal)
        doneBtn.setTitleColor(kHighlightedRedTextColor, forState: .Normal)
        doneBtn.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        doneBtn.addTarget(self, action: "doneBtnPressed", forControlEvents: .TouchUpInside)
        superview.addSubview(doneBtn)
        doneBtn.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(header).offset(-20)
            make.centerY.equalTo(header)
            make.height.equalTo(header)
            make.width.equalTo(30)
        }
        //
        picker = UIDatePicker()
        picker.datePickerMode = .DateAndTime
        picker.minimumDate = NSDate()
        picker.setDate(NSDate(), animated: true)
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
        let now = NSDate()
        picker.minimumDate = now
        picker.setDate(now, animated: false)
    }
}
