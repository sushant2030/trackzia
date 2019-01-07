//
//  AccntWiseIMEIListStore.swift
//  Trackzia
//
//  Created by Rohan Bhale on 29/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import CoreData
import ApiManager

class DeviceStore {
    static var shared = DeviceStore()
    var context: NSManagedObjectContext!
    
    private init() {}
    
    var devices: [Device] = []
    
    func refreshDeviceList(from context: NSManagedObjectContext) {
        self.devices.removeAll()
        guard let accountDevices = UserDataStore.shared.account?.devices else { return }
        self.devices.append(contentsOf: accountDevices)
    }
}

extension DeviceStore: CommunicationResultListener {
    func onSuccess(operationId: Int, operation: CommunicationOperationResult) {
        if let wrapper = operation as? GetDeviceDetailsServiceResultWrapper {
            if wrapper.result.success {
                guard let device = UserDataStore.shared.account?.devices?.filter({ $0.imei == wrapper.imei }).first else { return }
                context.performChanges {
                    device.simcard = wrapper.result.data.simNumber
                    device.simOperator = wrapper.result.data.simOperator
                    device.activationDate = wrapper.result.data.activationDate
                }
                
            }
        }
    }
    
    func onFailure(operationId: Int, error: Error, data: Data?) {
        print(error)
    }
}
