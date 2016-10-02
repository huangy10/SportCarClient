//
//  PermissionCheck.swift
//  SportCarClient
//
//  Created by 黄延 on 16/7/18.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import AlecrimCoreData


protocol Syncable {
    
    func sync()
    
    func resync()
    
    func update()
}


class PermissionCheck: Syncable {
    
    static let sharedInstance = PermissionCheck()
    
    fileprivate var requesting: Bool = false
    fileprivate var _synced: Bool = false
    fileprivate var _infered: Bool = false
    fileprivate var anonymous: Bool {
        return MainManager.sharedManager.hostUser == nil
    }
    
    fileprivate var _releaseActivity: Bool = false
    
    var releaseActivity: Bool {
        get {
            if !_synced {
                sync()
            }
            return _releaseActivity
        }
        set {
            _releaseActivity = newValue
        }
    }
    
    func sync() {
        if _synced || anonymous || requesting {
            return
        }
        requesting = true
        _ = AccountRequester2.sharedInstance.syncPermission({ (json) in
            self._synced = true
            self.releaseActivity = json!["allow_to_release_acts"].boolValue
            self.requesting = false
            }) { (code) in
                self.requesting = false
                self._infered = false
                self.inferFromLocalData()
        }
    }
    
    func resync() {
        _synced = false
        _infered = false
        sync()
    }
    
    func update() {
        // Not defined yet
    }
    
    func inferFromLocalData() {
        if _infered {
            return
        }
        let ctx = getAlecrimCoreDataContext()
        if let hostID = MainManager.sharedManager.hostUserID {
            releaseActivity = ctx.sportCars.filter({ $0.hostSSID == hostID })
                .filter({ $0.mine == true && $0.identified == true})
                .any()
            _infered = true
        }
    }
    
    func getAlecrimCoreDataContext() -> DataContext {
        if Thread.isMainThread {
            return MainManager.sharedManager.getOperationContext()
        } else {
            return ChatModelManger.sharedManager.getOperationContext()
        }
    }
}

