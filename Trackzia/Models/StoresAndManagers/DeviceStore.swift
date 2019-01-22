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
    var imeiSelectionManagerListenerToken: IMEISelectionManagerListenerToken!
    
    var detailsFetchingInProgress = Set<IMEI>()
    var dataPacketsFetchingInProgress = Set<IMEI>()
    
    private init() {
        imeiSelectionManagerListenerToken = IMEISelectionManager.shared.addListener(imeiSelectionManagerListener)
    }
    
    var devices: [Device] = []
    
    func refreshDeviceList(from context: NSManagedObjectContext) {
        self.devices.removeAll()
        guard let accountDevices = UserDataStore.shared.account?.devices else { return }
        self.devices.append(contentsOf: accountDevices)
    }
    
    func getDeviceDetails(imei: IMEI) {
        CommunicationManager.getCommunicator().performOpertaion(with: GetDeviceDetailsService(imeiNumber: imei, listener: self))
    }
    
    func imeiSelectionManagerListener() {
        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
        if device.activationDate == nil {
            guard !detailsFetchingInProgress.contains(device.imei) else { return }
            detailsFetchingInProgress.insert(device.imei)
            getDeviceDetails(imei: device.imei)
        }
    }
    
    func getAccntWiseIMEI(accntId: String) {
        CommunicationManager.getCommunicator().performOpertaion(with: GetAccountWiseIMEIService(accountId: accntId, listener: self))
    }
    
    func insertDevices(in context: NSManagedObjectContext, for imeiList: [IMEI]) {
        context.performChanges {
            UserDataStore.shared.account?.devices?.forEach{ context.delete($0) }
            UserDataStore.shared.account?.devices = []
            for (index, imei) in imeiList.enumerated() {
                let device = Device.insert(into: context, imei: imei)
                device.order = Int16(index)
                UserDataStore.shared.account?.devices?.insert(device)
            }
        }
    }
}

extension DeviceStore: CommunicationResultListener {
    func onSuccess(operationId: Int, operation: CommunicationOperationResult) {
        if let result = operation as? GetAccountWiseIMEIServiceResult, result.success {
            if let data = result.data {
                let imeiList = data.keys.sorted().map{ Int64(data[$0]!)! }
                insertDevices(in: context, for: imeiList)
                
                DispatchQueue.main.async {
                    DeviceStore.shared.refreshDeviceList(from: self.context)
                    PostLoginRouter.showHomeView()
                }
            }
        }
        
        if let wrapper = operation as? GetDeviceDetailsServiceResultWrapper {
            if wrapper.result.success {
                detailsFetchingInProgress.remove(wrapper.imei)
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
