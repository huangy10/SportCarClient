//
//  Suggestions.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/1.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//
//  个人设置：意见反馈
//

import UIKit


class SuggestionController: PresentTemplateViewController {
    var suggestionInput: UITextView!
    var confirmBtn: UIButton!
    
    var beginEditing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
    }
    
    override func createSubviews() {
        self.tapper = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tapper?.isEnabled = false
        self.view.addGestureRecognizer(tapper!)
        let superview = self.view!
        //
        bg = UIImageView(image: bgImage)
        superview.addSubview(bg)
        bg.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        //
        bgBlurred = UIImageView(image: self.blurImageUsingCoreImage(bgImage))
        superview.addSubview(bgBlurred)
        bgBlurred.layer.opacity = 0
        bgBlurred.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(bg)
        }
        //
        bgMask = UIView()
        bgMask.backgroundColor = UIColor(white: 1, alpha: 0.7)
        superview.addSubview(bgMask)
        bgMask.layer.opacity = 0
        //
        container = UIView()
        container.layer.cornerRadius = 4
        container.backgroundColor = UIColor.white
        superview.addSubview(container)
        container.snp.makeConstraints { (make) -> Void in
            make.size.equalTo(CGSize(width: 250, height: 175))
            make.centerX.equalTo(superview)
            make.top.equalTo(superview.snp.bottom).offset(-30)
        }
        // 
        let staticLbl = UILabel()
        staticLbl.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightSemibold)
        staticLbl.textColor = UIColor.black
        staticLbl.text = LS("意见反馈")
        container.addSubview(staticLbl)
        staticLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(container).offset(15)
            make.top.equalTo(container).offset(20)
        }
        //
        suggestionInput = UITextView()
        inputFields.append(suggestionInput)
        suggestionInput.delegate = self
        suggestionInput.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        suggestionInput.textColor = UIColor(white: 0.72, alpha: 1)
        suggestionInput.text = LS("请在此处输入反馈...")
        container.addSubview(suggestionInput)
        suggestionInput.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(staticLbl)
            make.right.equalTo(container).offset(-15)
            make.top.equalTo(staticLbl.snp.bottom).offset(10)
            make.height.equalTo(80)
        }
        //
        confirmBtn = UIButton()
        confirmBtn.setTitle(LS("确定"), for: UIControlState())
        confirmBtn.setTitleColor(kHighlightedRedTextColor, for: UIControlState())
        confirmBtn.addTarget(self, action: #selector(confirmMessageSent), for: .touchUpInside)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        container.addSubview(confirmBtn)
        confirmBtn.snp.makeConstraints { (make) -> Void in
            make.size.equalTo(CGSize(width: 74, height: 43))
            make.bottom.equalTo(container)
            make.right.equalTo(container).offset(-10)
        }
        //
        cancelBtn = UIButton()
        cancelBtn.setTitle(LS("取消"), for: UIControlState())
        cancelBtn.addTarget(self, action: #selector(hideAnimated), for: .touchUpInside)
        cancelBtn.setTitleColor(UIColor(white: 0.72, alpha: 1), for: UIControlState())
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        container.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(confirmBtn)
            make.size.equalTo(CGSize(width: 74, height: 43))
            make.right.equalTo(confirmBtn.snp.left)
        }
    }
    
    override func showAnimated() {
        self.view.layoutIfNeeded()
        container.snp.remakeConstraints { (make) -> Void in
            make.size.equalTo(CGSize(width: 250, height: 175))
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.view).offset(100)
        }
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.bg.layer.opacity = 0
            self.bgBlurred.layer.opacity = 1
            self.bgMask.layer.opacity = 1
        }) 
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    override func hideAnimated(_ completion: (() -> ())?) {
        self.view.layoutIfNeeded()
        container.snp.remakeConstraints { (make) -> Void in
            make.size.equalTo(CGSize(width: 250, height: 175))
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.view.snp.bottom)
        }
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.bg.layer.opacity = 1
            self.bgBlurred.layer.opacity = 0
            self.bgMask.layer.opacity = 0
            }, completion: { (_) -> Void in
                self.presentingViewController?.dismiss(animated: false, completion: nil)
        }) 
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if beginEditing {
            return
        }
        beginEditing = true
        textView.text = ""
        textView.textColor = UIColor.black
    }
    
    func confirmMessageSent() {
        hideAnimated(nil)
        UIApplication.shared.keyWindow?.rootViewController?.showToast(LS("感谢您提出的意见！"))
    }
}
