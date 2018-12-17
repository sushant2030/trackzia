//
//  UserDataManager.swift
//  Trackzia
//
//  Created by Rohan Bhale on 15/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import Foundation
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
    
    private init() {
        imeiSelectionManagerListenerToken = IMEISelectionManager.shared.addListener(imeiSelectionManagerListener)
    }
    
    var isLoggedIn: Bool { return UserDataStore.shared.loggedInState == .loggedIn ? true : false }
    
    var volatileLoginData: (mobileNumber: String, password: String)?
    var volatileIMEINumber: String?
    
    var imeiList: [String] {
        return AccntWiseIMEIListStore.shared.sortedKeys.map({ AccntWiseIMEIListStore.shared.imeiDictionary[$0]! })
    }
    
    var imeiWiseProfileFetchInProgress: Set<String> = []
    
    typealias IMEINumber = String
    var imeiWiseProfileChangesListeners: [String: (IMEINumber) -> Void] = [:]
    
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
    
    func getAccntWiseIMEI(accntId: String) {
        CommunicationManager.getCommunicator().performOpertaion(with: GetAccountWiseIMEIService(accountId: accntId, listener: self))
    }
    
    func getIMEIWiseProfiles(imeiNumber: String) {
        volatileIMEINumber = imeiNumber
        CommunicationManager.getCommunicator().performOpertaion(with: GetIMEIWiseProfiles(imeiNumber: imeiNumber, listener: UserDataManager.shared))
    }
    
    // MARK: Local data
    func profileTypesFrom(imeiNumber: String) -> [Any] {
        return IMEIWiseProfilesStore.shared.profileTypesFrom(imeiNumber: imeiNumber)
    }
    
    // MARK: IMEI data
    func imeiSelectionManagerListener() {
        if imeiList.count > IMEISelectionManager.shared.selectedIndex {
            let imeiNumber = imeiList[IMEISelectionManager.shared.selectedIndex]
            if IMEIWiseProfilesStore.shared.imeiWiseProfiles[imeiNumber] == nil {
                if imeiWiseProfileFetchInProgress.contains(imeiNumber) { return }
                imeiWiseProfileFetchInProgress.insert(imeiNumber)
                getIMEIWiseProfiles(imeiNumber: imeiNumber)
            }
        }
    }
    
    // MARK: Add remove listeners to changes in IMEI wise profiles
    func addListener(_ listener: @escaping (IMEINumber) -> Void) -> IMEIWiseProfileListenerToken {
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
                UserDataStore.shared.mobile = volatileLoginData?.mobileNumber
                UserDataStore.shared.password = volatileLoginData?.password
                UserDataStore.shared.accntId = result.data?.accountID
                UserDataStore.shared.loggedInState = .loggedIn
                getAccntWiseIMEI(accntId: UserDataStore.shared.accntId!)
            } else {
                volatileLoginData = nil
            }
        }
        
        if let result = operation as? GetAccountWiseIMEIServiceResult, result.success {
            AccntWiseIMEIListStore.shared.imeiDictionary = result.data ?? [:]
            getAccountDetails(mobileNumber: UserDataStore.shared.mobile!)
        }
        
        if let result = operation as? GetAccountDetailsServiceResult, result.success {
            UserDataStore.shared.emailId = result.data?.emailId
            UserDataStore.shared.city = result.data?.city
            UserDataStore.shared.gender = result.data?.gender
            UserDataStore.shared.country = result.data?.country
            UserDataStore.shared.accName = result.data?.accName
            UserDataStore.shared.dob = result.data?.dob
            UserDataStore.shared.stateName = result.data?.stateName
            
            PostLoginRouter.showHomeView()
        }
        
        if let wrapper = operation as? GetIMEIWiseProfilesResultWrapper {
            imeiWiseProfileFetchInProgress.remove(wrapper.imeiNumber)
            if wrapper.result.success {
                IMEIWiseProfilesStore.shared.setProfiles(wrapper.result.dataList, for: wrapper.imeiNumber)
                imeiWiseProfileChangesListeners.forEach({ $1(wrapper.imeiNumber) })
            }
        }
        
        if let wrapper = operation as? UpdateAccountDetailsServiceResultWrapper {
            if wrapper.result.success {
                UserDataStore.shared.emailId = wrapper.accntData.emailId
                UserDataStore.shared.city = wrapper.accntData.city
                UserDataStore.shared.gender = wrapper.accntData.gender
                UserDataStore.shared.country = wrapper.accntData.country
                UserDataStore.shared.accName = wrapper.accntData.accName
                UserDataStore.shared.dob = wrapper.accntData.dob
                UserDataStore.shared.stateName = wrapper.accntData.stateName
                UserDataStore.shared.updateObserver?()
            }
        }
    }
    
    func onFailure(operationId: Int, error: Error, data: Data?) {
        print(error)
    }
    
    
}

private class UserDataStore {
    static var shared = UserDataStore()
    
