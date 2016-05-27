//
//  PersonMineSinglePropertyModifier.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/12.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

protocol PersonMineSinglePropertyModifierDelegate: class {
    func didModify(newValue: String?, indexPath: NSIndexPath)
    func modificationCancelled()
}

class PersonMineSinglePropertyModifierController: InputableViewController {
    
    weak var delegate: PersonMineSinglePropertyModifierDelegate?
    var initValue: String?
    var propertyName: String?
    var contentInput: UITextField!
    var focusedIndexPath: NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
    }
    
    override func createSubviews() {
        super.createSubviews()
        let superview = self.view
        superview.backgroundColor = UIColor.whiteColor()
        contentInput = UITextField()
        inputFields.append(contentInput)
        contentInput.delegate = self
        contentInput.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        contentInput.textColor = UIColor.blackColor()
        contentInput.text = initValue
        superview.addSubview(contentInput)
        contentInput.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(15)
            make.right.equalTo(superview).offset(-15)
            make.top.equalTo(superview).offset(22)
            make.height.equalTo(17)
        }
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.92, alpha: 1)
        superview.addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentInput)
            make.right.equalTo(contentInput)
            make.top.equalTo(superview).offset(52.5)
            make.height.equalTo(0.5)
        }
    }
    
    func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = propertyName
        //
        let navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        navLeftBtn.frame = CGRectMake(0, 0, 9, 15)
        navLeftBtn.addTarget(self, action: #selector(PersonMineSinglePropertyModifierController.navLeftBtnPressed), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        //
        let rightItem = UIBarButtonItem(title: LS("确定"), style: .Done, target: self, action: #selector(PersonMineSinglePropertyModifierController.navRightBtnPressed))
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func navLeftBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
        delegate?.modificationCancelled()
    }
    
    func navRightBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
        delegate?.didModify(contentInput.text, indexPath: self.focusedIndexPath)
    }
}
