//
//  Schedule+CoreDataProperties.swift
//  My Scheduler
//
//  Created by William Chrisandy on 27/04/22.
//
//

import Foundation
import CoreData


extension Schedule
{

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Schedule>
    {
        let fetchRequest = NSFetchRequest<Schedule>(entityName: "Schedule")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        return fetchRequest
    }
    
    @nonobjc public class func fetchRequest(since: Date) -> NSFetchRequest<Schedule>
    {
        let fetchRequest = NSFetchRequest<Schedule>(entityName: "Schedule")
        fetchRequest.predicate = NSPredicate(format: "startTime >= %@", since as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: true)]
        return fetchRequest
    }

    @NSManaged public var startTime: Date?
    @NSManaged public var endTime: Date?
    @NSManaged public var note: String?
    @NSManaged public var id: Int32
    @NSManaged public var has: Activity?

}

extension Schedule : Identifiable
{

}
