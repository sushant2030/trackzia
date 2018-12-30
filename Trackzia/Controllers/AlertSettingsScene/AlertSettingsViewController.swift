//
//  AlertSettingsViewController.swift
//  Trackzia
//
//  Created by Rohan Bhale on 09/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit

class AlertSettingsViewController: UITableViewController {
    @IBOutlet var geoFenceInoutSwitch: UISwitch!
    @IBOutlet var lowBatterInoutSwitch: UISwitch!
    @IBOutlet var panicSwitch: UISwitch!
    
    var changeListenerToken: UserAlertSettingsPreferenceChangeToken!
    
    deinit {
        UserAlertSettingsPreference.shared.removeListener(changeListenerToken)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let device = IMEISelectionManager.shared.selectedDevice {
            UserAlertSettingsPreference.shared.getAllAlertSettings(for: device.imei)
        }
        changeListenerToken = UserAlertSettingsPreference.shared.addListener({ [weak self] (imeiNumber) in
            if let device = IMEISelectionManager.shared.selectedDevice {
                if device.imei == imeiNumber {
                    self?.updateSwitches(imeiNumber: device.imei)
                }
            }
        })
    }
    
    @IBAction func geoFenceSwitchValueChanged(_ sender: UISwitch) {
        if let device = IMEISelectionManager.shared.selectedDevice {
            UserAlertSettingsPreference.shared.setAlertSettingService(imeiNumber: device.imei, type: .geofence, value: sender.isOn)
        }
    }
    
    @IBAction func lowBatterInoutSwitchValueChanged(_ sender: UISwitch) {
        if let device = IMEISelectionManager.shared.selectedDevice {
            UserAlertSettingsPreference.shared.setAlertSettingService(imeiNumber: device.imei, type: .battery, value: sender.isOn)
        }
    }
    
    @IBAction func panicSwitchValueChanged(_ sender: UISwitch) {
        if let device = IMEISelectionManager.shared.selectedDevice {
            UserAlertSettingsPreference.shared.setAlertSettingService(imeiNumber: device.imei, type: .panic, value: sender.isOn)
        }
    }
    
    func updateSwitches(imeiNumber: String) {
        if let device = IMEISelectionManager.shared.selectedDevice {
            if device.imei == imeiNumber {
                let values = UserAlertSettingsPreference.shared.alertValues(for: imeiNumber)
                geoFenceInoutSwitch.isOn = values.0
                lowBatterInoutSwitch.isOn = values.1
                panicSwitch.isOn = values.2
            }
        }
    }
}