    private init() {}
    
    var updateObserver: (() -> Void)?
    
    var mobile: String? {
        get {
            return UserDefaults.standard.string(forKey: "mobile")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "mobile")
        }
    }
    
    var password: String? {
        get {
            return UserDefaults.standard.string(forKey: "password")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "password")
        }
    }
    
    var accntId: String? {
        get {
            return UserDefaults.standard.string(forKey: "accntId")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "accntId")
        }
    }
    
    var emailId: String? {
        get {
            return UserDefaults.standard.string(forKey: "emailId")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "emailId")
        }
    }
    
    var city: String? {
        get {
            return UserDefaults.standard.string(forKey: "city")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "city")
        }
    }
    
    var gender: String? {
        get {
            return UserDefaults.standard.string(forKey: "gender")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "gender")
        }
    }
    
    var country: String? {
        get {
            return UserDefaults.standard.string(forKey: "country")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "country")
        }
    }
    
    var accName: String? {
        get {
            return UserDefaults.standard.string(forKey: "accName")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "accName")
        }
    }
    
    var dob: String? {
        get {
            return UserDefaults.standard.string(forKey: "dob")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "dob")
        }
    }
    
    var stateName: String? {
        get {
            return UserDefaults.standard.string(forKey: "stateName")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "stateName")
        }
    }
    
    var loggedInState: LoginState {
        get {
            guard let state = UserDefaults.standard.value(forKey: "loggedIn") as? Int else { return .loggedOut }
            return LoginState(rawValue: state)!
        }
        
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "loggedIn")
        }
    }
}

private class AccntWiseIMEIListStore {
    static var shared = AccntWiseIMEIListStore()
    
    private init() {}
    
    var imeiDictionary: [String: String] {
        get {
            guard let dictionary = UserDefaults.standard.value(forKey: "imeiDictionary") as? [String: String] else { return [:] }
            return dictionary
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "imeiDictionary")
        }
    }
    
    var sortedKeys: [String] { return imeiDictionary.keys.sorted() }
}

private class IMEIWiseProfilesStore {
    typealias IMEINumber = String
    
    static var shared = IMEIWiseProfilesStore()
    
    private init() {
        imeiWiseProfiles = UserDefaults.standard.value(forKey: "imeiWiseProfiles") as? [IMEINumber: [[String: String]]] ?? [:]
    }
    
    var imeiWiseProfiles: [IMEINumber: [[String: String]]]
    
    func setProfiles(_ profiles: [[String: String]], for imeiNumber: String) {
        imeiWiseProfiles[imeiNumber] = profiles
        UserDefaults.standard.set(imeiWiseProfiles, forKey: "imeiWiseProfiles")
    }
    
    func profileTypesFrom(imeiNumber: String) -> [Any] {
        let kidProfile = profileTypeKidFrom(imeiNumber: imeiNumber)
        let petProfile = profileTypePetFrom(imeiNumber: imeiNumber)
        let seniorCitizenProfile = profileTypeSeniorCitizenFrom(imeiNumber: imeiNumber)
        let vehicleProfile = profileTypeVehicleFrom(imeiNumber: imeiNumber)
        let otherProfile = profileTypeOtherFrom(imeiNumber: imeiNumber)
        return [petProfile, kidProfile, seniorCitizenProfile, vehicleProfile, otherProfile]
    }
    
    func profileTypeKidFrom(imeiNumber: String) -> ProfileTypeKid {
        let dictionary = imeiWiseProfiles[imeiNumber]?.filter({ $0["ProfileType"] == "Kid" }).first ?? [:]
        return profileTypeKid(dictionary: dictionary)
    }
    
    func profileTypePetFrom(imeiNumber: String) -> ProfileTypePet {
        let dictionary = imeiWiseProfiles[imeiNumber]?.filter({ $0["ProfileType"] == "Pet" }).first ?? [:]
        return profileTypePet(dictionary: dictionary)
    }
    
    func profileTypeSeniorCitizenFrom(imeiNumber: String) -> ProfileTypeSeniorCitizen {
        let dictionary = imeiWiseProfiles[imeiNumber]?.filter({ $0["ProfileType"] == "SeniorCitizen" }).first ?? [:]
        return profileTypeSeniorCitizen(dictionary: dictionary)
    }
    
    func profileTypeVehicleFrom(imeiNumber: String) -> ProfileTypeVehicle {
        let dictionary = imeiWiseProfiles[imeiNumber]?.filter({ $0["ProfileType"] == "Vehicle" }).first ?? [:]
        return profileTypeVehicle(dictionary: dictionary)
    }
    
    func profileTypeOtherFrom(imeiNumber: String) -> ProfileTypeOther {
        let dictionary = imeiWiseProfiles[imeiNumber]?.filter({ $0["ProfileType"] == "Other" }).first ?? [:]
        return profileTypeOther(dictionary: dictionary)
    }
}

