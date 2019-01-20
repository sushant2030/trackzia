//
//  DeviceActionsInfoStore.swift
//  Trackzia
//
//  Created by Rohan Bhale on 18/01/19.
//  Copyright © 2019 Private. All rights reserved.
//

import ApiManager
import CoreData

typealias DataPacketTuple = (device: Device, allPackets: [DataPacket], moreUpdatesToCome: Bool)
typealias GetDataPacketCompletionHandler = (DataPacketTuple) -> ()

class DeviceActionsInfoStore {
    static var shared = DeviceActionsInfoStore()
    var context: NSManagedObjectContext!
    var imeiSelectionManagerListenerToken: IMEISelectionManagerListenerToken!
    
    var fetchInProgress = Set<IMEI>()
    var alreadyFetched = Set<IMEI>()
    
    let webServiceExpectedDateFormatter: DateFormatter
    
    private init() {
        webServiceExpectedDateFormatter = DateFormatter()
        webServiceExpectedDateFormatter.timeZone = TimeZone.current
        webServiceExpectedDateFormatter.dateFormat = "yyyyMMddHHmmss"
        imeiSelectionManagerListenerToken = IMEISelectionManager.shared.addListener(imeiSelectionManagerListener)
    }
    
    func forceUpdateIfAlreadyFetched() {
        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
        guard !fetchInProgress.contains(device.imei) else { return }
        
        updateTodayActionInfo(for: device)
    }
    
    func imeiSelectionManagerListener() {
        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
        guard !alreadyFetched.contains(device.imei) else { return }
        guard !fetchInProgress.contains(device.imei) else { return }
        
        updateTodayActionInfo(for: device)
    }
    
    func setComponents(components: DateComponents, hour: Int, minute: Int, second: Int) -> DateComponents {
        var newComponents = components
        newComponents.hour = hour
        newComponents.minute = minute
        newComponents.second = second
        return newComponents
    }
    
    func getDeviceDataPackets(device: Device, timeStampString: String) {
        CommunicationManager.getCommunicator().performOpertaion(with: GetDataPacketsService(imei: device.imei, timeStamp: timeStampString, listener: self))
    }
}

extension DeviceActionsInfoStore {
    func updateTodayActionInfo(for device: Device) {
        guard let actionInfo = IMEISelectionManager.shared.selectedDevice?.actionsInfo else { return }
        
        let calendar = DataPacketDateFormatter.calendar
        let yearMonthDay: Set<Calendar.Component> = [.year, .month, .day]
        
        let today = Date()
        let todayDateComponents = calendar.dateComponents(yearMonthDay, from: today)
        
        let actionInfoTimeStamp = actionInfo.timeStamp
        let actionInfoTimeStampDateComponents = calendar.dateComponents(yearMonthDay, from: actionInfoTimeStamp)
        
        if todayDateComponents == actionInfoTimeStampDateComponents {
            // actionInfo of the device was updated today
            // So we check if complete is true or not
            // If its is true we dont call the webservice as there are no more packets.
            // If it is false we call the webservice with the timeStamp of the actionInfo
            if actionInfo.complete == false {
                // Call Webservice with actionInfo timeStamp
                let timeStampString = webServiceExpectedDateFormatter.string(from: actionInfo.timeStamp)
                getDeviceDataPackets(device: device, timeStampString: timeStampString)
            } else {
                alreadyFetched.insert(device.imei)
            }
        } else {
            // actionInfo was last updated previous to today, so we want to fetch it for today now
            // Call Webservice with timestamp as today and time as 00:00:00
            var dateComponents = todayDateComponents
            dateComponents.hour = 0
            dateComponents.minute = 0
            dateComponents.second = 0
            let date = calendar.date(from: dateComponents)!
            let timeStampString = webServiceExpectedDateFormatter.string(from: date)
            getDeviceDataPackets(device: device, timeStampString: timeStampString)
        }
    }
}

extension DeviceActionsInfoStore {
    func getPackets(for device: Device, for forDate: Date, fetchMorePacketsFromServerIfRequired: Bool = true, completionHandler: GetDataPacketCompletionHandler? = nil) {
        let yearMonthDayHourMinSecComp: Set<Calendar.Component> = [.year, .month, .day]
        let forDateComponents = DataPacketDateFormatter.calendar.dateComponents(yearMonthDayHourMinSecComp, from: forDate)
        
        var startOfDayDateComponents = forDateComponents
        startOfDayDateComponents.hour = 0
        startOfDayDateComponents.minute = 0
        startOfDayDateComponents.second = 0
        
        var endOfDayDateComponents = forDateComponents
        endOfDayDateComponents.hour = 24
        endOfDayDateComponents.minute = 0
        endOfDayDateComponents.second = 0
        
        let startOfDayDate = DataPacketDateFormatter.calendar.date(from: startOfDayDateComponents)!
        let endOfDayDate = DataPacketDateFormatter.calendar.date(from: endOfDayDateComponents)!
        
        let packets = DataPacket.fetch(in: context) { fetchRequest in
            //NSPredicate(format: "(date >= %@) AND (date <= %@)", startDate, endDate)
            fetchRequest.predicate = NSPredicate(format: "(timeStamp >= %@) AND (timeStamp <= %@) AND imei = \(device.imei)", startOfDayDate as NSDate, endOfDayDate as NSDate)
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.sortDescriptors = DataPacket.defaultSortDescriptors
        }
        
//        completionHandler(device, packets)
        
        if fetchMorePacketsFromServerIfRequired {
            completionHandler?((device, packets, true))
            
            let timeStampToUse: Date
            if packets.count == 0 {
                timeStampToUse = startOfDayDate
            } else {
                let dataPacket = packets.last!
                timeStampToUse = dataPacket.timeStamp
            }
            
            let timeStampString = webServiceExpectedDateFormatter.string(from: timeStampToUse)
            
            let minutesFromGMT = DataPacketDateFormatter.dateFormatter.timeZone.secondsFromGMT() / 60
            let zone = minutesFromGMT >= 0 ? "+\(minutesFromGMT)" : "-\(minutesFromGMT)"
            
            
            var urlComp = URLComponents()
            urlComp.scheme = "http"
            urlComp.host = "13.233.18.64"
            urlComp.port = 1166
            urlComp.path = "/api/DeviceData/GetData"
            urlComp.queryItems = [URLQueryItem(name: "IMEI", value: String(device.imei)),
                                  URLQueryItem(name: "time_stamp", value: timeStampString),
                                  URLQueryItem(name: "zone", value: zone)]
            
            let url = urlComp.url!
            var httpRequest = URLRequest(url: url)
            httpRequest.httpMethod = "POST"
            
            URLSession.shared.dataTask(with: httpRequest) { (data, response, error) in
                guard let data = data else {
                    DispatchQueue.main.async {
                        completionHandler?((device, [], false))
                    }
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let jsonResponse = try decoder.decode(GetDataPacketsServiceResponse.self, from: data)
                    
                    var responsePackets = [DataPacket]()
                    jsonResponse.deviceDataViewinfo.forEach { (packet) in
                        let dataPacket = DataPacket.insert(into: self.context, packet: packet, imei: device.imei)
                        dataPacket.device = device
                        responsePackets.append(dataPacket)
                    }
                    
                    DispatchQueue.main.async {
                        completionHandler?((device, responsePackets, false))
                    }
                } catch let jsonParsingError {
                    fatalError(jsonParsingError.localizedDescription)
                }
            }
            
        } else {
            completionHandler?((device, packets, false))
        }
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
                    let dataPacket = DataPacket.insert(into: self.context, packet: packet, imei: device.imei)
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



