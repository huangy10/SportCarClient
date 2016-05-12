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
    NSNotificationCenter.defaultCenter().postNotificationName(kUnreadNumberDidChangeNotification, object: nil)
}
let kNotificationUnreadClearNotification = "unread_notif_clear"

let kStatusDidDeletedNotification = "status_did_deleted_notification"
let kStatusDidDeletedStatusIDKey = "statusID"

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