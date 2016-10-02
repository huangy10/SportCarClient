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
        deleteBtn.setTitle(LS("删除"), for: UIControlState())
        deleteBtn.setTitleColor(kHighlightedRedTextColor, for: UIControlState())
        deleteBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightUltraLight)
        container.addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(container)
            make.top.equalTo(sepLine).offset(45)
            make.size.equalTo(CGSize(width: 40, height: 25))
        }
        deleteBtn.addTarget(self, action: #selector(StatusDeleteController.deleteBtnPressed), for: .touchUpInside)
    }
    
    func deleteBtnPressed() {
//        toast = showConfirmToast(LS("删除动态"), message: LS("确认删除这条动态吗？"), target: self, confirmSelector: #selector(StatusDeleteController.deleteConfirmed), cancelSelector: #selector(StatusDeleteController.deleteCancelled), onSelf: true)
        
        showConfirmToast(LS("删除动态"), message: LS("确认删除这条动态吗？"), target: self, onConfirm: #selector(deleteConfirmed))
    }
    
    func deleteConfirmed() {
        let requester = StatusRequester.sharedInstance
        let waitSignal = DispatchSemaphore(value: 0)
        lp_start()
        _ = requester.deleteStatus(status.ssidString, onSuccess: { (json) -> () in
            self.lp_stop()
            // 删除成功以后发送一个notification
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: kStatusDidDeletedNotification), object: nil, userInfo: [kStatusDidDeletedStatusIDKey: self.status.ssidString, kStatusKey: self.status])
            waitSignal.signal()
            
            self.delegate?.statusDidDeleted()
            self.hideAnimated({ [weak self] in
                DispatchQueue.main.async(execute: {
                    self?.delegate?.statusDidDeleted()
                })
                })
            }) { (code) -> () in
                self.lp_stop()
                self.showToast(LS("删除失败"), onSelf: true)
        }
    }
}
