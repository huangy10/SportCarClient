//
//  InputableViewController.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/13.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit


class InputableViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    var tapper: UITapGestureRecognizer?
    var inputFields: [UIView?] = []
    var delayWorkItem: DispatchWorkItem?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
    }
    
    func createSubviews(){
        self.tapper = UITapGestureRecognizer(target: self, action: #selector(InputableViewController.dismissKeyboard))
        tapper?.isEnabled = false
        self.view.addGestureRecognizer(tapper!)
        
    }
    
    func dismissKeyboard() {
        for inputer in self.inputFields{
            inputer?.resignFirstResponder()
        }
        tapper?.isEnabled = false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.tapper?.isEnabled = true
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.tapper?.isEnabled = true
        return true
    }
}
