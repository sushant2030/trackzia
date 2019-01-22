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
    @NSManaged var imei: Int64
    
    @NSManaged var accuracy: Float
    @NSManaged var battery: Float
    @NSManaged var charging: Bool
    @NSManaged var complete: Bool
    
    @NSManaged var lat: Double
    @NSManaged var long: Double
    
    @NSManaged var speed: Double
    @NSManaged var timeStamp: Date
    
    @NSManaged var resting: Int
    @NSManaged var running: Int
    @NSManaged var exploring: Int
    
    @NSManaged var year: Int
    @NSManaged var month: Int
    @NSManaged var day: Int
    @NSManaged var secondsFromGMT: Int
    
    static func insert(into context: NSManagedObjectContext, imei: Int64, year: Int, month: Int, day: Int, secondsFromGMT: Int) -> DeviceActionsInfo {
        let actionsInfo:DeviceActionsInfo = context.insertObject()
        actionsInfo.accuracy = 0
        actionsInfo.battery = 0
        actionsInfo.charging = false
        actionsInfo.complete = false
        actionsInfo.exploring = 0
        actionsInfo.lat = 0.0
        actionsInfo.long = 0.0
        actionsInfo.resting = 0
        actionsInfo.running = 0
        actionsInfo.speed = 0.0
        
        actionsInfo.year = year
        actionsInfo.month = month
        actionsInfo.day = day
        actionsInfo.secondsFromGMT = secondsFromGMT
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        actionsInfo.timeStamp = DataPacketDateFormatter.calendar.date(from: components)!
        
        actionsInfo.imei = imei
        return actionsInfo
    }
    
//    static func insert(into context: NSManagedObjectContext, info: DeviceDataRestExploreRuninfo) -> DeviceActionsInfo {
//        let actionsInfo:DeviceActionsInfo = context.insertObject()
//        actionsInfo.accuracy = Float(info.accuracy)
//        actionsInfo.battery = info.battery
//        actionsInfo.charging = info.charging
//        actionsInfo.complete = info.complete
//        actionsInfo.exploring = info.exploring
//        actionsInfo.lat = info.lat
//        actionsInfo.long = info.long
//        actionsInfo.resting = info.resting
//        actionsInfo.running = info.running
//        actionsInfo.speed = info.speed
//        actionsInfo.timeStamp = DataPacketDateFormatter.dateFormatter.date(from: info.timeStamp.split(separator: "T").joined())!
//        return actionsInfo
//    }
    
    func update(info: DeviceDataRestExploreRuninfo) {
        accuracy = Float(info.accuracy)
        battery = info.battery
        charging = info.charging
        complete = info.complete
        
        lat = info.lat
        long = info.long
        
        speed = info.speed
        timeStamp = DataPacketDateFormatter.dateFormatter.date(from: info.timeStamp.split(separator: "T").joined())!
        
        resting += resting + hrminsecStringToSeconds(info.resting)
        running += running + hrminsecStringToSeconds(info.running)
        exploring += exploring + hrminsecStringToSeconds(info.exploring)
    }
    
    func hrminsecStringToSeconds(_ time: String) -> Int {
        let components = time.split(separator: ":")
        let seconds = Int(components[0])! * 60 * 60 + Int(components[1])! * 60 + Int(components[2])!
        return seconds
    }
    
    func secondsToHrminsecString(_ seconds: Int) -> String {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        
        let date = DataPacketDateFormatter.calendar.date(from: components)!
        let newDate = Date(timeInterval: TimeInterval(exactly: seconds)!, since: date)
        let dateFormatter = DateFormatter()//DataPacketDateFormatter.dateFormatter
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.timeZone = DataPacketDateFormatter.timezone
        return dateFormatter.string(from: newDate)
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
    static var defaultSortDescriptors:[NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(timeStamp), ascending: true)]
    }
}
