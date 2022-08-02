//
//  StaticFunction.swift
//  Schedulia
//
//  Created by William Chrisandy on 27/04/22.
//

import UIKit

class StaticFunction
{
    static func prepareWarning(warningMessage:String) -> UIAlertController
    {
        let alert = UIAlertController(title: "Warning", message: warningMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        return alert
    }
    
    static func trimAndLowercaseString(string: String) ->String
    {
        return string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    static func dateToNameOfDay(_ date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd MMMM yyyy"
        return dateFormatter.string(from:date)
    }
    
    static func dateToTimeString(_ date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH.mm"
        return dateFormatter.string(from:date)
    }
    
    static func getStartOfDate(_ date: Date) -> Date
    {
        let calendar = Calendar.current
        return calendar.startOfDay(for: date)
    }
    
    static func createDurationString(_ duration: Int) -> String
    {
        let hour = duration/3600
        let minute = (duration/60) % 60
        var durationString = ""
        if(hour > 0)
        {
            durationString += "\(hour)h "
        }
        if(minute > 0)
        {
            durationString += "\(minute)m"
        }
        
        return durationString == "" ? "-" : durationString
    }
    
    static func getMinuteDifferences(startDate: Date, endDate: Date) -> Int
    {
        return Int(endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970) + 1
    }
}
