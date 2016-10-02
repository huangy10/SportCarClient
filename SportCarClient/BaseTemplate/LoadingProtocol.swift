//
//  LoadingProtocol.swift
//  SportCarClient
//
//  Created by 黄延 on 16/5/23.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


private var containerHandle: UInt8 = 1
private var loadingViewHandle: UInt8 = 2
private var timerHandle: UInt8 = 3
private var taskHandle: UInt8 = 4


protocol LoadingProtocol: class {
    func lp_start()
    
    func lp_stop()
    
    var lp_container: UIView! { get set }
    var lp_loadingView: UIImageView! { get set }
    var lp_timer: Timer! {set get}
    
    var delayWorkItem: DispatchWorkItem? { get set }
}


extension LoadingProtocol where Self: UIViewController {
    
    var lp_container: UIView! {
        
        get {
            if let container = objc_getAssociatedObject(self, &containerHandle) as? UIView {
                return container
            } else {
                let superview = self.view!
                let container: UIView
                if (superview.isKind(of: UITableView.self)) {
                    container = superview.addSubview(UIView.self).config(UIColor(white: 0, alpha: 0.2))
                    container.frame = UIScreen.main.bounds
                } else {
                    container = superview.addSubview(UIView.self).config(UIColor(white: 0, alpha: 0.2))
                        .layout({ (make) in
                            make.edges.equalTo(superview)
                        })
                }
                
                let rect = container.addSubview(UIView.self).config(UIColor.white)
                    .toRound(6)
                    .layout({ (make) in
                        make.centerX.equalTo(container)
                        make.size.equalTo(70)
                        make.top.equalTo(container).offset(150)
                    })
                rect.layer.opacity = 0
                rect.transform = CGAffineTransform(scaleX: 1.28, y: 1.28)
                let loading = UIImageView(image: UIImage(named: "loading"))
                rect.addSubview(loading)
                loading.frame = CGRect(x: 0, y: 0, width: 37.5, height: 37.5)
                loading.contentMode = .scaleAspectFit
                loading.center = CGPoint(x: 35, y: 35)
                loading.layer.opacity = 0
                self.lp_loadingView = loading
                
                UIView.animate(withDuration: 0.3, animations: { 
                    rect.layer.opacity = 1
                    rect.transform = CGAffineTransform.identity
                    loading.layer.opacity = 1
                })
                objc_setAssociatedObject(self, &containerHandle, container, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return container
            }
        }
        
        set {
            objc_setAssociatedObject(self, &containerHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var lp_loadingView: UIImageView! {
        set {
            objc_setAssociatedObject(self, &loadingViewHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            if let _ = self.lp_container{
                return objc_getAssociatedObject(self, &loadingViewHandle) as? UIImageView
            } else {
                return nil
            }
        }
    }
    
    var lp_timer: Timer! {
        set {
            objc_setAssociatedObject(self, &timerHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            return objc_getAssociatedObject(self, &timerHandle) as? Timer
        }
    }
    
    func lp_stop() {
        if lp_timer != nil {
            lp_timer.invalidate()
            lp_timer = nil
            lp_container.isHidden = true
            lp_container.removeFromSuperview()
            lp_container = nil
        } else if self.delayWorkItem != nil {
//            dispatch_block_cancel(delayTask!)
            delayWorkItem?.cancel()
        } else {
            assertionFailure()
        }
        delayWorkItem = nil
    }
    
    func lp_start() {
        let delay = DispatchTime.now() + Double(Int64(NSEC_PER_MSEC) * kLoadingAppearDelay) / Double(NSEC_PER_SEC)
        lp_timer = nil
        
        delayWorkItem = DispatchWorkItem(block: { [weak self] in
            guard let sSelf = self else {
                return
            }
            let timer = Timer.schedule(repeatInterval: 0.05, handler: { (_) in
                let curTrans = sSelf.lp_loadingView.transform
                let newTrans = curTrans.rotated(by: 0.4)
                sSelf.lp_loadingView.transform = newTrans
            })
            sSelf.lp_timer = timer
        })
        
//        delayTask = dispatch_block_create(__DISPATCH_BLOCK_INHERIT_QOS_CLASS, { [weak self] in
//            guard let sSelf = self else {
//                return
//            }
//            let timer = Timer.schedule(repeatInterval: 0.05, handler: { (_) in
//                let curTrans = sSelf.lp_loadingView.transform
//                let newTrans = curTrans.rotated(by: 0.4)
//                sSelf.lp_loadingView.transform = newTrans
//            })
//            sSelf.lp_timer = timer
//        })
        DispatchQueue.main.asyncAfter(deadline: delay, execute: delayWorkItem!)
    }
}
