//
//  SinglePropertyModifer.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/30.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

protocol SinglePropertyModifierDelegate: class {
    
    func singlePropertyModifierDidModify(newValue: String?, forIndexPath indexPath: NSIndexPath)
    
    func singlePropertyModifierDidCancelled()
}


class SinglePropertyModifierController: InputableViewController {
    weak var delegate: SinglePropertyModifierDelegate?
    private var placeholder: String?
    private var text: String?
    private var propertyName: String!
    private var contentInput: UITextField!
    private var forcusedIndexPath: NSIndexPath!
    
    init (
        propertyName: String,
        delegate: SinglePropertyModifierDelegate,
        forcusedIndexPath: NSIndexPath!,
        placeholder: String? = nil,
        text: String? = nil
        ) {
        self.propertyName = propertyName
        self.delegate = delegate
        self.placeholder = placeholder
        self.forcusedIndexPath = forcusedIndexPath
        self.text = text
        super.init(nibName: nil, bundle: nil)
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
            .setFrame(CGRectMake(0, 0, 9, 15))
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        let rightItem = UIBarButtonItem(title: LS("确定"), style: .Done, target: self, action: #selector(navRightBtnPressed))
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
        navigationItem.rightBarButtonItem = rightItem
    }
    
    func navLeftBtnPressed() {
        navigationController?.popViewControllerAnimated(true)
        delegate?.singlePropertyModifierDidCancelled()
    }
    
    func navRightBtnPressed() {
        navigationController?.popViewControllerAnimated(true)
        delegate?.singlePropertyModifierDidModify(contentInput.text, forIndexPath: forcusedIndexPath)
    }
    
    func pushFromViewController(viewController: UIViewController) {
        assert(viewController.navigationController != nil)
        viewController.navigationController?.pushViewController(self, animated: true)
    }
    
    override func createSubviews() {
        super.createSubviews()
        let superview = self.view
        superview.backgroundColor = UIColor.whiteColor()
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
