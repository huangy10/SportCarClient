//
//  SportCar.generated.swift
//
//  This code was generated by AlecrimCoreData code generator tool.
//
//  Changes to this file may cause incorrect behavior and will be lost if
//  the code is regenerated.
//

import Foundation
import CoreData

import AlecrimCoreData

// MARK: - SportCar properties

extension SportCar {

    @NSManaged var audio: String?
    @NSManaged var body: String?
    @NSManaged var engine: String?
    @NSManaged var identified: Bool // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var images: String?
    @NSManaged var logo: String?
    @NSManaged var manufacturer: String?
    @NSManaged var maxSpeed: String?
    @NSManaged var mine: Bool // cannot mark as optional because Objective-C compatibility issues
    @NSManaged var name: String?
    @NSManaged var price: String?
    @NSManaged var signature: String?
    @NSManaged var subname: String?
    @NSManaged var torque: String?
    @NSManaged var video: String?
    @NSManaged var zeroTo60: String?

}

// MARK: - SportCar query attributes

extension SportCar {

    static let audio = AlecrimCoreData.NullableAttribute<String>("audio")
    static let body = AlecrimCoreData.NullableAttribute<String>("body")
    static let engine = AlecrimCoreData.NullableAttribute<String>("engine")
    static let identified = AlecrimCoreData.NullableAttribute<Bool>("identified")
    static let images = AlecrimCoreData.NullableAttribute<String>("images")
    static let logo = AlecrimCoreData.NullableAttribute<String>("logo")
    static let manufacturer = AlecrimCoreData.NullableAttribute<String>("manufacturer")
    static let maxSpeed = AlecrimCoreData.NullableAttribute<String>("maxSpeed")
    static let mine = AlecrimCoreData.NullableAttribute<Bool>("mine")
    static let name = AlecrimCoreData.NullableAttribute<String>("name")
    static let price = AlecrimCoreData.NullableAttribute<String>("price")
    static let signature = AlecrimCoreData.NullableAttribute<String>("signature")
    static let subname = AlecrimCoreData.NullableAttribute<String>("subname")
    static let torque = AlecrimCoreData.NullableAttribute<String>("torque")
    static let video = AlecrimCoreData.NullableAttribute<String>("video")
    static let zeroTo60 = AlecrimCoreData.NullableAttribute<String>("zeroTo60")

}

// MARK: - AttributeType extensions

extension AlecrimCoreData.AttributeProtocol where Self.ValueType: SportCar {

    var audio: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("audio", self) }
    var body: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("body", self) }
    var engine: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("engine", self) }
    var identified: AlecrimCoreData.NullableAttribute<Bool> { return AlecrimCoreData.NullableAttribute<Bool>("identified", self) }
    var images: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("images", self) }
    var logo: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("logo", self) }
    var manufacturer: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("manufacturer", self) }
    var maxSpeed: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("maxSpeed", self) }
    var mine: AlecrimCoreData.NullableAttribute<Bool> { return AlecrimCoreData.NullableAttribute<Bool>("mine", self) }
    var name: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("name", self) }
    var price: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("price", self) }
    var signature: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("signature", self) }
    var subname: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("subname", self) }
    var torque: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("torque", self) }
    var video: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("video", self) }
    var zeroTo60: AlecrimCoreData.NullableAttribute<String> { return AlecrimCoreData.NullableAttribute<String>("zeroTo60", self) }

}

// MARK: - DataContext extensions

extension DataContext {

    var sportCars: AlecrimCoreData.Table<SportCar> { return AlecrimCoreData.Table<SportCar>(dataContext: self) }

}

