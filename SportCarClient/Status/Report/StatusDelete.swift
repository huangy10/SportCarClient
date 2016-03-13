//
//  StatusDelete.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/1.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


let kStatusDidDeletedNotification = "status_did_deleted_notification"
let kStatusDidDeletedStatusIDKey = "statusID"

protocol StatusDeleteDelegate {
    func statusDidDeleted()
}


class StatusDeleteController: PresentTemplateViewController {
    
    var delegate: StatusDeleteDelegate?
    
    var deleteBtn: UIButton!
    var status: Status!
    
    weak var toast: UIView?
    
    override func createContent() {
        deleteBtn = UIButton()
        deleteBtn.setTitle(LS("删除"), forState: .Normal)
        deleteBtn.setTitleColor(kHighlightedRedTextColor, forState: .Normal)
        deleteBtn.titleLabel?.font = UIFont.systemFontOfSize(17, weight: UIFontWeightUltraLight)
        container.addSubview(deleteBtn)
        deleteBtn.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(container)
            make.top.equalTo(sepLine).offset(45)
            make.size.equalTo(CGSizeMake(40, 25))
        }
        deleteBtn.addTarget(self, action: "deleteBtnPressed", forControlEvents: .TouchUpInside)
    }
    
    func deleteBtnPressed() {
        toast = showConfirmToast(LS("确认删除这条状态吗？"), target: self, confirmSelector: "deleteConfirmed", cancelSelector: "deleteCancelled")
    }
    
    func deleteConfirmed() {
        hideConfirmToast(toast!)
        let requester = StatusRequester.SRRequester
        let waitSignal = dispatch_semaphore_create(0)
        requester.deleteStatus(status.statusID!, onSuccess: { (json) -> () in
            // 删除成功以后发送一个notification
            NSNotificationCenter.defaultCenter().postNotificationName(kStatusDidDeletedNotification, object: nil, userInfo: [kStatusDidDeletedStatusIDKey: self.status.statusID!])
            dispatch_semaphore_signal(waitSignal)
            }) { (code) -> () in
                dispatch_semaphore_signal(waitSignal)
        }
        dispatch_semaphore_wait(waitSignal, DISPATCH_TIME_FOREVER)
        delegate?.statusDidDeleted()
        hideAnimated()
    }
    
    func deleteCancelled() {
        hideConfirmToast(toast!)
    }
}
