//
//  User.generated.swift
//
//  This code was generated by AlecrimCoreData code generator tool.
//
//  Changes to this file may cause incorrect behavior and will be lost if
//  the code is regenerated.
//

import Foundation
import CoreData

import AlecrimCoreData

// MARK: - User properties

extension User {

    @NSManaged var age: Int32 // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var avatar: String?
    @NSManaged var avatarCar: String?
    @NSManaged var avatarClub: String?
    @NSManaged var birthDate: NSDate?
    @NSManaged var blacklisted: Bool // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var district: String?
    @NSManaged var fansNum: Int32 // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var followed: Bool // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var followsNum: Int32 // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var gender: String?
    @NSManaged var identified: Bool // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var job: String?
    @NSManaged var nickName: String?
    @NSManaged var noteName: String?
    @NSManaged var phoneNum: String?
    @NSManaged var recentStatusDes: String?
    @NSManaged var remarkName: String?
    @NSManaged var signature: String?
    @NSManaged var starSign: String?
    @NSManaged var statusNum: Int32 // cannot mark as optional because Objective-C compatibility issues

    @NSManaged var acts: Set<Activity>
    @NSManaged var notifications: Set<Notification>
    @NSManaged var status: Set<Status>

}

// MARK: - User KVC compliant to-many accessors and helpers

extension User {

    @NSManaged private func addActsObject(object: Activity)
    @NSManaged private func removeActsObject(object: Activity)
    @NSManaged func addActs(acts: Set<Activity>)
    @NSManaged func removeActs(acts: Set<Activity>)

    @NSManaged private func addNotificationsObject(object: Notification)
    @NSManaged private func removeNotificationsObject(object: Notification)
    @NSManaged func addNotifications(notifications: Set<Notification>)
    @NSManaged func removeNotifications(notifications: Set<Notification>)

    @NSManaged private func addStatusObject(object: Status)
    @NSManaged private func removeStatusObject(object: Status)
    @NSManaged func addStatus(status: Set<Status>)
    @NSManaged func removeStatus(status: Set<Status>)

    func addAct(act: Activity) { self.addActsObject(act) }
    func removeAct(act: Activity) { self.removeActsObject(act) }

    func addNotification(notification: Notification) { self.addNotificationsObject(notification) }
    func removeNotification(notification: Notification) { self.removeNotificationsObject(notification) }

    func addStatu(statu: Status) { self.addStatusObject(statu) }
    func removeStatu(statu: Status) { self.removeStatusObject(statu) }

}

// MARK: - User query attributes

extension User {

    static let age = AlecrimCoreData.NullableAttribute<Int32>("age")
    static let avatar = AlecrimCoreData.NullableAttribute<String>("avatar")
    static let avatarCar = AlecrimCoreData.NullableAttribute<String>("avatarCar")
    static let avatarClub = AlecrimCoreData.NullableAttribute<String>("avatarClub")
    static let birthDate = AlecrimCoreData.NullableAttribute<NSDate>("birthDate")
    static let blacklisted = AlecrimCoreData.NullableAttribute<Bool>("blacklisted")
    static let district = AlecrimCoreData.NullableAttribute<String>("district")
    static let fansNum = AlecrimCoreData.NullableAttribute<Int32>("fansNum")
    static let followed = AlecrimCoreData.NullableAttribute<Bool>("followed")
    static let followsNum = AlecrimCoreData.NullableAttribute<Int32>("followsNum")
    static let gender = AlecrimCoreData.NullableAttribute<String>("gender")
    static let identified = AlecrimCoreData.NullableAttribute<Bool>("identified")
    static let job = AlecrimCoreData.NullableAttribute<String>("job")
    static let nickName = AlecrimCoreData.NullableAttribute<String>("nickName")
    static let noteName = AlecrimCoreData.NullableAttribute<String>("noteName")
    static let phoneNum = AlecrimCoreData.NullableAttribute<String>("phoneNum")
    static let recentStatusDes = AlecrimCoreData.NullableAttribute<String>("recentStatusDes")
    static let remarkName = AlecrimCoreData.NullableAttribute<String>("remarkName")
    static let signature = AlecrimCoreData.NullableAttribute<String>("signature")
    static let starSign = AlecrimCoreData.NullableAttribute<String>("starSign")
    static let statusNum = AlecrimCoreData.NullableAttribute<Int32>("statusNum")

    static let acts = AlecrimCoreData.Attribute<Set<Activity>>("acts")
    static let notifications = AlecrimCoreData.Attribute<Set<Notification>>("notifications")
    static let status = AlecrimCoreData.Attribute<Set<Status>>("status")

}

// MARK: - AttributeType extensions

extension AlecrimCoreData.AttributeType where Self.ValueType: User {

    var age: AlecrimCoreData.NullableAttribute<Int32> { return AlecrimCoreData.NullableAttribute<Int32>("age", self) }
    var avatar: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("avatar", self) }
    var avatarCar: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("avatarCar", self) }
    var avatarClub: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("avatarClub", self) }
    var birthDate: AlecrimCoreData.NullableAttribute<NSDate> { return AlecrimCoreData.NullableAttribute<NSDate>("birthDate", self) }
    var blacklisted: AlecrimCoreData.NullableAttribute<Bool> { return AlecrimCoreData.NullableAttribute<Bool>("blacklisted", self) }
    var district: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("district", self) }
    var fansNum: AlecrimCoreData.NullableAttribute<Int32> { return AlecrimCoreData.NullableAttribute<Int32>("fansNum", self) }
    var followed: AlecrimCoreData.NullableAttribute<Bool> { return AlecrimCoreData.NullableAttribute<Bool>("followed", self) }
    var followsNum: AlecrimCoreData.NullableAttribute<Int32> { return AlecrimCoreData.NullableAttribute<Int32>("followsNum", self) }
    var gender: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("gender", self) }
    var identified: AlecrimCoreData.NullableAttribute<Bool> { return AlecrimCoreData.NullableAttribute<Bool>("identified", self) }
    var job: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("job", self) }
    var nickName: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("nickName", self) }
    var noteName: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("noteName", self) }
    var phoneNum: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("phoneNum", self) }
    var recentStatusDes: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("recentStatusDes", self) }
    var remarkName: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("remarkName", self) }
    var signature: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("signature", self) }
    var starSign: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("starSign", self) }
    var statusNum: AlecrimCoreData.NullableAttribute<Int32> { return AlecrimCoreData.NullableAttribute<Int32>("statusNum", self) }

    var acts: AlecrimCoreData.Attribute<Set<Activity>> { return AlecrimCoreData.Attribute<Set<Activity>>("acts", self) }
    var notifications: AlecrimCoreData.Attribute<Set<Notification>> { return AlecrimCoreData.Attribute<Set<Notification>>("notifications", self) }
    var status: AlecrimCoreData.Attribute<Set<Status>> { return AlecrimCoreData.Attribute<Set<Status>>("status", self) }

}

// MARK: - DataContext extensions

extension DataContext {

    var users: AlecrimCoreData.Table<User> { return AlecrimCoreData.Table<User>(dataContext: self) }

}

