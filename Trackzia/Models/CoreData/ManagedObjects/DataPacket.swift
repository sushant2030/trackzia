//
//  DataPacket.swift
//  Trackzia
//
//  Created by Rohan Bhale on 01/01/19.
//  Copyright © 2019 Private. All rights reserved.
//

import CoreData

class DataPacket: NSManagedObject {
    @NSManaged var accuracy: Float
    @NSManaged var battery: Float
    @NSManaged var charging: Bool
    @NSManaged var lat: Double
    @NSManaged var long: Double
    @NSManaged var panic: Bool
    @NSManaged var speed: Double
    @NSManaged var timeStamp: Date
    
    @NSManaged var device: Device
    
    static func insert(into context: NSManagedObjectContext, packet: DeviceDataViewInfoPacket) -> DataPacket {
        let dataPacket: DataPacket = context.insertObject()
        dataPacket.accuracy = Float(packet.accuracy)
        dataPacket.battery = packet.battery
        dataPacket.charging = packet.charging
        dataPacket.lat = packet.lat
        dataPacket.long = packet.long
        dataPacket.panic = packet.panic == 0 ? false : true
        dataPacket.speed = packet.speed
        dataPacket.timeStamp = DataPacketDateFormatter.dateFormatter.date(from: packet.timeStamp.split(separator: "T").joined())!
        return dataPacket
    }
}

extension DataPacket: Managed {
    
}

class DataPacketDateFormatter {
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        print("Seconds from GMT: \(formatter.timeZone.secondsFromGMT())")//19800 seconds for 05:30
        //"2019-01-06T15:45:18"
        formatter.dateFormat = "yyyy-MM-ddHH:mm:ss"
        return formatter
    }()
}
