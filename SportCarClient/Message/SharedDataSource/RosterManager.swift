//
//  RosterManager.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/23.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SwiftyJSON
import AlecrimCoreData

class RosterDict: MyOrderedDict<String, RosterItem> {
    
    func resortRosters() {
        let rosters = _dict.map({ $0.1 })
        _keys = rosters.sorted(by: { (r1, r2) -> Bool in
//            if r1.alwaysOnTop && !r2.alwaysOnTop {
//                return true
//            } else if r1.updatedAt!.compare(r2.updatedAt!) == .orderedDescending {
//                return true
//            }
//            return false
            if r1.updatedAt!.compare(r2.updatedAt!) == .orderedDescending {
                return true
            }
            return false
        }).map({$0.mapKey})
    }
}

class RosterManager {
    static let defaultManager = RosterManager()
    /// The data of the roster
    var data = RosterDict()
    /// The rosterList
    weak var rosterList: UITableView?
    
    var synchronized: Bool = false;
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init () {
        NotificationCenter.default.addObserver(self, selector: #selector(onClubMemberChange(_:)), name: NSNotification.Name(rawValue: kMessageClubMemberChangeNotification), object: nil)
    }
    
    var queue: DispatchQueue {
        return ChatModelManger.sharedManager.workQueue
    }
    
    var onTopNum: Int = 0
    
    /**
     Accept json data as input and get the output
     */
    func getOrCreateNewRoster(_ json: JSON, autoBringToFront: Bool = false) -> RosterItem {
        let entityType = json["entity_type"].stringValue
        var mapKey = ""
        if entityType == "user" {
            mapKey = "user:\(json["user"][User.idField].int32Value)"
        } else {
            mapKey = "club:\(json["club"][Club.idField].int32Value)"
        }
        if let existingRosterItem = data[mapKey] {
            try! existingRosterItem.loadDataFromJSON(json)
            if autoBringToFront {
//                data.bringKeyToFront(mapKey)
                data.resortRosters()
            }
            return existingRosterItem
        } else {
            let newItem = try! ChatModelManger.sharedManager.getOrCreate(json) as RosterItem
            data[mapKey] = newItem
            // always bring to front
//            data.bringKeyToFront(mapKey)
            data.resortRosters()
            
            return newItem
        }
    }

    /**
     Request roster list from server, work on the Message queue
     */
    func sync() {
//        dispatch_async(queue) {
//            self._sync()
//        }
        queue.async { 
            self._load()
        }
    }
    
    fileprivate func _load() {
        if data.count > 0 {
            data.removeAll()
        }
        guard let hostID = MainManager.sharedManager.hostUserID else {
            return
        }
        let context = ChatModelManger.sharedManager.getOperationContext()
        // TODO: order by createdAt or updatedAt?
        let existingRosterItems = context.rosterItems.filter({$0.hostSSID == hostID})
            .orderBy(ascending: false, orderingClosure: { $0.updatedAt })
        var unread: Int = 0
        existingRosterItems.forEach { (item) in
            item.manager = ChatModelManger.sharedManager
            unread += Int(item.unreadNum)
        }
        MessageManager.defaultManager.unreadChatNum += unread
        if unread == 0 {
            ss_sendUnreadNumberDidChangeNotification()
        }
        for item in existingRosterItems {
            let mapKey: String
            if item.entityType! == "user" {
                mapKey = "user:\(item.relatedID)"
            } else if item.entityType! == "club" {
                mapKey = "club:\(item.relatedID)"
            } else {
                mapKey = ""
                assertionFailure()
            }
            data[mapKey] = item
        }
    }
    
    func countOnTopNum() {
        var temp = 0
        for key in data.keys {
            let item = data[key]!
            
            switch item.data! {
            case .club(let club):
                if club.alwayOnTop {
                    temp += 1
                }
            default:
                break
            }
        }
        onTopNum = 0
    }
    
    /**
     actual working queue
     */
    fileprivate func _sync() {
        _ = ChatRequester2.sharedInstance.getChatList({ (json) in
            let newRosters = RosterDict()
            var unreadTotal = 0
            for var data in json!.arrayValue {
                do {
                    data["attended"].bool = true
                    let item = try ChatModelManger.sharedManager.getOrCreate(data) as RosterItem
                    newRosters[item.mapKey] = item
                    unreadTotal += Int(item.unreadNum)
                } catch {
                    self.synchronized = false
                    return
                }
            }
            self.data = newRosters
            MessageManager.defaultManager.unreadChatNum = unreadTotal
            self.synchronized = true
            DispatchQueue.main.async(execute: { 
                self.rosterList?.reloadData()
            })
            }) { (code) in
                self.synchronized = false
                if self.data.count == 0 {
                    // 若此时数据仍然是空的，尝试从数据库中读入列表
                    let context = ChatModelManger.sharedManager.getOperationContext()
                    _ = context.rosterItems.orderBy(ascending: false, orderingClosure: { $0.createdAt }).filter({
                        $0.hostSSID == MainManager.sharedManager.hostUserID!
                    }).each { self.data[$0.mapKey] = $0 }
                    if self.data.count > 0 {
                        DispatchQueue.main.async(execute: {
                            self.rosterList?.reloadData()
                        })
                    }
                }
        }
    }
    
    func deleteAndQuitClub(_ club: Club) {
        club.attended = false
        let wait = DispatchSemaphore(value: 0)
        queue.async {
            let context = ChatModelManger.sharedManager.getOperationContext()
            context.rosterItems.filter({ $0.ssid == MainManager.sharedManager.hostUserID! })
                .filter({ $0.entityType == "club" && $0.relatedID == club.ssid })
                .deleteEntities()
            wait.signal()
        }
        _ = wait.wait(timeout: DispatchTime.distantFuture)
        let mapKey = "club:\(club.ssid)"
        self.data[mapKey] = nil
    }
    
    @objc func onClubMemberChange(_ notification: Foundation.Notification) {
        guard let club = (notification as NSNotification).userInfo?[kMessageClubKey] as? Club else {
            assertionFailure()
            return
        }
        let mapKey = "club:\(club.ssid)"
        if let rosterItem = self.data[mapKey] {
            switch rosterItem.data! {
            case .club(let _club):
                _club.memberNum = club.memberNum
            default:
                return
            }
        }
    }
    
    /**
     暂时删除存储在本地的聊天数据，当重新有该聊天的数据到来时会重新出现
     */
    func removeLocalRosterItemStorage(at index: Int) {
        let item = data.valueForIndex(index)
        let context = ChatModelManger.sharedManager.getOperationContext()
        context.rosterItems.deleteEntity(item!)
        data.remove(at: index)
    }
}
