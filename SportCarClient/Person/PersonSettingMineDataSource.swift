//
//  PersonSettingMineDataSource.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/12.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation

let PMUpdateFinishedNotification = "pm_update_finished_notification"
let PMUpdateErrorNotification = "pm_update_error_notification"

let kPersonMineSettingsLocationVisibleMapping: [String: String] = [
    "all": "所有人",
    "female_only": "仅女性",
    "male_only": "仅男性",
    "none": "不可见",
    "only_idol": "仅我关注的人",
    "only_friend": "互相关注",
]

let kPersonMineSettingsLocationVisibilityList: [String] = ["all", "female_only", "male_only", "none", "only_idol", "only_friend"]

let kPersonMineSettingsAcceptInvitationMapping: [String: String] = [
    "all": "所有人",
    "friend": "互相关注",
    "follow": "我关注的",
    "fans": "关注我的",
    "auth_first": "需通过验证",
    "never": "不允许",
]

let kPersonMineSettingsAcceptInvitationList: [String] = ["all", "friend", "follow", "fans", "auth_first", "never"]

class PersonMineSettingsDataSource {
    static let sharedDataSource = PersonMineSettingsDataSource()
    
    var locationVisible: String!
    var acceptInvitation: String!
    
    var newMessageNotificationSound: Bool = true
    var newMessageNotificationShake: Bool = true
    var newMessageNotificationAccept: Bool = true
    var showOnMap: Bool = true
    
    var cacheSize: UInt64 = 0
    var cacheSizeDes: String?
    
    init() {
        loadFromUserDefault()
        // 取消创建时自动
//        update()
    }
    
    /**
     将本地设置同步到服务器端
     */
    func sync() {
        let uploadParam: [String: AnyObject] = [
            "notification_accept": newMessageNotificationAccept ? "y" : "n",
            "notification_shake": newMessageNotificationShake ? "y" : "n",
            "notification_sound": newMessageNotificationSound ? "y" : "n",
            "location_visible_to": locationVisible,
            "accept_invitation": acceptInvitation,
            "show_on_map": showOnMap ? "y" : "n"
        ]
        let requester = SettingsRequester.sharedInstance
        requester.syncPersonMineSettings(uploadParam, onSuccess: { (data) -> () in
            print("setting data uploaded")
            }) { (code) -> () in
                print("sync error")
        }
    }
    
    /**
     从服务器获取最新的设置
     */
    func update() {
        getCacheFolderSize()
        let requester = SettingsRequester.sharedInstance
        requester.updatePersonMineSettings({ (json) -> () in
            if let data = json {
                self.locationVisible = data["location_visible_to"].stringValue
                self.acceptInvitation = data["accept_invitation"].stringValue
                self.newMessageNotificationAccept = data["notification_accept"].boolValue
                self.newMessageNotificationShake = data["notification_shake"].boolValue
                self.newMessageNotificationSound = data["notification_sound"].boolValue
                self.showOnMap = data["show_on_map"].boolValue
                self.saveToUserDefault()
                NSNotificationCenter.defaultCenter().postNotificationName(PMUpdateFinishedNotification, object: nil)
            }
            }) { (code) -> () in
                NSNotificationCenter.defaultCenter().postNotificationName(PMUpdateErrorNotification, object: nil, userInfo: ["code": code ?? "0000"])
        }
    }
    
    func saveToUserDefault() {
        let prefix = MainManager.sharedManager.hostUserIDString!
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setObject(locationVisible, forKey: prefix + "_location_visibile")
        userDefault.setObject(acceptInvitation, forKey: prefix + "_accept_invitation")
        userDefault.setBool(newMessageNotificationSound, forKey: prefix + "_notification_sound")
        userDefault.setBool(newMessageNotificationShake, forKey: prefix + "_notification_shake")
        userDefault.setBool(newMessageNotificationAccept, forKey: prefix + "_notification_accept")
    }
    
    func loadFromUserDefault() {
        let prefix = MainManager.sharedManager.hostUserIDString!
        let userDefault = NSUserDefaults.standardUserDefaults()
        locationVisible = (userDefault.objectForKey(prefix + "_location_visible") as? String) ?? "all"
        acceptInvitation = (userDefault.objectForKey(prefix + "_accept_invitation") as? String) ?? "all"
        newMessageNotificationAccept = (userDefault.boolForKey(prefix + "_notification_accept")) ?? true
        newMessageNotificationShake = userDefault.boolForKey(prefix + "_notification_shake") ?? true
        newMessageNotificationSound = userDefault.boolForKey(prefix + "_notification_sound") ?? true
        newMessageNotificationAccept = userDefault.boolForKey(prefix + "_notification_accept") ?? true
    }
    
    func getCacheFolderSize() {
        let fileManger = NSFileManager.defaultManager()
        let cacheFolderPath: AnyObject = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
        do {
            let subpaths = try fileManger.subpathsOfDirectoryAtPath(cacheFolderPath as! String)
            var size: UInt64 = 0
            for fileName in subpaths {
                let filePath = cacheFolderPath.stringByAppendingPathComponent(fileName)
                let fileInfo: NSDictionary = try fileManger.attributesOfItemAtPath(filePath)
                size += fileInfo.fileSize()
            }
            cacheSize = size
            var shiftLevel = 0
            var sizedouble = Double(size)
            while sizedouble > 1024 {
                sizedouble = sizedouble / 1024
                shiftLevel += 1
                if shiftLevel >= 3 {
                    break
                }
            }
            let sizeString = String(format: "%.1f", sizedouble)
            cacheSizeDes = sizeString + ["", "KB", "MB", "GB"][shiftLevel]
        }catch _ {
            cacheSizeDes = LS("获取缓存大小失败")
        }
    }
    
    func clearCacheFolder() -> Bool {
        let fileManger = NSFileManager.defaultManager()
        let cacheFolderPath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
        let cacheFolderURL = NSURL(fileURLWithPath: cacheFolderPath)
        let enumerator = fileManger.enumeratorAtPath(cacheFolderPath)!
        do {
            while let file: String = enumerator.nextObject() as? String {
                try fileManger.removeItemAtURL(cacheFolderURL.URLByAppendingPathComponent(file))
            }
            self.cacheSize = 0
            self.cacheSizeDes = ""
            return true
        } catch _ {
            return false
        }
    }
}