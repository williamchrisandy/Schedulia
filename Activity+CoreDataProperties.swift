//
//  Activity+CoreDataProperties.swift
//  My Scheduler
//
//  Created by William Chrisandy on 27/04/22.
//
//

import Foundation
import CoreData

extension Activity
{

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Activity>
    {
        let fetchRequest = NSFetchRequest<Activity>(entityName: "Activity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return fetchRequest
    }
    
    @nonobjc public class func fetchRequest(name: String) -> NSFetchRequest<Activity>
    {
        let fetchRequest = NSFetchRequest<Activity>(entityName: "Activity")
        fetchRequest.predicate = NSPredicate(format: "name like [c] %@", "\(name)")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return fetchRequest
    }
    
    @nonobjc public class func fetchRequest(contains: String) -> NSFetchRequest<Activity>
    {
        let fetchRequest = NSFetchRequest<Activity>(entityName: "Activity")
        fetchRequest.predicate = NSPredicate(format: "name like [c] %@", "*\(contains)*")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return fetchRequest
    }
    
    @NSManaged public var name: String?
    @NSManaged public var id: Int32
    @NSManaged public var isPartOf: NSSet?
    @NSManaged public var includedIn: NSSet?

}

// MARK: Generated accessors for isPartOf
extension Activity
{

    @objc(addIsPartOfObject:)
    @NSManaged public func addToIsPartOf(_ value: Category)

    @objc(removeIsPartOfObject:)
    @NSManaged public func removeFromIsPartOf(_ value: Category)

    @objc(addIsPartOf:)
    @NSManaged public func addToIsPartOf(_ values: NSSet)

    @objc(removeIsPartOf:)
    @NSManaged public func removeFromIsPartOf(_ values: NSSet)

}

// MARK: Generated accessors for includedIn
extension Activity
{

    @objc(addIncludedInObject:)
    @NSManaged public func addToIncludedIn(_ value: Schedule)

    @objc(removeIncludedInObject:)
    @NSManaged public func removeFromIncludedIn(_ value: Schedule)

    @objc(addIncludedIn:)
    @NSManaged public func addToIncludedIn(_ values: NSSet)

    @objc(removeIncludedIn:)
    @NSManaged public func removeFromIncludedIn(_ values: NSSet)

}

extension Activity : Identifiable
{

}
