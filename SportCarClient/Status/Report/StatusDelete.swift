//
//  StatusDelete.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/1.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit



protocol StatusDeleteDelegate: class {
    func statusDidDeleted()
}


class StatusDeleteController: PresentTemplateViewController, LoadingProtocol {
    
    weak var delegate: StatusDeleteDelegate?
    
    var deleteBtn: UIButton!
    var status: Status!
    
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
        deleteBtn.addTarget(self, action: #selector(StatusDeleteController.deleteBtnPressed), forControlEvents: .TouchUpInside)
    }
    
    func deleteBtnPressed() {
//        toast = showConfirmToast(LS("删除动态"), message: LS("确认删除这条动态吗？"), target: self, confirmSelector: #selector(StatusDeleteController.deleteConfirmed), cancelSelector: #selector(StatusDeleteController.deleteCancelled), onSelf: true)
        
        showConfirmToast(LS("删除动态"), message: LS("确认删除这条动态吗？"), target: self, onConfirm: #selector(deleteConfirmed))
    }
    
    func deleteConfirmed() {
        let requester = StatusRequester.sharedInstance
        let waitSignal = dispatch_semaphore_create(0)
        lp_start()
        requester.deleteStatus(status.ssidString, onSuccess: { (json) -> () in
            self.lp_stop()
            // 删除成功以后发送一个notification
            NSNotificationCenter.defaultCenter().postNotificationName(kStatusDidDeletedNotification, object: nil, userInfo: [kStatusDidDeletedStatusIDKey: self.status.ssidString, kStatusKey: self.status])
            dispatch_semaphore_signal(waitSignal)
            
            self.delegate?.statusDidDeleted()
            self.hideAnimated({ [weak self] in
                dispatch_async(dispatch_get_main_queue(), {
                    self?.delegate?.statusDidDeleted()
                })
                })
            }) { (code) -> () in
                self.lp_stop()
                self.showToast(LS("删除失败"), onSelf: true)
        }
    }
}
