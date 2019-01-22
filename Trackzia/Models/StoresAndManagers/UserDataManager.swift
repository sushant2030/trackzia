//
//  UserDataManager.swift
//  Trackzia
//
//  Created by Rohan Bhale on 15/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import Foundation
import CoreData
import ApiManager

enum LoginState: Int {
    case loggedOut = 0
    case loggedIn
}

class IMEIWiseProfileListenerToken {
    let uuidString = UUID().uuidString
}

class UserDataManager {
    static var shared = UserDataManager()
    
    var imeiSelectionManagerListenerToken: IMEISelectionManagerListenerToken!
    var context: NSManagedObjectContext! {
        didSet {
            do {
                let fetchRequest = Account.sortedFetchRequest
                do {
                    if let account = try context.fetch(fetchRequest).first {
                        UserDataStore.shared.account = account
                    }
                } catch {
                    UserDataStore.shared.account = nil
                }
            }
            
            do {
                DeviceStore.shared.refreshDeviceList(from: context)
            }
            
        }
    }
    
    private init() {
        imeiSelectionManagerListenerToken = IMEISelectionManager.shared.addListener(imeiSelectionManagerListener)
    }
    
    var isLoggedIn: Bool { return UserDataStore.shared.loggedInState == .loggedIn ? true : false }
    
    var volatileLoginData: (mobileNumber: String, password: String)?
    var volatileIMEINumber: IMEI?
    
    var imeiList: [IMEI] {
        return DeviceStore.shared.devices.map{ $0.imei }
    }
    
    var imeiWiseProfileFetchInProgress: Set<IMEI> = []
    
    var imeiWiseProfileChangesListeners: [String: (IMEI) -> Void] = [:]
    
    var volatileLoginAccountData: LoginServiceResult.LoginAccountData? = nil
    var geoFenceDetailsCompletionHandler: ((IMEI) -> Void)?
    
    // MARK: Service usage
    func login(mobileNumber: String, password: String) {
        volatileLoginData = (mobileNumber, password)
        CommunicationManager.getCommunicator().performOpertaion(with: LoginService(mobileNumber: mobileNumber, password: password, listener: self))
    }
    
    func getAccountDetails(mobileNumber: String) {
        CommunicationManager.getCommunicator().performOpertaion(with: GetAccountDetailsService(mobileNumber: mobileNumber, listener: self))
    }
    
    func updateAccountDetails(userAccntData: UserAccountData, completionHandler: @escaping () -> Void) {
        UserDataStore.shared.updateObserver = completionHandler
        CommunicationManager.getCommunicator().performOpertaion(with: UpdateAccountDetailsService(userAccntData: userAccntData, listener: self))
    }
    
//    func getAccntWiseIMEI(accntId: String) {
//        CommunicationManager.getCommunicator().performOpertaion(with: GetAccountWiseIMEIService(accountId: accntId, listener: self))
//    }
    
    func getIMEIWiseProfiles(imeiNumber: IMEI) {
        volatileIMEINumber = imeiNumber
        CommunicationManager.getCommunicator().performOpertaion(with: GetIMEIWiseProfiles(imeiNumber: imeiNumber, listener: self))
    }
    
    func getGeoFenceDetails(imei: IMEI, completionHandlder: @escaping (IMEI) -> Void) {
        geoFenceDetailsCompletionHandler = completionHandlder
        CommunicationManager.getCommunicator().performOpertaion(with: GetGeoFenceDetailsService(imei: imei, listener: self))
    }
    
    func getDataPackets(imei: IMEI, completionHandler: @escaping (IMEI) -> Void) {
        guard let device = UserDataStore.shared.account?.devices?.filter({ $0.imei == imei }).first else {
            completionHandler(-1)
            return
        }
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "DataPacket")
        request.resultType = .dictionaryResultType
        request.predicate = NSPredicate(format: "device == %@", device)
        
        let timeStampExpressionDescription = NSExpressionDescription()
        timeStampExpressionDescription.expressionResultType = .doubleAttributeType
        timeStampExpressionDescription.expression = NSExpression(forFunction: "max:", arguments: [NSExpression(forKeyPath: "timeStamp")])
        timeStampExpressionDescription.name = "maxTimeStamp"
        
        
    }
    
    // MARK: Local data
    func profileTypesFrom(imeiNumber: IMEI) -> [Any] {
        return IMEIWiseProfilesStore.shared.profileTypesFrom(imeiNumber: imeiNumber)
    }
    
    // MARK: IMEI data
    func imeiSelectionManagerListener() {
        if let device = IMEISelectionManager.shared.selectedDevice {
            if device.profiles == nil || device.profiles?.count == 0 {
                if imeiWiseProfileFetchInProgress.contains(device.imei) { return }
                imeiWiseProfileFetchInProgress.insert(device.imei)
                getIMEIWiseProfiles(imeiNumber: device.imei)
            }
        }
    }
    
    // MARK: Add remove listeners to changes in IMEI wise profiles
    func addListener(_ listener: @escaping (IMEI) -> Void) -> IMEIWiseProfileListenerToken {
        let token = IMEIWiseProfileListenerToken()
        imeiWiseProfileChangesListeners[token.uuidString] = listener
        return token
    }
    
    func removeListener(_ token: IMEIWiseProfileListenerToken) {
        imeiWiseProfileChangesListeners[token.uuidString] = nil
    }
}

extension UserDataManager: CommunicationResultListener {
    func onSuccess(operationId: Int, operation: CommunicationOperationResult) {
        if let result = operation as? LoginServiceResult {
            if result.success {
                UserDataStore.shared.password = volatileLoginData?.password
                UserDataStore.shared.loggedInState = .loggedIn
                volatileLoginAccountData = result.data!
                getAccountDetails(mobileNumber: volatileLoginData!.mobileNumber)
            } else {
                volatileLoginData = nil
            }
        }
        
        if let result = operation as? GetAccountDetailsServiceResult, result.success {
            UserDataStore.shared.createAccount(in: context, loginAccountData: self.volatileLoginAccountData!, accountDetailsData: result.data!)
            
            DispatchQueue.main.async {
                self.volatileLoginAccountData = nil
                DeviceStore.shared.getAccntWiseIMEI(accntId: UserDataStore.shared.accntId!)
            }
        }

        if let wrapper = operation as? GetIMEIWiseProfilesResultWrapper {
            imeiWiseProfileFetchInProgress.remove(wrapper.imeiNumber)
            if wrapper.result.success {
                IMEIWiseProfilesStore.shared.setProfiles(in: context, profileDictionaries: wrapper.result.dataList, for: wrapper.imeiNumber)
                DispatchQueue.main.async {
                    self.imeiWiseProfileChangesListeners.forEach({ $1(wrapper.imeiNumber) })
                }
            }
        }
        
        if let wrapper = operation as? UpdateAccountDetailsServiceResultWrapper {
            if wrapper.result.success {
                UserDataStore.shared.updateAccount(in: context, userAccountData: wrapper.accntData)
                UserDataStore.shared.updateObserver?()
            }
        }
        
        if let wrapper = operation as? GetGeoFenceDetailsServiceResultWrapper {
            if wrapper.result.success {
                guard let device = UserDataStore.shared.account?.devices?.filter({ $0.imei == wrapper.imei }).first else { return }
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
                }
            }
        }
    }
    
    func onFailure(operationId: Int, error: Error, data: Data?) {
        print(error)
    }
    
}
