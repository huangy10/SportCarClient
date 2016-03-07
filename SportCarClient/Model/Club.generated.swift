//
//  Club.generated.swift
//
//  This code was generated by AlecrimCoreData code generator tool.
//
//  Changes to this file may cause incorrect behavior and will be lost if
//  the code is regenerated.
//

import Foundation
import CoreData

import AlecrimCoreData

// MARK: - Club properties

extension Club {

    @NSManaged var city: String?
    @NSManaged var clubDescription: String?
    @NSManaged var clubID: String?
    @NSManaged var created_at: NSDate?
    @NSManaged var identified: Bool // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var logo_url: String?
    @NSManaged var memberNum: Int32 // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var name: String?
    @NSManaged var onlyHostInvites: Bool // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var show_members: Bool // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var value: Int32 // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var valueAverage: Int32 // cannot mark as optional because Objective-C compatibility issues

    @NSManaged var host: User?
    @NSManaged var mostRecentChat: ChatRecord?

    @NSManaged var activity: Set<Activity>
    @NSManaged var chats: Set<ChatRecord>
    @NSManaged var members: Set<User>

}

// MARK: - Club KVC compliant to-many accessors and helpers

extension Club {

    @NSManaged private func addActivityObject(object: Activity)
    @NSManaged private func removeActivityObject(object: Activity)
    @NSManaged func addActivity(activity: Set<Activity>)
    @NSManaged func removeActivity(activity: Set<Activity>)

    @NSManaged private func addChatsObject(object: ChatRecord)
    @NSManaged private func removeChatsObject(object: ChatRecord)
    @NSManaged func addChats(chats: Set<ChatRecord>)
    @NSManaged func removeChats(chats: Set<ChatRecord>)

    @NSManaged private func addMembersObject(object: User)
    @NSManaged private func removeMembersObject(object: User)
    @NSManaged func addMembers(members: Set<User>)
    @NSManaged func removeMembers(members: Set<User>)

    @nonobjc func addActivity(activity: Activity) { self.addActivityObject(activity) }
    @nonobjc func removeActivity(activity: Activity) { self.removeActivityObject(activity) }

    func addChat(chat: ChatRecord) { self.addChatsObject(chat) }
    func removeChat(chat: ChatRecord) { self.removeChatsObject(chat) }

    func addMember(member: User) { self.addMembersObject(member) }
    func removeMember(member: User) { self.removeMembersObject(member) }
}

// MARK: - Club query attributes

extension Club {

    static let city = AlecrimCoreData.NullableAttribute<String>("city")
    static let clubDescription = AlecrimCoreData.NullableAttribute<String>("clubDescription")
    static let clubID = AlecrimCoreData.NullableAttribute<String>("clubID")
    static let created_at = AlecrimCoreData.NullableAttribute<NSDate>("created_at")
    static let identified = AlecrimCoreData.NullableAttribute<Bool>("identified")
    static let logo_url = AlecrimCoreData.NullableAttribute<String>("logo_url")
    static let memberNum = AlecrimCoreData.NullableAttribute<Int32>("memberNum")
    static let name = AlecrimCoreData.NullableAttribute<String>("name")
    static let onlyHostInvites = AlecrimCoreData.NullableAttribute<Bool>("onlyHostInvites")
    static let show_members = AlecrimCoreData.NullableAttribute<Bool>("show_members")
    static let value = AlecrimCoreData.NullableAttribute<Int32>("value")
    static let valueAverage = AlecrimCoreData.NullableAttribute<Int32>("valueAverage")

    static let host = AlecrimCoreData.NullableAttribute<User>("host")
    static let mostRecentChat = AlecrimCoreData.NullableAttribute<ChatRecord>("mostRecentChat")

    static let activity = AlecrimCoreData.Attribute<Set<Activity>>("activity")
    static let chats = AlecrimCoreData.Attribute<Set<ChatRecord>>("chats")
    static let members = AlecrimCoreData.Attribute<Set<User>>("members")

}

// MARK: - AttributeType extensions

extension AlecrimCoreData.AttributeType where Self.ValueType: Club {

    var city: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("city", self) }
    var clubDescription: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("clubDescription", self) }
    var clubID: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("clubID", self) }
    var created_at: AlecrimCoreData.NullableAttribute<NSDate> { return AlecrimCoreData.NullableAttribute<NSDate>("created_at", self) }
    var identified: AlecrimCoreData.NullableAttribute<Bool> { return AlecrimCoreData.NullableAttribute<Bool>("identified", self) }
    var logo_url: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("logo_url", self) }
    var memberNum: AlecrimCoreData.NullableAttribute<Int32> { return AlecrimCoreData.NullableAttribute<Int32>("memberNum", self) }
    var name: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("name", self) }
    var onlyHostInvites: AlecrimCoreData.NullableAttribute<Bool> { return AlecrimCoreData.NullableAttribute<Bool>("onlyHostInvites", self) }
    var show_members: AlecrimCoreData.NullableAttribute<Bool> { return AlecrimCoreData.NullableAttribute<Bool>("show_members", self) }
    var value: AlecrimCoreData.NullableAttribute<Int32> { return AlecrimCoreData.NullableAttribute<Int32>("value", self) }
    var valueAverage: AlecrimCoreData.NullableAttribute<Int32> { return AlecrimCoreData.NullableAttribute<Int32>("valueAverage", self) }

    var host: AlecrimCoreData.NullableAttribute<User> { return AlecrimCoreData.NullableAttribute<User>("host", self) }
    var mostRecentChat: AlecrimCoreData.NullableAttribute<ChatRecord> { return AlecrimCoreData.NullableAttribute<ChatRecord>("mostRecentChat", self) }

    var activity: AlecrimCoreData.Attribute<Set<Activity>> { return AlecrimCoreData.Attribute<Set<Activity>>("activity", self) }
    var chats: AlecrimCoreData.Attribute<Set<ChatRecord>> { return AlecrimCoreData.Attribute<Set<ChatRecord>>("chats", self) }
    var members: AlecrimCoreData.Attribute<Set<User>> { return AlecrimCoreData.Attribute<Set<User>>("members", self) }

}

// MARK: - DataContext extensions

extension DataContext {

    var clubs: AlecrimCoreData.Table<Club> { return AlecrimCoreData.Table<Club>(dataContext: self) }

}

