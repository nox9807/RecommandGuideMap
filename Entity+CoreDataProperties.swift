//
//  Entity+CoreDataProperties.swift
//  RecommandGuideMap
//
//  Created by chaeyoonpark on 11/7/25.
//
//

public import Foundation
public import CoreData


public typealias EntityCoreDataPropertiesSet = NSSet

extension Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Entity")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var category: String?
    @NSManaged public var address: String?
    @NSManaged public var lat: Double
    @NSManaged public var lng: Double
    @NSManaged public var imggeURL: String?
    @NSManaged public var careatedAt: Date?

}

extension Entity : Identifiable {

}
