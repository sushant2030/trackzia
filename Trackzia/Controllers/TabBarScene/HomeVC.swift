//
//  HomeVC.swift
//  Trackzia
//
//  Created by Sushant Alone on 09/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit
import CoreLocation

class HomeVC: UIViewController {

    @IBOutlet var lblProfileName: UILabel!
    @IBOutlet var lblJustNow: UILabel!
    @IBOutlet var lblCurrentLocation: UILabel!
    
    @IBOutlet var lblUpdatedAt: UILabel!
    @IBOutlet var lblDetail: UILabel!
    @IBOutlet var lblCurrentDistance: UILabel!

    @IBOutlet var lblRestingHours: UILabel!
    @IBOutlet var lblExploring: UILabel!
    @IBOutlet var lblPlayinHours: UILabel!
    @IBOutlet var imgProfile: UIImageView!
    
    
    
    
    @IBOutlet var batteryLabel: UILabel!
    
    let geoCoder = CLGeocoder()
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.timeZone = DataPacketDateFormatter.dateFormatter.timeZone
        return dateFormatter
    }()
    
    var imeiChangeListenerToken: IMEISelectionManagerListenerToken!
    var profileChangeListenerToken: ProfileSectionListenerToken!
    var actionInfoStoreChangeListener: DeviceActionsInfoStoreChangeToken!
    
    var deviceInfoObjectObserver: ManagedObjectObserver?
    
    var updatedAtUpdatedTimer: Timer!
    
    
    var geofenceListenerToken: GeofenceStoreListenerToken!
    
    deinit {
        IMEISelectionManager.shared.removeListener(token: imeiChangeListenerToken)
        IMEISelectionManager.shared.removeProfileListener(token: profileChangeListenerToken)
        if let geofenceListenerToken = geofenceListenerToken {
            GeofenceStore.shared.removeListener(geofenceListenerToken)
        }
        DeviceActionsInfoStore.shared.removeListener(token: actionInfoStoreChangeListener)
        updatedAtUpdatedTimer.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateDeviceInfoFields()
        imeiSelectionChangeListener()
        profileChangeListener()
        imeiChangeListenerToken = IMEISelectionManager.shared.addListener({ [weak self] in
            self?.imeiSelectionChangeListener()
        })
        
        profileChangeListenerToken = IMEISelectionManager.shared.addListener({ [weak self] in
            self?.profileChangeListener()
        })
        
        actionInfoStoreChangeListener = DeviceActionsInfoStore.shared.addListener { [weak self] (change) in
            self?.actionsInfoStoreChange(change)
        }
        
        if let device = IMEISelectionManager.shared.selectedDevice {
            geofenceListenerToken = GeofenceStore.shared.addListener(for: device.imei, listener: { [weak self] (imei) in
                if IMEISelectionManager.shared.selectedDevice?.imei == imei {
                    DispatchQueue.main.async {
                        self?.updateGeofenceFields()
                    }
                }
            })
        }
        
        updatedAtUpdatedTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] (_) in
            print("Got trigger")
            self?.updateDeviceInfoFields()
        }
    }
    
    func actionsInfoStoreChange(_ change: DeviceActionsInfoStoreChange) {
        switch change {
        case .addedForToday(let imei, let actionInfo):
            guard imei == IMEISelectionManager.shared.selectedDevice?.imei else { return }
            updateActionInfoDataLabels(actionInfo)
        case .updated(let imei, let dateComponents, let actionInfo):
            guard imei == IMEISelectionManager.shared.selectedDevice?.imei else { return }
            let todayDateComponents = DataPacketDateFormatter.yearMonthDayDateComponentsForNow()
            if todayDateComponents == dateComponents {
                updateActionInfoDataLabels(actionInfo)
            }
            
        default: break
            
        }
    }
    
    @IBAction func btnMapAction(_ sender: Any) {
        PostLoginRouter.showTabBarView()
    }
    
    @IBAction func btnMenuAction(_ sender: Any) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func imeiSelectionChangeListener() {
        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
        profileChangeListener()
        startObserving(device: device)
    }
    
    func profileChangeListener() {
        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
        guard let profile = device.profiles?.filter({ $0.profileType == IMEISelectionManager.shared.profileType.rawValue }).first else { return }
        lblProfileName.text = profile.name
        
    }
    
    func startObserving(device: Device) {
//        deviceInfoObjectObserver = ManagedObjectObserver(object: device.actionsInfo, changeHandler: objectChangeObserver(changeType:))
    }
    
    func objectChangeObserver(changeType: ManagedObjectObserver.ChangeType) {
        if changeType == .update{
            updateDeviceInfoFields()
        }
    }
    
    func updateDeviceInfoFields() {
        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
        guard let actionInfo = DeviceActionsInfoStore.shared.todaysActionInfo(for: device) else { return }
        updateActionInfoDataLabels(actionInfo)
    }
    
    func updateActionInfoDataLabels(_ actionsInfo: DeviceActionsInfo) {
        let location = CLLocation(latitude: actionsInfo.lat as CLLocationDegrees, longitude: actionsInfo.long as CLLocationDegrees)
        geoCoder.reverseGeocodeLocation(location) { [weak self](placemarks, error) in
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Address dictionary
            //print(placeMark.addressDictionary ?? "")
            
            // Location name
            var address = ""
            if let locationName = placeMark.name {
                //print(locationName)
                address += locationName
                
            }
            
            // Street address
            if let street = placeMark.thoroughfare {
                //print(street)
                address += ", \(street)"
            }
            
            // City
            if let city = placeMark.locality {
                //print(city)
                address += ", \(city)"
            }
            
            // Zip code
            if let zip = placeMark.postalCode {
                //print(zip)
                address += "-\(zip)"
            }
            
            // Country
            if let country = placeMark.country {
                //print(country)
                address += ", \(country)"
            }
            
            self?.lblCurrentLocation.text = address
        }

        batteryLabel.text = String(format: "%.0f", actionsInfo.battery) + "%"
        
        lblPlayinHours.text = "Playing" + "\n\(actionsInfo.secondsToHrminsecString(actionsInfo.running))"
        lblExploring.text = "Exploring" + "\n\(actionsInfo.secondsToHrminsecString(actionsInfo.exploring))"
        lblRestingHours.text = "Resting" + "\n\(actionsInfo.secondsToHrminsecString(actionsInfo.resting))"
        
        updateUpdatedAtLabels(for: actionsInfo.timeStamp)
    }
    
    func updateUpdatedAtLabels(for timeStamp: Date) {
        let timeStampYearMonthDay = DataPacketDateFormatter.calendar.dateComponents([.year, .month, .day], from: timeStamp)

        let currentDate = Date()
        let currentDateYearMonthDay = DataPacketDateFormatter.calendar.dateComponents([.year, .month, .day], from: currentDate)

        let text: String

        if timeStampYearMonthDay == currentDateYearMonthDay {
            let timeStampHourMinuteSecond = DataPacketDateFormatter.calendar.dateComponents([.hour, .minute, .second], from: timeStamp)
            let currentDateHourMinuteSecond = DataPacketDateFormatter.calendar.dateComponents([.hour, .minute, .second], from: currentDate)

            let timeStampSeconds = timeStampHourMinuteSecond.hour! * 60 * 60 + timeStampHourMinuteSecond.minute! * 60 + timeStampHourMinuteSecond.second!
            let currentDateSeconds = currentDateHourMinuteSecond.hour! * 60 * 60 + currentDateHourMinuteSecond.minute! * 60 + currentDateHourMinuteSecond.second!

            if currentDateSeconds - timeStampSeconds <= 60 {
                text = "Just Now"
            } else if currentDateSeconds - timeStampSeconds <= 180 {
                text = "A moment ago"
            } else  {
                dateFormatter.dateFormat = "hh:mm a"
                text = "Updated today at \(dateFormatter.string(from: timeStamp))"
            }

        } else if timeStampYearMonthDay.year == currentDateYearMonthDay.year &&
            timeStampYearMonthDay.month == currentDateYearMonthDay.month {
            if currentDateYearMonthDay.day! - timeStampYearMonthDay.day! == 1 {
                dateFormatter.dateFormat = "hh:mm a"
                text = "Updated yesterday at \(dateFormatter.string(from: timeStamp))"
            } else {
                dateFormatter.dateFormat = "dd MMM hh:mm a"
                text = "Updated on \(dateFormatter.string(from: timeStamp))"
            }
        } else if timeStampYearMonthDay.year == currentDateYearMonthDay.year {
            dateFormatter.dateFormat = "dd MMM hh:mm a"
            text = "Updated on \(dateFormatter.string(from: timeStamp))"
        } else {
            dateFormatter.dateFormat = "dd MMM hh:mm a"
            text = "Updated on \(dateFormatter.string(from: timeStamp))"
        }

        lblJustNow.text = text
        lblUpdatedAt.text = text
    }
    
    func updateGeofenceFields() {
        
    }
    
}

class HomeVCPlaceHolder: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PostLoginRouter.showHomeView()
    }
}

