//
//  RosterManager.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/23.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SwiftyJSON

class RosterManager {
    static let defaultManager = RosterManager()
    /// The data of the roster
    var data = MyOrderedDict<String, RosterItem>()
    /// The rosterList
    weak var rosterList: UITableView?
    
    var synchronized: Bool = false;
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    init () {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onClubMemberChange(_:)), name: kMessageClubMemberChangeNotification, object: nil)
    }
    
    var queue: dispatch_queue_t {
        return ChatModelManger.sharedManager.workQueue
    }
    
    /**
     - parameter bringToFront: whether to bring the added roster item to the  very front of the roster list
     - returns: if the new item has already exists in the roster list before the insertion
     */
    @available(*, deprecated=1)
    func addNewRosterItem(newItem: RosterItem, bringToFront: Bool = false) -> Bool{
        if let roster = data[newItem.mapKey] {
            roster.recentChatDes = newItem.recentChatDes
            self.data.bringKeyToFront(newItem.mapKey)
            return false
        }
        data[newItem.mapKey] = newItem
        self.data.bringKeyToFront(newItem.mapKey)
        return true
    }
    
    /**
     Accept json data as input and get the output
     */
    func getOrCreateNewRoster(json: JSON, autoBringToFront: Bool = false) -> RosterItem {
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
                data.bringKeyToFront(mapKey)
            }
            return existingRosterItem
        } else {
            let newItem = try! ChatModelManger.sharedManager.getOrCreate(json) as RosterItem
            data[mapKey] = newItem
            if autoBringToFront {
                data.bringKeyToFront(mapKey)
            }
            return newItem
        }
    }
    
    @available(*, deprecated=1)
    func rosterItemForUser(user: User) -> RosterItem? {
        for (_, item) in data._dict {
            switch item.data! {
            case .USER(let chater):
                if chater.ssid == user.ssid {
                    return item
                }
            default:
                continue
            }
        }
        return nil
    }
    
    @available(*, deprecated=1)
    func rosterItemForClub(club: Club) -> RosterItem? {
        for (_, item) in data._dict {
            switch item.data! {
            case .CLUB(let club):
                if club.ssid == club.ssid {
                    return item
                }
            default:
                continue
            }
        }
        return nil
    }
    
    /**
     Request roster list from server, work on the Message queue
     */
    func sync() {
        dispatch_async(queue) {
            self._sync()
        }
    }
    
    /**
     actual working queue
     */
    private func _sync() {
        ChatRequester2.sharedInstance.getChatList({ (json) in
            let newRosters = MyOrderedDict<String, RosterItem>()
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
            dispatch_async(dispatch_get_main_queue(), { 
                self.rosterList?.reloadData()
            })
            }) { (code) in
                self.synchronized = false
                if self.data.count == 0 {
                    // 若此时数据仍然是空的，尝试从数据库中读入列表
                    let context = ChatModelManger.sharedManager.getOperationContext()
                    context.rosterItems.orderByDescending({ $0.createdAt }).filter({
                        $0.hostSSID == MainManager.sharedManager.hostUserID!
                    }).each { self.data[$0.mapKey] = $0 }
                    if self.data.count > 0 {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.rosterList?.reloadData()
                        })
                    }
                }
        }
    }
    
    func loadCachedRosterItems() {
        
    }
    
    @objc func onClubMemberChange(notification: NSNotification) {
        guard let club = notification.userInfo?[kMessageClubKey] as? Club else {
            assertionFailure()
            return
        }
        let mapKey = "club:\(club.ssid)"
        if let rosterItem = self.data[mapKey] {
            switch rosterItem.data! {
            case .CLUB(let _club):
                _club.memberNum = club.memberNum
            default:
                return
            }
        }
    }
}
