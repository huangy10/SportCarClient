//
//  PersonMineSinglePropertyModifier.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/12.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

protocol PersonMineSinglePropertyModifierDelegate: class {
    func didModify(_ newValue: String?, indexPath: IndexPath)
    func modificationCancelled()
}

class PersonMineSinglePropertyModifierController: InputableViewController {
    
    weak var delegate: PersonMineSinglePropertyModifierDelegate?
    var initValue: String?
    var propertyName: String?
    var contentInput: UITextField!
    var focusedIndexPath: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
    }
    
    override func createSubviews() {
        super.createSubviews()
        let superview = self.view!
        superview.backgroundColor = UIColor.white
        contentInput = UITextField()
        inputFields.append(contentInput)
        contentInput.delegate = self
        contentInput.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        contentInput.textColor = UIColor.black
        contentInput.text = initValue
        superview.addSubview(contentInput)
        contentInput.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(15)
            make.right.equalTo(superview).offset(-15)
            make.top.equalTo(superview).offset(22)
            make.height.equalTo(17)
        }
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.92, alpha: 1)
        superview.addSubview(sepLine)
        sepLine.snp.makeConstraints { (make) -> Void in
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
        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), for: UIControlState())
        navLeftBtn.frame = CGRect(x: 0, y: 0, width: 9, height: 15)
        navLeftBtn.addTarget(self, action: #selector(PersonMineSinglePropertyModifierController.navLeftBtnPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        //
        let rightItem = UIBarButtonItem(title: LS("确定"), style: .done, target: self, action: #selector(PersonMineSinglePropertyModifierController.navRightBtnPressed))
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], for: UIControlState())
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func navLeftBtnPressed() {
        _ = self.navigationController?.popViewController(animated: true)
        delegate?.modificationCancelled()
    }
    
    func navRightBtnPressed() {
        _ = self.navigationController?.popViewController(animated: true)
        delegate?.didModify(contentInput.text, indexPath: self.focusedIndexPath)
    }
}
