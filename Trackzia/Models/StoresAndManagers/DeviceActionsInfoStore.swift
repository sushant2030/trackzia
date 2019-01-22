//
//  DeviceActionsInfoStore.swift
//  Trackzia
//
//  Created by Rohan Bhale on 18/01/19.
//  Copyright © 2019 Private. All rights reserved.
//

import ApiManager
import CoreData

enum DeviceActionsInfoStoreChange {
    case addedForToday(IMEI, DeviceActionsInfo)
    case addedForPastDays(IMEI, DateComponents, DeviceActionsInfo)
    case updated(IMEI, DateComponents, DeviceActionsInfo)
}

class DeviceActionsInfoStoreChangeToken {
    let uuidString = UUID().uuidString
}

class DeviceActionsInfoStore {
    static var shared = DeviceActionsInfoStore()
    var context: NSManagedObjectContext!
    var imeiSelectionManagerListenerToken: IMEISelectionManagerListenerToken!
    let webserviceDateFormatter: DateFormatter
    
    var fetchInProgress: [DateComponents: Set<IMEI>] = [:]
    var changeListeners: [String: (DeviceActionsInfoStoreChange) -> ()] = [:]
    
    private init() {
        webserviceDateFormatter = DateFormatter()//DataPacketDateFormatter.dateFormatter
        webserviceDateFormatter.dateFormat = "yyyyMMddHHmmss"
        webserviceDateFormatter.timeZone = DataPacketDateFormatter.timezone
        imeiSelectionManagerListenerToken = IMEISelectionManager.shared.addListener(imeiSelectionManagerListener)
    }
    
    func todaysActionInfo(for device: Device) -> DeviceActionsInfo? {
        let yearMonthDay = DataPacketDateFormatter.yearMonthDayDateComponentsForNow()
        let results = DeviceActionsInfo.fetch(in: context) { (fetchRequest) in
            fetchRequest.sortDescriptors = DeviceActionsInfo.defaultSortDescriptors
            fetchRequest.predicate = NSPredicate(format: "year == \(yearMonthDay.year!) AND month == \(yearMonthDay.month!) AND day == \(yearMonthDay.day!) AND imei = \(device.imei)")
        }
        return results.first
    }
    
    func imeiSelectionManagerListener() {
        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
        let yearMonthDay = DataPacketDateFormatter.yearMonthDayDateComponentsForNow()
        
        if let fetchInProgressForImeiList = fetchInProgress[yearMonthDay], fetchInProgressForImeiList.contains(device.imei) {
            return
        }
        
        let result = todaysActionInfo(for: device)
        
        if let deviceActionInfoForToday = result {
            // Get action infos timeStamp
            let timeStamp = deviceActionInfoForToday.timeStamp
            let timeStampString = webserviceDateFormatter.string(from: timeStamp)
            getDeviceActionInfo(imei: device.imei, timeStamp: timeStampString, yearMonthDay: yearMonthDay, actionsInfo: deviceActionInfoForToday)
        } else {
            context.performChanges {
                let deviceActionInfoForToday = DeviceActionsInfo.insert(into: self.context, imei: device.imei, year: yearMonthDay.year!, month: yearMonthDay.month!, day: yearMonthDay.day!, secondsFromGMT: DataPacketDateFormatter.secondsFromGMT)
                
                DispatchQueue.main.async {
                    self.informAllListners(change: .addedForToday(device.imei, deviceActionInfoForToday))
                    let timeStamp = deviceActionInfoForToday.timeStamp
                    let timeStampString = self.webserviceDateFormatter.string(from: timeStamp)
                    self.getDeviceActionInfo(imei: device.imei, timeStamp: timeStampString, yearMonthDay: yearMonthDay, actionsInfo: deviceActionInfoForToday)
                }
            }
        }
        
    }
    
    func getDeviceActionInfo(imei: IMEI, timeStamp: String, yearMonthDay: DateComponents, actionsInfo: DeviceActionsInfo) {
        if self.fetchInProgress[yearMonthDay] == nil { self.fetchInProgress[yearMonthDay] = [] }
        self.fetchInProgress[yearMonthDay]?.insert(imei)
        CommunicationManager.getCommunicator().performOpertaion(with: GetDataPacketsService(imei: imei, timeStamp: timeStamp, yearMonthDay: yearMonthDay, deviceActionsInfo: actionsInfo, listener: self))
    }
    
    func addListener(_ listener: @escaping (DeviceActionsInfoStoreChange) -> ()) -> DeviceActionsInfoStoreChangeToken {
        let token = DeviceActionsInfoStoreChangeToken()
        changeListeners[token.uuidString] = listener
        return token
    }
    
    func removeListener(token: DeviceActionsInfoStoreChangeToken) {
        changeListeners[token.uuidString] = nil
    }
    
    func informAllListners(change: DeviceActionsInfoStoreChange) {
        changeListeners.forEach({ $1(change) })
    }
}

