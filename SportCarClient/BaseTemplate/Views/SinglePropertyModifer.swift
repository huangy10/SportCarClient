//
//  SinglePropertyModifer.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/30.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

protocol SinglePropertyModifierDelegate: class {
    
    func singlePropertyModifierDidModify(_ newValue: String?, forIndexPath indexPath: IndexPath)
    
    func singlePropertyModifierDidCancelled()
}


class SinglePropertyModifierController: InputableViewController {
    weak var delegate: SinglePropertyModifierDelegate?
    fileprivate var placeholder: String?
    fileprivate var text: String?
    fileprivate var propertyName: String!
    fileprivate var contentInput: UITextField!
    fileprivate var forcusedIndexPath: IndexPath!
    
    init (
        propertyName: String,
        delegate: SinglePropertyModifierDelegate,
        forcusedIndexPath: IndexPath!,
        placeholder: String? = nil,
        text: String? = nil
        ) {
        self.propertyName = propertyName
        self.delegate = delegate
        self.placeholder = placeholder
        self.forcusedIndexPath = forcusedIndexPath
        self.text = text
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
    }
    
    func navSettings() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = propertyName
        let navLeftBtn = UIButton().config(self, selector: #selector(navLeftBtnPressed), image: UIImage(named: "account_header_back_btn"))
            .setFrame(CGRect(x: 0, y: 0, width: 9, height: 15))
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        let rightItem = UIBarButtonItem(title: LS("确定"), style: .done, target: self, action: #selector(navRightBtnPressed))
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], for: .normal)
        navigationItem.rightBarButtonItem = rightItem
    }
    
    func navLeftBtnPressed() {
        _ = navigationController?.popViewController(animated: true)
        delegate?.singlePropertyModifierDidCancelled()
    }
    
    func navRightBtnPressed() {
        _ = navigationController?.popViewController(animated: true)
        delegate?.singlePropertyModifierDidModify(contentInput.text, forIndexPath: forcusedIndexPath)
    }
    
    func pushFromViewController(_ viewController: UIViewController) {
        assert(viewController.navigationController != nil)
        viewController.navigationController?.pushViewController(self, animated: true)
    }
    
    override func createSubviews() {
        super.createSubviews()
        let superview = self.view!
        superview.backgroundColor = UIColor.white
        contentInput = superview.addSubview(UITextField.self)
            .config(placeholder: placeholder, text: text)
            .addToInputable(self)
            .layout({ (make) in
                make.left.equalTo(superview).offset(15)
                make.right.equalTo(superview).offset(-15)
                make.top.equalTo(superview).offset(22)
                make.height.equalTo(17)
            })
        superview.addSubview(UIView.self).config(UIColor(white: 0.92, alpha: 1))
            .layout { (make) in
                make.left.equalTo(contentInput)
                make.right.equalTo(contentInput)
                make.top.equalTo(superview).offset(52.5)
                make.height.equalTo(0.5)
        }
    }
    
}
