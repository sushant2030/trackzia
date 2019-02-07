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
    
    var geoFenceDetailsCompletionHandler: ((IMEI) -> Void)?
    
    typealias UpdateGeoFenceCompletionHandler = ((IMEI, String, Error?) -> Void)
    var updateGeoFenceCompletionHandler: UpdateGeoFenceCompletionHandler?
    
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
        fetchInProgress.insert(device.imei)
        getGeofence(for: device)
    }
    
    func getGeofence(for device: Device) {
        
        getGeoFenceDetails(imei: device.imei) { (imei) in
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
    
    func getGeoFenceDetails(imei: IMEI, completionHandlder: @escaping (IMEI) -> Void) {
        geoFenceDetailsCompletionHandler = completionHandlder
        CommunicationManager.getCommunicator().performOpertaion(with: GetGeoFenceDetailsService(imei: imei, listener: self))
    }
    
    func updateGeoFence(_ geoFenceCreateUpdateModel: GeoFenceCreateUpdateModel, completionHandler: @escaping UpdateGeoFenceCompletionHandler) {
        updateGeoFenceCompletionHandler = completionHandler
        CommunicationManager.getCommunicator().performOpertaion(with: CreateUpdateGeofence(createUpdateModel: geoFenceCreateUpdateModel, listener: self))
    }
}

class GeofenceStoreListenerToken {
    let uuidString = UUID().uuidString
}

extension GeofenceStore: CommunicationResultListener {
    func onSuccess(operationId: Int, operation: CommunicationOperationResult) {
        if let wrapper = operation as? GetGeoFenceDetailsServiceResultWrapper {
            fetchInProgress.remove(wrapper.imei)
            if wrapper.result.success {
                guard let device = UserDataStore.shared.account?.devices?.filter({ $0.imei == wrapper.imei }).first else { return }
                self.alreadyFetched.insert(device.imei)
                context.performChanges {
                    device.geoFences?.forEach({ self.context.delete($0) })
                    device.geoFences = []
                    for geoFenceData in wrapper.result.data {
                        let geoFence = GeoFence.insert(into: self.context, geoFenceData: geoFenceData)
                        device.geoFences?.insert(geoFence)
                    }
                }
                
                DispatchQueue.main.async {
                    self.geoFenceDetailsCompletionHandler?(device.imei)
                    self.geoFenceDetailsCompletionHandler = nil
                }
            }
        }
        
        if let wrapper = operation as? CreateUpdateGeofenceResponseWrapper {
            if wrapper.response.success {
                guard let device = UserDataStore.shared.account?.devices?.filter({ $0.imei == wrapper.createUpdateModel.imei }).first else { return }
                if let geoFence = device.geoFences?.filter({ $0.type == wrapper.createUpdateModel.type }).first {
                    context.performChanges {
                        geoFence.name = wrapper.createUpdateModel.name
                        geoFence.lat = String(wrapper.createUpdateModel.lat)
                        geoFence.long = String(wrapper.createUpdateModel.long)
                        geoFence.radius = String(wrapper.createUpdateModel.radius)
                        geoFence.startTime = wrapper.createUpdateModel.startTime
                        geoFence.endTime = wrapper.createUpdateModel.endTime
                    }
                } else {
                    if device.geoFences == nil {
                        device.geoFences = []
                    }
                    context.performChanges {
                        let geofence = GeoFence.insert(into: self.context, createUpdateModel: wrapper.createUpdateModel)
                        device.geoFences?.insert(geofence)
                    }
                }
                DispatchQueue.main.async {
                    self.updateGeoFenceCompletionHandler?(device.imei, wrapper.createUpdateModel.type, nil)
                    self.updateGeoFenceCompletionHandler = nil
                }
            }
        }
    }
    
    func onFailure(operationId: Int, error: Error, data: Data?) {
        print(error)
    }
    
}
