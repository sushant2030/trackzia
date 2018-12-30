//
//  ActiveProfile.swift
//  Trackzia
//
//  Created by Rohan Bhale on 29/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import CoreData

class ActiveProfile: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var profileType: String
    
    @NSManaged var device: Device
    
    static func insert(into context: NSManagedObjectContext, name: String, profileType: String) -> ActiveProfile {
        let activeProfile:ActiveProfile = context.insertObject()
        activeProfile.name = name
        activeProfile.profileType = profileType
        return activeProfile
    }
}

extension ActiveProfile: Managed {
    
}
