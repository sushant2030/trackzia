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

class UserDataManager {
    static var shared = UserDataManager()
    
    private init() {}
    
    var isLoggedIn: Bool { return UserDataStore.shared.loggedInState == .loggedIn ? true : false }
    
    var volatileLoginData: (mobileNumber: String, password: String)? {
        didSet {
            print(volatileLoginData)
        }
    }
    
    var imeiList: [String] { return IMEIListStore.shared.sortedKeys.map({ IMEIListStore.shared.imeiDictionary[$0]! })}
    
    func login(mobileNumber: String, password: String) {
        volatileLoginData = (mobileNumber, password)
        CommunicationManager.getCommunicator().performOpertaion(with: LoginService(mobileNumber: mobileNumber, password: password, listener: self))
    }
    
    func getAccntWiseIMEI(accntId: String) {
        CommunicationManager.getCommunicator().performOpertaion(with: GetAccountWiseIMEIService(accountId: accntId, listener: self))
    }
    
    func getAccountDetails(mobileNumber: String) {
        CommunicationManager.getCommunicator().performOpertaion(with: GetAccountDetailsService(mobileNumber: mobileNumber, listener: self))
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
            IMEIListStore.shared.imeiDictionary = result.data ?? [:]
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
    }
    
    func onFailure(operationId: Int, error: Error, data: Data?) {
        
    }
    
    
}

private class UserDataStore {
    static var shared = UserDataStore()
    
    private init() {}
    
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

private class IMEIListStore {
    static var shared = IMEIListStore()
    
    private init() {}
    
    var imeiDictionary: [String: String] {
        get {
            guard let dictionary = UserDefaults.standard.value(forKey: "imeiDictionary") as? [String: String] else { return [:] }
            return dictionary
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "imeiDictionary")
            sortedKeys = newValue.keys.sorted()
        }
    }
    
    var sortedKeys: [String] = []
}
