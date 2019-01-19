//
//  GeofenceStore.swift
//  Trackzia
//
//  Created by Rohan Bhale on 19/01/19.
//  Copyright © 2019 Private. All rights reserved.
//

import Foundation

import ApiManager
import CoreData

class GeofenceStore {
    static var shared = GeofenceStore()
    
    var fetchInProgress = Set<IMEI>()
    var alreadyFetched = Set<IMEI>()
    var imeiSelectionManagerListenerToken: IMEISelectionManagerListenerToken!
    var listeners: [String: (IMEI) -> Void] = [:]
    var context: NSManagedObjectContext!
    
    private init() {
        imeiSelectionManagerListenerToken = IMEISelectionManager.shared.addListener(imeiSelectionManagerListener)
    }
    
    func imeiSelectionManagerListener() {
        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
        guard !alreadyFetched.contains(device.imei) else {
            listeners.forEach({ $1(device.imei) })
            return
        }
        guard !fetchInProgress.contains(device.imei) else { return }
        getGeofence(for: device)
    }
    
    func getGeofence(for device: Device) {
        fetchInProgress.insert(device.imei)
        UserDataManager.shared.getGeoFenceDetails(imei: device.imei) { (imei) in
            self.fetchInProgress.remove(imei)
            self.alreadyFetched.insert(imei)
            self.listeners.forEach({ $1(imei) })
        }
    }
    
    func addListener(for imei: IMEI, listener: @escaping (IMEI) -> Void) -> GeofenceStoreListenerToken {
        let token = GeofenceStoreListenerToken()
        listeners[token.uuidString] = listener
        if alreadyFetched.contains(imei) {
            listener(imei)
        }
        return token
    }
    
    func removeListener(_ token: GeofenceStoreListenerToken) {
        listeners[token.uuidString] = nil
    }
}

class GeofenceStoreListenerToken {
    let uuidString = UUID().uuidString
}
