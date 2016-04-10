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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
    }
    
    func createSubviews(){
        self.tapper = UITapGestureRecognizer(target: self, action: #selector(InputableViewController.dismissKeyboard))
        tapper?.enabled = false
        self.view.addGestureRecognizer(tapper!)
        
    }
    
    func dismissKeyboard() {
        for inputer in self.inputFields{
            inputer?.resignFirstResponder()
        }
        tapper?.enabled = false
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        self.tapper?.enabled = true
        return true
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        self.tapper?.enabled = true
        return true
    }
}
