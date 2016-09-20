//
//  WaitableProtocol.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/9.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Alamofire

// A plugin to give the controller who confirm to it the ability to show waiting views and disable the main board at the same time
protocol WaitableProtocol: class {
    
    // container view
    var wp_waitingContainer: UIView? { set get }
    
    weak var requestOnFly: Request? { get }
    
    /**
     start waiting, will disable other views. Notice that the navigation bar buttons still work
     */
    func wp_startWaiting()
    
    /**
     stop waiting, which will remove container
     */
    func wp_stopWaiting()
    
    /**
     waiting aborted, the rquest on fly will be cancelled
     */
    func wp_abortWaiting()
}


extension WaitableProtocol where Self: UIViewController {
    
    func wp_startWaiting() {
        if wp_waitingContainer != nil {
            // duplicated call
            assertionFailure()
        }
        
        let superview = self.view
        wp_waitingContainer = superview?.addSubview(UIView).config(UIColor.clear)
            .layout({ (make) in
                make.edges.equalTo(superview)
            })
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        wp_waitingContainer?.addSubview(activityView)
        activityView.snp_makeConstraints { (make) in
            make.center.equalTo(wp_waitingContainer!)
            make.size.equalTo(60)
        }
        wp_waitingContainer?.layer.opacity = 0
        UIView.animate(withDuration: 0.3, animations: { 
            self.wp_waitingContainer?.layer.opacity = 1
        }) 
    }
    
    func wp_stopWaiting() {
        if wp_waitingContainer == nil {
            assertionFailure()
        }
        UIView.animate(withDuration: 0.3, animations: { 
            self.wp_waitingContainer?.layer.opacity = 0
            }, completion: { (_) in
                self.wp_waitingContainer?.removeFromSuperview()
                self.wp_waitingContainer = nil
        }) 
    }
    
    func wp_abortWaiting() {
        if let request = requestOnFly {
            request.cancel()
        }
    }
    
}
