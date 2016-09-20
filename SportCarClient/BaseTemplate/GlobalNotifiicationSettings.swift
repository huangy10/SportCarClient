
//
//  GlobalNotifiicationSettings.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/14.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation


// Notifications
let kUnreadNumberDidChangeNotification = "unread_number_did_change_notification"
func ss_sendUnreadNumberDidChangeNotification() {
    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: kUnreadNumberDidChangeNotification), object: nil)
}
let kNotificationUnreadClearNotification = "unread_notif_clear"

let kStatusDidDeletedNotification = "status_did_deleted_notification"
let kStatusDidDeletedStatusIDKey = "statusID"
let kStatusNewNotification = "status_new_notification"
let kStatusKey = "status_key"

let kUserBlacklistedNotification = "user_blacklisted"
let kUserSSIDKey = "userID"
let kUserKey = "user"
let kUserListKey = "users"
let kUserUnBlacklistedNotification = "user_unblacklisted"

let kActivityManualEndedNotification = "act_manual_ended"
let kActivityKey = "activitiyObj"
let kActivitySSIDKey = "activity_ssid"

// MARK: Chat
let kMessageNewChatMergedNotification = "new_chat_merged"
let kMessageChatListKey = "chats"
let kMessageChatResetNotification = "chat_message_reset"
let kMessageClubMemberChangeNotification = "club_member_change"
let kMessageClubKey = "club"
let kMessageClubDelete = "club_delete"
let kMessageStopAllVoicePlayNotification = "stop_all_voice_play"
let kMessageChatHistoryCleared = "chat_history_cleared"
let kRosterItemKey  = "roster_item"


// MARK: Account
 ///  当从服务器返回了1402错误时，意味着当前使用jwttoken已经失效了，强制用户下线，这1402错误由MessageManager来负责看管
let kAccontNolongerLogin = "no_longer_login"
let kAccountBlacklistChange = "black_list_change"
let kAccountBlackStatusKey = "block_status"
let kAccountBlackStatusDefault = "default"
let kAccountBlackStatusBlocked = "blocked"
let kAccountInfoChanged = "info_changed"

// MARK: Car

let kCarDeletedNotification = "car_deleted"
let kSportcarKey = "sportcar_key"

// MAKR: Activity

let kActivityInfoChanged = "activity_changed"
