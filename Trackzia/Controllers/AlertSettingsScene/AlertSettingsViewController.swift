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
        if UserDataManager.shared.imeiList.count > IMEISelectionManager.shared.selectedIndex {
            let settingsDisplayedForIMEINumber = UserDataManager.shared.imeiList[IMEISelectionManager.shared.selectedIndex]
            UserAlertSettingsPreference.shared.getAllAlertSettings(for: settingsDisplayedForIMEINumber)
        }
        changeListenerToken = UserAlertSettingsPreference.shared.addListener({ [weak self] (imeiNumber) in
            if UserDataManager.shared.imeiList.count > IMEISelectionManager.shared.selectedIndex {
                let settingsDisplayedForIMEINumber = UserDataManager.shared.imeiList[IMEISelectionManager.shared.selectedIndex]
                if settingsDisplayedForIMEINumber == imeiNumber {
                    self?.updateSwitches(imeiNumber: settingsDisplayedForIMEINumber)
                }
            }
        })
    }
    
    @IBAction func geoFenceSwitchValueChanged(_ sender: UISwitch) {
        if UserDataManager.shared.imeiList.count > IMEISelectionManager.shared.selectedIndex {
            let settingsDisplayedForIMEINumber = UserDataManager.shared.imeiList[IMEISelectionManager.shared.selectedIndex]
            UserAlertSettingsPreference.shared.setAlertSettingService(imeiNumber: settingsDisplayedForIMEINumber, type: .geofence, value: sender.isOn)
        }
    }
    
    @IBAction func lowBatterInoutSwitchValueChanged(_ sender: UISwitch) {
        if UserDataManager.shared.imeiList.count > IMEISelectionManager.shared.selectedIndex {
            let settingsDisplayedForIMEINumber = UserDataManager.shared.imeiList[IMEISelectionManager.shared.selectedIndex]
            UserAlertSettingsPreference.shared.setAlertSettingService(imeiNumber: settingsDisplayedForIMEINumber, type: .battery, value: sender.isOn)
        }
    }
    
    @IBAction func panicSwitchValueChanged(_ sender: UISwitch) {
        if UserDataManager.shared.imeiList.count > IMEISelectionManager.shared.selectedIndex {
            let settingsDisplayedForIMEINumber = UserDataManager.shared.imeiList[IMEISelectionManager.shared.selectedIndex]
            
            UserAlertSettingsPreference.shared.setAlertSettingService(imeiNumber: settingsDisplayedForIMEINumber, type: .panic, value: sender.isOn)
        }
    }
    
    func updateSwitches(imeiNumber: String) {
        if UserDataManager.shared.imeiList.count > IMEISelectionManager.shared.selectedIndex {
            let settingsDisplayedForIMEINumber = UserDataManager.shared.imeiList[IMEISelectionManager.shared.selectedIndex]
            if settingsDisplayedForIMEINumber == imeiNumber {
                let values = UserAlertSettingsPreference.shared.alertValues(for: imeiNumber)
                geoFenceInoutSwitch.isOn = values.0
                lowBatterInoutSwitch.isOn = values.1
                panicSwitch.isOn = values.2
            }
        }
    }
}
