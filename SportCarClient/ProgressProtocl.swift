//
//  ProgressProtocl.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/18.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


private var associateObjectHandle: UInt8 = 0

protocol ProgressProtocol: class {
    func pp_createProgressView()
    
    func pp_updateProgress(progress: Float)
    
    func pp_hideProgressView()
    
    func pp_showProgressView()
    
    func pp_layoutProgressView()
    
    var pp_progressView: UIProgressView? { get set }
}

extension ProgressProtocol where Self: UIViewController {
    
    var pp_progressView: UIProgressView? {
        set {
            objc_setAssociatedObject(self, &associateObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return objc_getAssociatedObject(self, &associateObjectHandle) as? UIProgressView
        }
    }
    
    func pp_createProgressView() {
        let progress = UIProgressView()
        progress.tintColor = kHighlightedRedTextColor
        progress.backgroundColor = UIColor.clearColor()
        self.view.addSubview(progress)
        self.pp_progressView = progress
        pp_layoutProgressView()
    }
    
    func pp_layoutProgressView() {
        let superview = self.view
        pp_progressView?.snp_makeConstraints(closure: { (make) -> Void in
            make.top.equalTo(superview)
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.height.equalTo(3)
        })
    }
    
    func pp_updateProgress(progress: Float) {
        pp_progressView?.setProgress(progress, animated: false)
    }
    
    func pp_hideProgressView() {
        pp_progressView?.hidden = true
        pp_progressView?.setProgress(0, animated: false)
    }
    
    func pp_showProgressView() {
        if pp_progressView == nil {
            pp_createProgressView()
        }
        pp_progressView?.hidden = false
    }
}
