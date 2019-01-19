//
//  DeviceActionsInfo.swift
//  Trackzia
//
//  Created by Rohan Bhale on 11/01/19.
//  Copyright © 2019 Private. All rights reserved.
//

import CoreData

/*
 "DeviceDataRestExploreRuninfo": {
 "Exploring": "00:08:36",
 "Resting": "06:05:36",
 "Running": "02:00:11",
 "Time_stamp": "2019-01-06T23:59:41",
 "Lat": 22.770528,
 "Lng": 72.850683,
 "Battery": 78.5714,
 "Speed": 41.74,
 "Charging": false,
 "Complete": true,
 "Accuracy": 2.5
 }
 */

class DeviceActionsInfo: NSManagedObject {
    @NSManaged var accuracy: Float
    @NSManaged var battery: Float
    @NSManaged var charging: Bool
    @NSManaged var complete: Bool
    @NSManaged var exploring: String
    @NSManaged var lat: Double
    @NSManaged var long: Double
    @NSManaged var resting: String
    @NSManaged var running: String
    @NSManaged var speed: Double
    @NSManaged var timeStamp: Date
    
    @NSManaged var device: Device
    
    static func insert(into context: NSManagedObjectContext) -> DeviceActionsInfo {
        let actionsInfo:DeviceActionsInfo = context.insertObject()
        actionsInfo.accuracy = 0
        actionsInfo.battery = 0
        actionsInfo.charging = false
        actionsInfo.complete = false
        actionsInfo.exploring = "00:00:00"
        actionsInfo.lat = 0.0
        actionsInfo.long = 0.0
        actionsInfo.resting = "00:00:00"
        actionsInfo.running = "00:00:00"
        actionsInfo.speed = 0.0
        
        let calendar = DataPacketDateFormatter.calendar
        var components = DateComponents()
        //"0001-01-01T00:00:00"
        components.year = 0001
        components.month = 01
        components.day = 01
        components.hour = 00
        components.minute = 00
        components.second = 00
        actionsInfo.timeStamp = calendar.date(from: components)!
        return actionsInfo
    }
    
    static func insert(into context: NSManagedObjectContext, info: DeviceDataRestExploreRuninfo) -> DeviceActionsInfo {
        let actionsInfo:DeviceActionsInfo = context.insertObject()
        actionsInfo.accuracy = Float(info.accuracy)
        actionsInfo.battery = info.battery
        actionsInfo.charging = info.charging
        actionsInfo.complete = info.complete
        actionsInfo.exploring = info.exploring
        actionsInfo.lat = info.lat
        actionsInfo.long = info.long
        actionsInfo.resting = info.resting
        actionsInfo.running = info.running
        actionsInfo.speed = info.speed
        actionsInfo.timeStamp = DataPacketDateFormatter.dateFormatter.date(from: info.timeStamp.split(separator: "T").joined())!
        return actionsInfo
    }
    
    func update(info: DeviceDataRestExploreRuninfo) {
        accuracy = Float(info.accuracy)
        battery = info.battery
        charging = info.charging
        complete = info.complete
        
        lat = info.lat
        long = info.long
        
        speed = info.speed
        if info.timeStamp != "0001-01-01T00:00:00" {
            let infoTimeStampString = info.timeStamp.components(separatedBy: "T").joined()
            let infoTimeStampDate = DataPacketDateFormatter.dateFormatter.date(from: infoTimeStampString)!
            
            let calendarComponents: Set<Calendar.Component> = [.year, .month, .day]
            let infoTimeStampDateComponents = DataPacketDateFormatter.calendar.dateComponents(calendarComponents, from: infoTimeStampDate)
            
            let storedtimeStampDateComponents = DataPacketDateFormatter.calendar.dateComponents(calendarComponents, from: timeStamp)
            
            if infoTimeStampDateComponents == storedtimeStampDateComponents {
                //Add to existing time
                let formatter = DateFormatter()
                formatter.timeZone = DataPacketDateFormatter.dateFormatter.timeZone
                formatter.calendar = DataPacketDateFormatter.calendar
                formatter.dateFormat = "HH:mm:ss"
                
                var storedDatecomponents = storedtimeStampDateComponents
                storedDatecomponents.hour = Int(exploring.components(separatedBy: ":")[0])!
                storedDatecomponents.minute = Int(exploring.components(separatedBy: ":")[1])!
                storedDatecomponents.second = Int(exploring.components(separatedBy: ":")[2])!
                
                exploring = hourMinsSecs(baseTimeString: exploring, timeStringToAdd: info.exploring, formatter: formatter, baseDateComponents: storedDatecomponents)
                resting = hourMinsSecs(baseTimeString: resting, timeStringToAdd: info.resting, formatter: formatter, baseDateComponents: storedDatecomponents)
                running = hourMinsSecs(baseTimeString: running, timeStringToAdd: info.running, formatter: formatter, baseDateComponents: storedDatecomponents)
            } else {
                //Update existing time
                exploring = info.exploring
                resting = info.resting
                running = info.running
            }
            
            timeStamp = DataPacketDateFormatter.dateFormatter.date(from: info.timeStamp.split(separator: "T").joined())!
        }
    }
    
    func hourMinsSecs(baseTimeString: String, timeStringToAdd: String,formatter: DateFormatter, baseDateComponents: DateComponents) -> String {
        var storedDatecomponents = baseDateComponents
        storedDatecomponents.hour = Int(baseTimeString.components(separatedBy: ":")[0])!
        storedDatecomponents.minute = Int(baseTimeString.components(separatedBy: ":")[1])!
        storedDatecomponents.second = Int(baseTimeString.components(separatedBy: ":")[2])!
        let storedDate = DataPacketDateFormatter.calendar.date(from: storedDatecomponents)!
        
        let addHour = Int(timeStringToAdd.components(separatedBy: ":")[0])!
        let addMinute = Int(timeStringToAdd.components(separatedBy: ":")[1])!
        let addSecond = Int(timeStringToAdd.components(separatedBy: ":")[2])!
        let addTotalSeconds = addHour * 60 * 60 + addMinute * 60 +  addSecond
        
        let dateByAddingTotalSeconds = storedDate.addingTimeInterval(TimeInterval(addTotalSeconds))
        
        return formatter.string(from: dateByAddingTotalSeconds)
    }
}

extension DeviceActionsInfo: Managed {
    
}
