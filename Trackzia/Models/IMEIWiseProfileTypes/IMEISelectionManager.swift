//
//  IMEISelectionManager.swift
//  Trackzia
//
//  Created by Rohan Bhale on 15/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import Foundation

class IMEISelectionManager {
    static var shared = IMEISelectionManager()
    
    private init() {}
    
    var selectedDevice: Device? {
        didSet {
            if oldValue?.imei != selectedDevice?.imei {
                informListeners()
                DispatchQueue.main.async {
                    guard let selectedDevice = self.selectedDevice else { return }
                    guard let activeProfile = selectedDevice.activeProfile else {
                        self.profileType = .pet
                        return
                    }
                    self.profileType = ProfileType(rawValue: activeProfile.profileType)!
                }
            }
        }
    }
    
    var profileType: ProfileType = .pet {
        didSet {
            if oldValue != profileType {
                informProfileTypeListeners()
            }
        }
    }
    
    var listeners: [String: () -> Void] = [:]
    var profileTypeListeners: [String: () -> Void] = [:]
    
    func removeListener(token: IMEISelectionManagerListenerToken) {
        listeners[token.uuidString] = nil
    }
    
    func addListener(_ listener: @escaping () -> Void) -> IMEISelectionManagerListenerToken {
        let token = IMEISelectionManagerListenerToken()
        listeners[token.uuidString] = listener
        return token
    }
    
    func informListeners() {
        listeners.forEach{ $1() }
    }
    
    func removeProfileListener(token: ProfileSectionListenerToken) {
        profileTypeListeners[token.uuidString] = nil
    }
    
    func addListener(_ listener: @escaping () -> Void) -> ProfileSectionListenerToken {
        let token = ProfileSectionListenerToken()
        profileTypeListeners[token.uuidString] = listener
        return token
    }
    
    func informProfileTypeListeners() {
        profileTypeListeners.forEach{ $1() }
    }
}

class IMEISelectionManagerListenerToken {
    let uuidString = UUID().uuidString
}

class ProfileSectionListenerToken {
    let uuidString = UUID().uuidString
}
