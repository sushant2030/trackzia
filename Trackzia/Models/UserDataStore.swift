//
//  UserDataStore.swift
//  Trackzia
//
//  Created by Rohan Bhale on 29/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import CoreData

typealias IMEI = String

class UserDataStore {
    static var shared = UserDataStore()
    
    var account: Account?
    
    private init() {}
    
    var updateObserver: (() -> Void)?
    
    var mobile: String? { return account?.mobileno ?? nil }
    
    var password: String? {
        get { return UserDefaults.standard.string(forKey: "password") }
        
        set { UserDefaults.standard.set(newValue, forKey: "password") }
    }
    
    var accntId: String? { return account?.accountId ?? nil }
    
    var emailId: String? { return account?.emailId ?? nil }
    
    var city: String? { return account?.city ?? nil }
    
    var gender: String? { return account?.gender ?? nil }
    
    var country: String? { return account?.country ?? nil }
    
    var accName: String? { return account?.fullName ?? nil }
    
    var dob: String? { return account?.dob ?? nil }
    
    var stateName: String? { return account?.state ?? nil }
    
    var loggedInState: LoginState {
        get {
            guard let state = UserDefaults.standard.value(forKey: "loggedIn") as? Int else { return .loggedOut }
            return LoginState(rawValue: state)!
        }
        
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "loggedIn")
        }
    }
    
    func createAccount(in context: NSManagedObjectContext, loginAccountData: LoginServiceResult.LoginAccountData, accountDetailsData: GetAccountDetailsServiceResult.AccountDetailsData) {
        context.performChanges {
            let fetchRequest = Account.sortedFetchRequest
            do {
                let accounts = try context.fetch(fetchRequest)
                accounts.forEach{ context.delete($0) }
            } catch {
                print(error)
            }
            self.account = Account.insert(into: context, loginAccountData: loginAccountData, accountDetailsData: accountDetailsData)
        }
    }
    
    func updateAccount(in context: NSManagedObjectContext, userAccountData: UserAccountData) {
        context.performChanges {
            self.account?.emailId = userAccountData.emailId
            self.account?.city = userAccountData.city
            self.account?.gender = userAccountData.gender
            self.account?.country = userAccountData.country
            self.account?.fullName = userAccountData.accName
            self.account?.dob = userAccountData.dob
            self.account?.state = userAccountData.stateName
        }
    }
    
    func insertDevices(in context: NSManagedObjectContext, for imeiList: [IMEI]) {
        context.performChanges {
            self.account?.devices?.forEach{ context.delete($0) }
            self.account?.devices = []
            for (index, imei) in imeiList.enumerated() {
                let device = Device.insert(into: context, imei: imei)
                device.order = Int16(index)
                self.account?.devices?.insert(device)
            }
        }
    }
}
