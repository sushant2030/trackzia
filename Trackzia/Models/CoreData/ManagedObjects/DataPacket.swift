//
//  DataPacket.swift
//  Trackzia
//
//  Created by Rohan Bhale on 01/01/19.
//  Copyright © 2019 Private. All rights reserved.
//

import CoreData

class DataPacket: NSManagedObject {
    @NSManaged var battery: Float
    @NSManaged var lat: Double
    @NSManaged var long: Double
    @NSManaged var panic: Bool
    @NSManaged var speed: Double
    @NSManaged var timeStamp: Double
    
    @NSManaged var device: Device
}

extension DataPacket: Managed {
    
}
