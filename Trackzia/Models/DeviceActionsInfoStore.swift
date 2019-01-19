//
//  DeviceActionsInfoStore.swift
//  Trackzia
//
//  Created by Rohan Bhale on 18/01/19.
//  Copyright © 2019 Private. All rights reserved.
//

import ApiManager
import CoreData

class DeviceActionsInfoStore {
    static var shared = DeviceActionsInfoStore()
    var context: NSManagedObjectContext!
    var imeiSelectionManagerListenerToken: IMEISelectionManagerListenerToken!
    
    var fetchInProgress = Set<IMEI>()
    var alreadyFetched = Set<IMEI>()
    
    private init() {
        imeiSelectionManagerListenerToken = IMEISelectionManager.shared.addListener(imeiSelectionManagerListener)
    }
    
    func imeiSelectionManagerListener() {
        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
        guard !alreadyFetched.contains(device.imei) else { return }
        guard !fetchInProgress.contains(device.imei) else { return }
        let currentDate = Date()
        let calendar = DataPacketDateFormatter.calendar
        var currentDateComponents = calendar.dateComponents(DataPacketDateFormatter.calendarComponents, from: currentDate)
        
        let timeStamp = device.actionsInfo.timeStamp
        let timeStampComponents = calendar.dateComponents(DataPacketDateFormatter.calendarComponents, from: timeStamp)
        
        let componentsToUse: DateComponents
        
        if timeStampComponents.year == 1  && timeStampComponents.month == 1 && timeStampComponents.day == 1 && timeStampComponents.hour == 0 && timeStampComponents.minute == 0 && timeStampComponents.second == 0 {
            currentDateComponents.hour = 0
            currentDateComponents.minute = 0
            currentDateComponents.second = 0
            
            componentsToUse = currentDateComponents
        } else {
            if timeStampComponents.year == currentDateComponents.year && timeStampComponents.month == currentDateComponents.month && timeStampComponents.day == currentDateComponents.day {
                // We have the packet update date as today so we need packets after that time stamp now
                componentsToUse = timeStampComponents
            } else {
                //We have packets from any other day before today, so we need to load data from time 00:00:00 today
                currentDateComponents.hour = 0
                currentDateComponents.minute = 0
                currentDateComponents.second = 0
                
                componentsToUse = currentDateComponents
            }
        }
        
        let dateToUse = calendar.date(from: componentsToUse)!
        let timeStampToUse = DataPacketDateFormatter.dateFormatter.string(from: dateToUse).components(separatedBy: "-").joined().components(separatedBy: ":").joined()
        fetchInProgress.insert(device.imei)
        getDeviceDataPackets(device: device, timeStampString: timeStampToUse)
    }
    
    func getDeviceDataPackets(device: Device, timeStampString: String) {
        CommunicationManager.getCommunicator().performOpertaion(with: GetDataPacketsService(imei: device.imei, timeStamp: timeStampString, listener: self))
    }
}

extension DeviceActionsInfoStore: CommunicationResultListener {
    func onSuccess(operationId: Int, operation: CommunicationOperationResult) {
        if let wrapper = operation as? GetDataPacketsServiceResponseWrapper {
            fetchInProgress.remove(wrapper.imei)
            guard let device = UserDataStore.shared.account?.devices?.filter({ $0.imei == wrapper.imei }).first else { return }
            alreadyFetched.insert(wrapper.imei)
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
