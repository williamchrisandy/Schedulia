//
//  Category+CoreDataProperties.swift
//  My Scheduler
//
//  Created by William Chrisandy on 27/04/22.
//
//

import Foundation
import CoreData


extension Category
{
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category>
    {
        let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return fetchRequest
    }
    
    @nonobjc public class func fetchRequest(name: String) -> NSFetchRequest<Category>
    {
        let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
        fetchRequest.predicate = NSPredicate(format: "name like [c] %@", "\(name)")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return fetchRequest
    }
    
    @nonobjc public class func fetchRequest(contains: String) -> NSFetchRequest<Category>
    {
        let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
        fetchRequest.predicate = NSPredicate(format: "name like [c] %@", "*\(contains)*")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return fetchRequest
    }

    @NSManaged public var name: String?
    @NSManaged public var id: Int16
    @NSManaged public var has: NSSet?

}

// MARK: Generated accessors for has
extension Category
{

    @objc(addHasObject:)
    @NSManaged public func addToHas(_ value: Activity)

    @objc(removeHasObject:)
    @NSManaged public func removeFromHas(_ value: Activity)

    @objc(addHas:)
    @NSManaged public func addToHas(_ values: NSSet)

    @objc(removeHas:)
    @NSManaged public func removeFromHas(_ values: NSSet)

}

extension Category : Identifiable
{

}