extension DeviceActionsInfoStore: CommunicationResultListener {
    func onSuccess(operationId: Int, operation: CommunicationOperationResult) {
        if let wrapper = operation as? GetDataPacketsServiceResponseWrapper {
            fetchInProgress[wrapper.yearMonthDay]?.remove(wrapper.imei)
            context.performChanges {
                wrapper.deviceActionsInfo.update(info: wrapper.response.deviceDataRestExploreRuninfo)
                wrapper.response.deviceDataViewinfo.forEach({
                    let _ = DataPacket.insert(into: self.context, packet: $0, imei: wrapper.imei, secondsFromGMT: DataPacketDateFormatter.secondsFromGMT)
                })
            }
            
            DispatchQueue.main.async {
                self.informAllListners(change: .updated(wrapper.imei, wrapper.yearMonthDay, wrapper.deviceActionsInfo))
            }
        }
    }
    
    func onFailure(operationId: Int, error: Error, data: Data?) {
        print(error)
    }
}









//
//typealias DataPacketsTuple = (date: Date, device: Device, allPackets: [DataPacket], moreUpdatesToCome: Bool)
//typealias GetDataPacketCompletionHandler = (DataPacketsTuple) -> ()
//
//class DeviceActionsInfoStore {
//    static var shared = DeviceActionsInfoStore()
//    var context: NSManagedObjectContext!
//    var imeiSelectionManagerListenerToken: IMEISelectionManagerListenerToken!
//    
//    var fetchInProgress = Set<IMEI>()
//    var alreadyFetched = Set<IMEI>()
//    
//    let webServiceExpectedDateFormatter: DateFormatter
//    
//    private init() {
//        webServiceExpectedDateFormatter = DateFormatter()
//        webServiceExpectedDateFormatter.timeZone = TimeZone.current
//        webServiceExpectedDateFormatter.dateFormat = "yyyyMMddHHmmss"
//        imeiSelectionManagerListenerToken = IMEISelectionManager.shared.addListener(imeiSelectionManagerListener)
//    }
//    
//    func forceUpdateIfAlreadyFetched() {
//        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
//        guard !fetchInProgress.contains(device.imei) else { return }
//        
//        updateTodayActionInfo(for: device)
//    }
//    
//    func imeiSelectionManagerListener() {
//        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
//        guard !alreadyFetched.contains(device.imei) else { return }
//        guard !fetchInProgress.contains(device.imei) else { return }
//        
//        updateTodayActionInfo(for: device)
//    }
//    
//    func setComponents(components: DateComponents, hour: Int, minute: Int, second: Int) -> DateComponents {
//        var newComponents = components
//        newComponents.hour = hour
//        newComponents.minute = minute
//        newComponents.second = second
//        return newComponents
//    }
//    
//    func getDeviceDataPackets(device: Device, timeStampString: String) {
//        CommunicationManager.getCommunicator().performOpertaion(with: GetDataPacketsService(imei: device.imei, timeStamp: timeStampString, listener: self))
//    }
//}
//
//extension DeviceActionsInfoStore {
//    func updateTodayActionInfo(for device: Device) {
//        guard let actionInfo = IMEISelectionManager.shared.selectedDevice?.actionsInfo else { return }
//        
//        let calendar = DataPacketDateFormatter.calendar
//        let yearMonthDay: Set<Calendar.Component> = [.year, .month, .day]
//        
//        let today = Date()
//        let todayDateComponents = calendar.dateComponents(yearMonthDay, from: today)
//        
//        let actionInfoTimeStamp = actionInfo.timeStamp
//        let actionInfoTimeStampDateComponents = calendar.dateComponents(yearMonthDay, from: actionInfoTimeStamp)
//        
//        if todayDateComponents == actionInfoTimeStampDateComponents {
//            // actionInfo of the device was updated today
//            // So we check if complete is true or not
//            // If its is true we dont call the webservice as there are no more packets.
//            // If it is false we call the webservice with the timeStamp of the actionInfo
//            if actionInfo.complete == false {
//                // Call Webservice with actionInfo timeStamp
//                let timeStampString = webServiceExpectedDateFormatter.string(from: actionInfo.timeStamp)
//                getDeviceDataPackets(device: device, timeStampString: timeStampString)
//            } else {
//                alreadyFetched.insert(device.imei)
//            }
//        } else {
//            // actionInfo was last updated previous to today, so we want to fetch it for today now
//            // Call Webservice with timestamp as today and time as 00:00:00
//            var dateComponents = todayDateComponents
//            dateComponents.hour = 0
//            dateComponents.minute = 0
//            dateComponents.second = 0
//            let date = calendar.date(from: dateComponents)!
//            let timeStampString = webServiceExpectedDateFormatter.string(from: date)
//            getDeviceDataPackets(device: device, timeStampString: timeStampString)
//        }
//    }
//}
//
//extension DeviceActionsInfoStore {
//    func getPackets(for device: Device, for forDate: Date, fetchMorePacketsFromServerIfRequired: Bool = true, completionHandler: GetDataPacketCompletionHandler? = nil) {
//        let yearMonthDayHourMinSecComp: Set<Calendar.Component> = [.year, .month, .day]
//        let forDateComponents = DataPacketDateFormatter.calendar.dateComponents(yearMonthDayHourMinSecComp, from: forDate)
//        
//        var startOfDayDateComponents = forDateComponents
//        startOfDayDateComponents.hour = 0
//        startOfDayDateComponents.minute = 0
//        startOfDayDateComponents.second = 0
//        
//        var endOfDayDateComponents = forDateComponents
//        endOfDayDateComponents.hour = 24
//        endOfDayDateComponents.minute = 0
//        endOfDayDateComponents.second = 0
//        
//        let startOfDayDate = DataPacketDateFormatter.calendar.date(from: startOfDayDateComponents)!
//        let endOfDayDate = DataPacketDateFormatter.calendar.date(from: endOfDayDateComponents)!
//        
//        let packets = DataPacket.fetch(in: context) { fetchRequest in
//            //NSPredicate(format: "(date >= %@) AND (date <= %@)", startDate, endDate)
//            fetchRequest.predicate = NSPredicate(format: "(timeStamp >= %@) AND (timeStamp <= %@) AND imei = \(device.imei)", startOfDayDate as NSDate, endOfDayDate as NSDate)
//            fetchRequest.returnsObjectsAsFaults = false
//            fetchRequest.sortDescriptors = DataPacket.defaultSortDescriptors
//        }
//        
////        completionHandler(device, packets)
//        
//        if fetchMorePacketsFromServerIfRequired {
//            completionHandler?((forDate, device, packets, true))
//            
//            let timeStampToUse: Date
//            if packets.count == 0 {
//                timeStampToUse = startOfDayDate
//            } else {
//                let dataPacket = packets.last!
//                timeStampToUse = dataPacket.timeStamp
//            }
//            
//            let timeStampString = webServiceExpectedDateFormatter.string(from: timeStampToUse)
//            
//            let minutesFromGMT = DataPacketDateFormatter.dateFormatter.timeZone.secondsFromGMT() / 60
//            let zone = minutesFromGMT >= 0 ? "+\(minutesFromGMT)" : "-\(minutesFromGMT)"
//            
//            
//            var urlComp = URLComponents()
//            urlComp.scheme = "http"
//            urlComp.host = "13.233.18.64"
//            urlComp.port = 1166
//            urlComp.path = "/api/DeviceData/GetData"
//            urlComp.queryItems = [URLQueryItem(name: "IMEI", value: String(device.imei)),
//                                  URLQueryItem(name: "time_stamp", value: timeStampString),
//                                  URLQueryItem(name: "zone", value: zone)]
//            
//            let url = urlComp.url!
//            var httpRequest = URLRequest(url: url)
//            httpRequest.httpMethod = "POST"
//            
//            URLSession.shared.dataTask(with: httpRequest) { (data, response, error) in
//                guard let data = data else {
//                    DispatchQueue.main.async {
//                        completionHandler?((forDate, device, packets, false))
//                    }
//                    return
//                }
//                do {
//                    let decoder = JSONDecoder()
//                    let jsonResponse = try decoder.decode(GetDataPacketsServiceResponse.self, from: data)
//                    
//                    jsonResponse.deviceDataViewinfo.forEach { (packet) in
//                        let dataPacket = DataPacket.insert(into: self.context, packet: packet, imei: device.imei)
//                        dataPacket.device = device
//                    }
//                    
//                    DispatchQueue.main.async {
//                        let packets = DataPacket.fetch(in: self.context) { fetchRequest in
//                            //NSPredicate(format: "(date >= %@) AND (date <= %@)", startDate, endDate)
//                            fetchRequest.predicate = NSPredicate(format: "(timeStamp >= %@) AND (timeStamp <= %@) AND imei = \(device.imei)", startOfDayDate as NSDate, endOfDayDate as NSDate)
//                            fetchRequest.returnsObjectsAsFaults = false
//                            fetchRequest.sortDescriptors = DataPacket.defaultSortDescriptors
//                        }
//                        completionHandler?((forDate, device, packets, false))
//                    }
//                } catch let jsonParsingError {
//                    fatalError(jsonParsingError.localizedDescription)
//                }
//            }
//            
//        } else {
//            completionHandler?((forDate, device, packets, false))
//        }
//    }
//
//}
//
//extension DeviceActionsInfoStore: CommunicationResultListener {
//    func onSuccess(operationId: Int, operation: CommunicationOperationResult) {
//        if let wrapper = operation as? GetDataPacketsServiceResponseWrapper {
//            fetchInProgress.remove(wrapper.imei)
//            guard let device = UserDataStore.shared.account?.devices?.filter({ $0.imei == wrapper.imei }).first else { return }
//            alreadyFetched.insert(wrapper.imei)
//            context.performChanges {
//                wrapper.response.deviceDataViewinfo.forEach { (packet) in
//                    let dataPacket = DataPacket.insert(into: self.context, packet: packet, imei: device.imei)
//                    dataPacket.device = device
//                }
//                
//                device.actionsInfo.update(info: wrapper.response.deviceDataRestExploreRuninfo)
//                
//            }
//        }
//    }
//    
//    func onFailure(operationId: Int, error: Error, data: Data?) {
//        print(error)
//    }
//}
//
//
//
