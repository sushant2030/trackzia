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
        if let device = IMEISelectionManager.shared.selectedDevice {
            if device.activationDate == nil {
                guard !detailsFetchingInProgress.contains(device.imei) else { return }
                detailsFetchingInProgress.insert(device.imei)
                getDeviceDetails(imei: device.imei)
            }
        }
    }
    
//    func getDeviceDataPackets(device: Device) {
//        guard let activationDate = device.activationDate else { return } //"2018-12-08T09:54:54"
//        let charSet = CharacterSet(charactersIn: "-T:")
//        let components = activationDate.components(separatedBy: charSet)
//        let processedDateString = components.joined(separator: "")
//        let date = DataPacketDateFormatter.dateFormatter.date(from: "2019-01-1700:00:00")!
//        let stringDate = DataPacketDateFormatter.dateFormatter.string(from: date).components(separatedBy: "-").joined().components(separatedBy: ":").joined()
//        CommunicationManager.getCommunicator().performOpertaion(with: GetDataPacketsService(imei: device.imei, timeStamp: stringDate, listener: self))
//    }
    
//    func updateDeviceDataPackets(imei: IMEI) {
//        if let device = IMEISelectionManager.shared.selectedDevice {
//            if device.imei == imei {
//                guard !dataPacketsFetchingInProgress.contains(device.imei) else { return }
//                dataPacketsFetchingInProgress.insert(device.imei)
//                getDeviceDataPackets(device: device)
//            }
//        }
//    }
}

extension DeviceStore: CommunicationResultListener {
    func onSuccess(operationId: Int, operation: CommunicationOperationResult) {
        if let wrapper = operation as? GetDeviceDetailsServiceResultWrapper {
            if wrapper.result.success {
                detailsFetchingInProgress.remove(wrapper.imei)
                guard let device = UserDataStore.shared.account?.devices?.filter({ $0.imei == wrapper.imei }).first else { return }
                context.performChanges {
                    device.simcard = wrapper.result.data.simNumber
                    device.simOperator = wrapper.result.data.simOperator
                    device.activationDate = wrapper.result.data.activationDate
                    device.actionsInfo.timeStamp = DataPacketDateFormatter.dateFormatter.date(from: wrapper.result.data.activationDate.split(separator: "T").joined())!
                }
            }
        }
        
        if let wrapper = operation as? GetDataPacketsServiceResponseWrapper {
            guard let device = UserDataStore.shared.account?.devices?.filter({ $0.imei == wrapper.imei }).first else { return }
            context.performChanges {
                wrapper.response.deviceDataViewinfo.forEach { (packet) in
                    let dataPacket = DataPacket.insert(into: self.context, packet: packet)
                    dataPacket.device = device
                }
                
                device.actionsInfo.update(info: wrapper.response.deviceDataRestExploreRuninfo)

            }
        }
    }
    
    func onFailure(operationId: Int, error: Error, data: Data?) {
        print(error)
    }
}
