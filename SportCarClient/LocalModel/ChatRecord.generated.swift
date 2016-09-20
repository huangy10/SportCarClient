//
//  ChatRecord.generated.swift
//
//  This code was generated by AlecrimCoreData code generator tool.
//
//  Changes to this file may cause incorrect behavior and will be lost if
//  the code is regenerated.
//

import Foundation
import CoreData

import AlecrimCoreData

// MARK: - ChatRecord properties

extension ChatRecord {

    @NSManaged var audio: String?
    @NSManaged var audioCaches: String?
    @NSManaged var audioLength: Double // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var audioReady: Bool // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var chatType: String?
    @NSManaged var createdAt: Date?
    @NSManaged var draft: String?
    @NSManaged var hidden: Bool // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var image: String?
    @NSManaged var imageHeight: Int32 // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var imageWidth: Int32 // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var messageType: String?
    @NSManaged var mine: Bool // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var read: Bool // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var relatedClub: String?
    @NSManaged var relatedUser: String?
    @NSManaged var rosterID: Int32 // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var sender: String?
    @NSManaged var sent: Bool // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var targetID: Int32 // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var textContent: String?
    @NSManaged var updatedAt: Date?

}

// MARK: - ChatRecord query attributes

extension ChatRecord {

    static let audio = AlecrimCoreData.NullableAttribute<String>("audio")
    static let audioCaches = AlecrimCoreData.NullableAttribute<String>("audioCaches")
    static let audioLength = AlecrimCoreData.NullableAttribute<Double>("audioLength")
    static let audioReady = AlecrimCoreData.NullableAttribute<Bool>("audioReady")
    static let chatType = AlecrimCoreData.NullableAttribute<String>("chatType")
    static let createdAt = AlecrimCoreData.NullableAttribute<NSDate>("createdAt")
    static let draft = AlecrimCoreData.NullableAttribute<String>("draft")
    static let hidden = AlecrimCoreData.NullableAttribute<Bool>("hidden")
    static let image = AlecrimCoreData.NullableAttribute<String>("image")
    static let imageHeight = AlecrimCoreData.NullableAttribute<Int32>("imageHeight")
    static let imageWidth = AlecrimCoreData.NullableAttribute<Int32>("imageWidth")
    static let messageType = AlecrimCoreData.NullableAttribute<String>("messageType")
    static let mine = AlecrimCoreData.NullableAttribute<Bool>("mine")
    static let read = AlecrimCoreData.NullableAttribute<Bool>("read")
    static let relatedClub = AlecrimCoreData.NullableAttribute<String>("relatedClub")
    static let relatedUser = AlecrimCoreData.NullableAttribute<String>("relatedUser")
    static let rosterID = AlecrimCoreData.NullableAttribute<Int32>("rosterID")
    static let sender = AlecrimCoreData.NullableAttribute<String>("sender")
    static let sent = AlecrimCoreData.NullableAttribute<Bool>("sent")
    static let targetID = AlecrimCoreData.NullableAttribute<Int32>("targetID")
    static let textContent = AlecrimCoreData.NullableAttribute<String>("textContent")
    static let updatedAt = AlecrimCoreData.NullableAttribute<NSDate>("updatedAt")

}

// MARK: - AttributeType extensions

extension AlecrimCoreData.AttributeType where Self.ValueType: ChatRecord {

    var audio: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("audio", self) }
    var audioCaches: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("audioCaches", self) }
    var audioLength: AlecrimCoreData.NullableAttribute<Double> { return AlecrimCoreData.NullableAttribute<Double>("audioLength", self) }
    var audioReady: AlecrimCoreData.NullableAttribute<Bool> { return AlecrimCoreData.NullableAttribute<Bool>("audioReady", self) }
    var chatType: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("chatType", self) }
    var createdAt: AlecrimCoreData.NullableAttribute<Date> { return AlecrimCoreData.NullableAttribute<NSDate>("createdAt", self) }
    var draft: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("draft", self) }
    var hidden: AlecrimCoreData.NullableAttribute<Bool> { return AlecrimCoreData.NullableAttribute<Bool>("hidden", self) }
    var image: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("image", self) }
    var imageHeight: AlecrimCoreData.NullableAttribute<Int32> { return AlecrimCoreData.NullableAttribute<Int32>("imageHeight", self) }
    var imageWidth: AlecrimCoreData.NullableAttribute<Int32> { return AlecrimCoreData.NullableAttribute<Int32>("imageWidth", self) }
    var messageType: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("messageType", self) }
    var mine: AlecrimCoreData.NullableAttribute<Bool> { return AlecrimCoreData.NullableAttribute<Bool>("mine", self) }
    var read: AlecrimCoreData.NullableAttribute<Bool> { return AlecrimCoreData.NullableAttribute<Bool>("read", self) }
    var relatedClub: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("relatedClub", self) }
    var relatedUser: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("relatedUser", self) }
    var rosterID: AlecrimCoreData.NullableAttribute<Int32> { return AlecrimCoreData.NullableAttribute<Int32>("rosterID", self) }
    var sender: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("sender", self) }
    var sent: AlecrimCoreData.NullableAttribute<Bool> { return AlecrimCoreData.NullableAttribute<Bool>("sent", self) }
    var targetID: AlecrimCoreData.NullableAttribute<Int32> { return AlecrimCoreData.NullableAttribute<Int32>("targetID", self) }
    var textContent: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("textContent", self) }
    var updatedAt: AlecrimCoreData.NullableAttribute<Date> { return AlecrimCoreData.NullableAttribute<NSDate>("updatedAt", self) }

}

// MARK: - DataContext extensions

extension DataContext {

    var chatRecords: AlecrimCoreData.Table<ChatRecord> { return AlecrimCoreData.Table<ChatRecord>(dataContext: self) }

}

