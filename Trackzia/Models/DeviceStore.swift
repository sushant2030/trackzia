//
//  AccntWiseIMEIListStore.swift
//  Trackzia
//
//  Created by Rohan Bhale on 29/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import CoreData

class DeviceStore {
    static var shared = DeviceStore()
    
    private init() {}
    
    var devices: [Device] = []
    
    func refreshDeviceList(from context: NSManagedObjectContext) {
        self.devices.removeAll()
        guard let accountDevices = UserDataStore.shared.account?.devices else { return }
        self.devices.append(contentsOf: accountDevices)
    }
}
