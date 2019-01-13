//
//  Device.swift
//  Trackzia
//
//  Created by Rohan Bhale on 28/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import CoreData

class Device: NSManagedObject {
    @NSManaged var order: Int16
    @NSManaged var deviceId: String?
    @NSManaged var imei: Int64
    @NSManaged var simcard: String?
    @NSManaged var simOperator: String?
    @NSManaged var sync: String?
    @NSManaged var updatedAt: Date
    @NSManaged var activationDate: String?
    
    @NSManaged var account: Account
    @NSManaged var profiles: Set<Profile>?
    @NSManaged var activeProfile: ActiveProfile?
    @NSManaged var geoFences: Set<GeoFence>?
    @NSManaged var dataPackets: Set<DataPacket>?
    @NSManaged var actionsInfo: DeviceActionsInfo
    
    static func insert(into context: NSManagedObjectContext, imei: IMEI) -> Device {
        let device: Device = context.insertObject()
        device.imei = imei
        device.updatedAt = Date()
        return device
    }
}

extension Device: Managed {
    
}
