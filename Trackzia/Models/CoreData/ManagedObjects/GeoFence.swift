//
//  GeoFence.swift
//  Trackzia
//
//  Created by Rohan Bhale on 30/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import CoreData

enum GeoFenceType: String {
    case home = "GeoHome"
    case school = "GeoSchool"
    case playGround = "GeoPlayGroud"
    case other = "GeoOther"
    case lock = "GeoLock"
}

class GeoFence: NSManagedObject {
    @NSManaged var lat: String
    @NSManaged var long: String
    @NSManaged var type: String
    @NSManaged var name: String
    @NSManaged var radius: String
    @NSManaged var startTime: String?
    @NSManaged var endTime: String?
    @NSManaged var sync: String?
    @NSManaged var updatedAt: Date
    @NSManaged var geoEndTime: String?
    
    @NSManaged var device: Device
    
    static func insert(into context: NSManagedObjectContext, geoFenceData: GetGeoFenceDetailsServiceResult.GeoFenceData) -> GeoFence {
        let geoFence: GeoFence = context.insertObject()
        geoFence.lat = geoFenceData.lat
        geoFence.long = geoFenceData.long
        geoFence.type = geoFenceData.type
        geoFence.name = geoFenceData.name
        geoFence.radius = geoFenceData.radius
        geoFence.startTime = geoFenceData.startTime
        geoFence.endTime = geoFenceData.endTime
        geoFence.geoEndTime = geoFenceData.geoEndTime
        geoFence.updatedAt = Date()
        return geoFence
    }
    
    static func insert(into context: NSManagedObjectContext, createUpdateModel: GeoFenceCreateUpdateModel) -> GeoFence {
        let geoFence: GeoFence = context.insertObject()
        geoFence.lat = String(createUpdateModel.lat)
        geoFence.long = String(createUpdateModel.long)
        geoFence.type = createUpdateModel.type
        geoFence.name = createUpdateModel.name
        geoFence.radius = String(createUpdateModel.radius)
        geoFence.startTime = createUpdateModel.startTime
        geoFence.endTime = createUpdateModel.endTime
        
        geoFence.updatedAt = Date()
        return geoFence
    }
}

extension GeoFence: Managed {
    
}
