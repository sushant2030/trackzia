//
//  Account.swift
//  Trackzia
//
//  Created by Rohan Bhale on 27/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import CoreData

class Account: NSManagedObject {
    @NSManaged var accountId: String
    @NSManaged var city: String?
    @NSManaged var country: String?
    @NSManaged var dob: String?
    @NSManaged var emailId: String?
    @NSManaged var fullName: String?
    @NSManaged var gender: String?
    @NSManaged var mobileno: String
    @NSManaged var state: String?
    @NSManaged var sync: String?
    @NSManaged var updatedAt: Date
    
    @NSManaged var devices: Set<Device>?
    
    static func insert(into context: NSManagedObjectContext, loginAccountData: LoginServiceResult.LoginAccountData, accountDetailsData: GetAccountDetailsServiceResult.AccountDetailsData) -> Account {
        let account: Account = context.insertObject()
        account.accountId = loginAccountData.accountID
        account.city = accountDetailsData.city
        account.country = accountDetailsData.country
        account.dob = accountDetailsData.dob
        account.emailId = accountDetailsData.emailId
        account.fullName = accountDetailsData.accName
        account.gender = accountDetailsData.gender
        account.mobileno = accountDetailsData.mobile
        account.state = accountDetailsData.stateName
        account.updatedAt = Date()
        return account
    }
}

extension Account: Managed {
    
}
