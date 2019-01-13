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
        actionsInfo.timeStamp = Date()
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
        exploring = info.exploring
        lat = info.lat
        long = info.long
        resting = info.resting
        running = info.running
        speed = info.speed
        if info.timeStamp != "0001-01-01T00:00:00" {
            timeStamp = DataPacketDateFormatter.dateFormatter.date(from: info.timeStamp.split(separator: "T").joined())!
        }
    }
}

extension DeviceActionsInfo: Managed {
    
}
