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
            }
        }
    }
    
    var listeners: [String: () -> Void] = [:]
    
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
}

class IMEISelectionManagerListenerToken {
    let uuidString = UUID().uuidString
}
