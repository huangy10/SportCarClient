//
//  InputableViewController.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/13.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit


class InputableViewController: UIViewController, UITextFieldDelegate {
    var tapper: UITapGestureRecognizer?
    var inputFields: [UITextField?] = []
    
    override func loadView() {
        super.loadView()
        createSubviews()
    }
    
    func createSubviews(){
        self.tapper = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
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
}
