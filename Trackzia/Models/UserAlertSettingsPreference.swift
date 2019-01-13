//
//  UserAlertSettingsPreference.swift
//  Trackzia
//
//  Created by Rohan Bhale on 16/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import ApiManager

class UserAlertSettingsPreferenceChangeToken {
    let uuidString = UUID().uuidString
}

enum AlertSettingType: String {
    case battery = "Battery"
    case geofence = "GeoInOut"
    case panic = "Panic"
}

class UserAlertSettingsPreference {
    static var shared = UserAlertSettingsPreference()
    
    private init() {
        if let alertSetValues = UserDefaults.standard.value(forKey: "alertSettings") as? [IMEI: [Bool]] {
            alertSettings = alertSetValues
        } else {
            alertSettings = [:]
        }
    }
    
    var alertSettings: [IMEI: [Bool]]
    
    var alertSettingsChangeListeners: [String: (IMEI) -> Void] = [:]
    
    func getAllAlertSettings(for imeiNumber: IMEI) {
        CommunicationManager.getCommunicator().performOpertaion(with: GetAllAlertSettingsService(imeiNumber: imeiNumber, listener: self))
    }
    
    func setAlertSettingService(imeiNumber: IMEI, type: AlertSettingType, value: Bool) {
        let onOffValue = value ? "true" : "false"
        CommunicationManager.getCommunicator().performOpertaion(with: SetAlertSettingValueService(imeiNumber: imeiNumber, alertName: type.rawValue, onOffValue: onOffValue, listener: self))
    }
    
    func setAlertValues(values: [Bool], for imeiNumber: IMEI) {
        alertSettings[imeiNumber] = values
        UserDefaults.standard.set(alertSettings, forKey: "alertSettings")
        alertSettingsChangeListeners.forEach{ $1(imeiNumber) }
    }
    
    func alertValues(for imeiNumber: IMEI) -> (Bool, Bool, Bool) {
        if let values = alertSettings[imeiNumber] { return (values[0], values[1], values[2]) }
        return (true, true, true)
    }
    
    func addListener(_ listener: @escaping (IMEI) -> Void) -> UserAlertSettingsPreferenceChangeToken {
        let token = UserAlertSettingsPreferenceChangeToken()
        alertSettingsChangeListeners[token.uuidString] = listener
        return token
    }
    
    func removeListener(_ token: UserAlertSettingsPreferenceChangeToken) {
        alertSettingsChangeListeners[token.uuidString] = nil
    }
}

extension UserAlertSettingsPreference: CommunicationResultListener {
    func onSuccess(operationId: Int, operation: CommunicationOperationResult) {
        if let wrapper = operation as? GetAllAlertSettingsServiceResultWrapper {
            if wrapper.result.success, wrapper.result.data != nil {
                setAlertValues(values: [wrapper.result.geoInOut, wrapper.result.battery, wrapper.result.panic], for: wrapper.imeiNumber)
            }
        }
        
        if let wrapper = operation as? SetAlertSettingValueServiceResultWrapper {
            if wrapper.result.success {
                if let settingType = AlertSettingType(rawValue: wrapper.alertName) {
                    let value = wrapper.onOffValue == "false" ? false : true
                    let values = alertValues(for: wrapper.imeiNumber)
                    var valuesArray = [values.0, values.1, values.2]
                    switch settingType {
                    case .geofence: valuesArray[0] = value
                    case .battery: valuesArray[1] = value
                    case .panic: valuesArray[2] = value
                    }
                    setAlertValues(values: valuesArray, for: wrapper.imeiNumber)
                }
            }
        }
    }
    
    func onFailure(operationId: Int, error: Error, data: Data?) {
        
    }
}

