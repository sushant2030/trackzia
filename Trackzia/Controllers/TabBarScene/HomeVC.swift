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
    var actionInfoStoreChangeListenerToken: DeviceActionsInfoStoreChangeToken!
    
    var deviceInfoObjectObserver: ManagedObjectObserver?
    
    var updatedAtFieldUpdaterTimer: Timer!
    
    
    var geofenceListenerToken: GeofenceStoreListenerToken!
    
    deinit {
        IMEISelectionManager.shared.removeListener(token: imeiChangeListenerToken)
        IMEISelectionManager.shared.removeProfileListener(token: profileChangeListenerToken)
        if let geofenceListenerToken = geofenceListenerToken {
            GeofenceStore.shared.removeListener(geofenceListenerToken)
        }
        DeviceActionsInfoStore.shared.removeListener(token: actionInfoStoreChangeListenerToken)
        updatedAtFieldUpdaterTimer.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imeiSelectionChangeListener()
        
        addImeiChangeListener()
        addProfileChangeListener()
        addActionInfoStoreChangeListener()
        
        if let device = IMEISelectionManager.shared.selectedDevice {
            addGeoFenceListener(forDevice: device)
        }
        
        updatedAtFieldUpdaterTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] (_) in
            guard let device = IMEISelectionManager.shared.selectedDevice else { return }
            guard let actionInfo = DeviceActionsInfoStore.shared.todaysActionInfo(for: device) else { return }
            self?.updateJustnowAndUpdatedAtLabels(for: actionInfo.timeStamp)
        }
    }
    
    func addImeiChangeListener() {
        imeiChangeListenerToken = IMEISelectionManager.shared.addListener({ [weak self] in
            self?.imeiSelectionChangeListener()
        })
    }
    
    func addProfileChangeListener() {
        profileChangeListenerToken = IMEISelectionManager.shared.addListener({ [weak self] in
            self?.profileChangeListener()
        })
    }
    
    func addActionInfoStoreChangeListener() {
        actionInfoStoreChangeListenerToken = DeviceActionsInfoStore.shared.addListener { [weak self] (change) in
            self?.actionsInfoStoreChange(change)
        }
    }
    
    func addGeoFenceListener(forDevice device: Device) {
        geofenceListenerToken.flatMap({
            GeofenceStore.shared.removeListener($0)
        })
        geofenceListenerToken = nil
        geofenceListenerToken = GeofenceStore.shared.addListener(for: device.imei, listener: { [weak self] (imei) in
            if IMEISelectionManager.shared.selectedDevice?.imei == imei {
                DispatchQueue.main.async {
                    // TODO: Update geofence
                    print("Can update geofence")
                }
            }
        })
    }
    
    func actionsInfoStoreChange(_ change: DeviceActionsInfoStoreChange) {
        switch change {
        case .addedForToday(let imei, let actionInfo):
            guard imei == IMEISelectionManager.shared.selectedDevice?.imei else { return }
            update(forActionInfo: actionInfo)
        case .updated(let imei, let dateComponents, let actionInfo):
            guard imei == IMEISelectionManager.shared.selectedDevice?.imei else { return }
            let todayDateComponents = DataPacketDateFormatter.yearMonthDayDateComponentsForNow()
            if todayDateComponents == dateComponents {
                update(forActionInfo: actionInfo)
            }
            
        default: break
        }
    }
    
    @IBAction func btnMapAction(_ sender: Any) {
        PostLoginRouter.showTabBarView()
    }
    
    @IBAction func btnMenuAction(_ sender: Any) {
    }
    

    func imeiSelectionChangeListener() {
        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
        update(forDevice: device)
    }
    
    func profileChangeListener() {
        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
        guard let profile = device.profiles?.filter({ $0.profileType == IMEISelectionManager.shared.profileType.rawValue }).first else { return }
        update(forProfile: profile)
    }
}

extension HomeVC {
    func update(forDevice device: Device) {
        guard let profile = device.profiles?.filter({ $0.profileType == IMEISelectionManager.shared.profileType.rawValue }).first else { return }
        update(forProfile: profile)
        
        guard let actionInfo = DeviceActionsInfoStore.shared.todaysActionInfo(for: device) else { return }
        update(forActionInfo: actionInfo)
    }
}

extension HomeVC {
    func update(forActionInfo actionInfo: DeviceActionsInfo) {
        updateJustnowAndUpdatedAtLabels(for: actionInfo.timeStamp)
        let location = CLLocation(latitude: actionInfo.lat as CLLocationDegrees, longitude: actionInfo.long as CLLocationDegrees)
        updateAddressField(forLocation: location)
        updateBatteryField(value: actionInfo.battery)
        updateRunningExploringResting(actionInfo: actionInfo)
        updateGeoFenceData(actionInfo: actionInfo)
    }
    
    func updateJustnowAndUpdatedAtLabels(for timeStamp: Date) {
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
    
    func updateAddressField(forLocation location: CLLocation) {
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
    }
    
    func updateBatteryField(value: Float) {
        batteryLabel.text = String(format: "%.0f", value) + "%"
    }
    
    func updateRunningExploringResting(actionInfo: DeviceActionsInfo) {
        lblPlayinHours.text = "Playing" + "\n\(actionInfo.secondsToHrminsecString(actionInfo.running))"
        lblExploring.text = "Exploring" + "\n\(actionInfo.secondsToHrminsecString(actionInfo.exploring))"
        lblRestingHours.text = "Resting" + "\n\(actionInfo.secondsToHrminsecString(actionInfo.resting))"
    }
}

extension HomeVC {
    
    func updateGeoFenceData(actionInfo: DeviceActionsInfo) {
        guard let device = IMEISelectionManager.shared.selectedDevice, device.imei == actionInfo.imei else { return }
        guard let geofences = device.geoFences?.filter({ !$0.name.isEmpty && $0.name != "0" && $0.name.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 }) else {
            lblDetail.text = nil
            return
        }
        
        let hourMinSecComponents = DataPacketDateFormatter.hourMinuteSecondsForNow()
        let secondsNow = hourMinSecComponents.hour! * 60 * 60 + hourMinSecComponents.minute! * 60
        
        let actlong = CLLocationDegrees(actionInfo.long)
        let actlat = CLLocationDegrees(actionInfo.lat)
        let actLocation = CLLocation(latitude: actlat, longitude: actlong)
        
        // Get geofences whose time range includes secondsNow
        var timeValidGeofences = geofences.filter {
            if $0.type != GeoFenceType.lock.rawValue {
                if let startHourMin = $0.startTime?.split(separator: ":"), let endHourMin = $0.endTime?.split(separator: ":") {
                    if startHourMin.count == 2 && endHourMin.count == 2 {
                        if let startHour = Int(startHourMin[0]), let startMin = Int(startHourMin[1]), let endHour = Int(endHourMin[0]), let endMin = Int(endHourMin[1]) {
                            let startSeconds = startHour * 60 * 60 + startMin * 60
                            let endSeconds = endHour * 60 * 60 + endMin * 60
                            if startSeconds <= secondsNow && endSeconds >= secondsNow {
                                return true
                            }
                        }
                    }
                }
            }
            return false
        }
        
        if timeValidGeofences.count == 0 {
            lblDetail.text = "No geofences for now"
            lblCurrentDistance.text = nil
            lblUpdatedAt.text = nil
            return
        }
        
        // Get distances
        let distanceRadiusGeoFences:[(distance: CLLocationDistance, radius: CLLocationDistance, geoFence:GeoFence)] = timeValidGeofences.map {
            let latitude = CLLocationDegrees($0.lat)!
            let longitude = CLLocationDegrees($0.long)!
            let geoFenceCenterLocation = CLLocation(latitude: latitude, longitude: longitude)
            let distanceFromGeoFenceCenter = geoFenceCenterLocation.distance(from: actLocation)
            return (distanceFromGeoFenceCenter, CLLocationDistance($0.radius)!, $0)
        }
        
        // Get geofences who we are inside
        let inside = distanceRadiusGeoFences.filter {
            $0.distance <= $0.radius
        }
        
        // If we are inside then show
        if inside.count > 0 {
            let min = inside.reduce(inside[0]) { $1.distance < $0.distance ? $1 : $0 }
            lblDetail.text = "I am inside \(min.geoFence.name)"
            lblUpdatedAt.text = "Just now"
            
            let lengthmeasurementInKM = Measurement(value: min.distance, unit: UnitLength.meters).converted(to: .kilometers)
            lblCurrentDistance.text = String(format: "Current Location Distance %.2f Km", lengthmeasurementInKM.value)

            return
        } else {
            // We are not, show the closest geofence
            let min = distanceRadiusGeoFences.reduce(inside[0]) { $1.distance < $0.distance ? $1 : $0 }
            lblDetail.text = "I am outside \(min.geoFence.name)"
            
            lblUpdatedAt.text = "Just now"
            
            let lengthmeasurementInKM = Measurement(value: min.distance, unit: UnitLength.meters).converted(to: .kilometers)
            lblCurrentDistance.text = String(format: "Current Location Distance %.2f Km", lengthmeasurementInKM.value)
        }
        
        
//        if geofence.type == "GeoLock" {
//
//        } else {
//            let components = DataPacketDateFormatter.hourMinuteSecondsForNow()
//            let startHour = Int(geofence.startTime!.split(separator: ":").first!)!
//            let startMinutes = Int(geofence.startTime!.split(separator: ":").last!)!
//            let startSeconds = startHour * 60 * 60 + startMinutes * 60
//
//            let endHour = Int(geofence.endTime!.split(separator: ":").first!)!
//            let endMinutes = Int(geofence.endTime!.split(separator: ":").last!)!
//            let endSeconds = endHour * 60 * 60 + endMinutes * 60
//
//            let nowSeconds = components.hour! * 60 * 60 + components.minute! * 60
//            let name = geofence.name
//
//            if nowSeconds >= startSeconds && nowSeconds <= endSeconds {
//                let actlong = CLLocationDegrees(actionInfo.long)
//                let actlat = CLLocationDegrees(actionInfo.lat)
//                let actLocation = CLLocation(latitude: actlong, longitude: actlat)
//
//
//                let latitude = CLLocationDegrees(geofence.lat)!
//                let longitude = CLLocationDegrees(geofence.long)!
//                let geoFenceCenterLocation = CLLocation(latitude: latitude, longitude: longitude)
//
//                let distanceFromGeoFenceCenter = geoFenceCenterLocation.distance(from: actLocation)
//                if distanceFromGeoFenceCenter <= CLLocationDistance(geofence.radius)! {
//                    lblDetail.text = "I am inside \(name)"
//                } else {
//                    lblDetail.text = "I am outside \(name)"
//                }
//
//                let lengthmeasurementInKM = Measurement(value: distanceFromGeoFenceCenter, unit: UnitLength.meters).converted(to: .kilometers)
//                lblCurrentDistance.text = "Current Location Distance \(lengthmeasurementInKM.value)"
//            } else {
//                lblDetail.text = nil
//            }
//        }
    }
//    func updateGeoFenceData(actionInfo: DeviceActionsInfo) {
//        guard let device = IMEISelectionManager.shared.selectedDevice, device.imei == actionInfo.imei else { return }
//        guard let geofence = device.geoFences?.filter({ !$0.name.isEmpty }).first else {
//            lblDetail.text = nil
//            return
//        }
//
//        if geofence.type == "GeoLock" {
//
//        } else {
//            let components = DataPacketDateFormatter.hourMinuteSecondsForNow()
//            let startHour = Int(geofence.startTime!.split(separator: ":").first!)!
//            let startMinutes = Int(geofence.startTime!.split(separator: ":").last!)!
//            let startSeconds = startHour * 60 * 60 + startMinutes * 60
//
//            let endHour = Int(geofence.endTime!.split(separator: ":").first!)!
//            let endMinutes = Int(geofence.endTime!.split(separator: ":").last!)!
//            let endSeconds = endHour * 60 * 60 + endMinutes * 60
//
//            let nowSeconds = components.hour! * 60 * 60 + components.minute! * 60
//            let name = geofence.name
//
//            if nowSeconds >= startSeconds && nowSeconds <= endSeconds {
//                let actlong = CLLocationDegrees(actionInfo.long)
//                let actlat = CLLocationDegrees(actionInfo.lat)
//                let actLocation = CLLocation(latitude: actlong, longitude: actlat)
//
//
//                let latitude = CLLocationDegrees(geofence.lat)!
//                let longitude = CLLocationDegrees(geofence.long)!
//                let geoFenceCenterLocation = CLLocation(latitude: latitude, longitude: longitude)
//
//                let distanceFromGeoFenceCenter = geoFenceCenterLocation.distance(from: actLocation)
//                if distanceFromGeoFenceCenter <= CLLocationDistance(geofence.radius)! {
//                    lblDetail.text = "I am inside \(name)"
//                } else {
//                    lblDetail.text = "I am outside \(name)"
//                }
//
//                let lengthmeasurementInKM = Measurement(value: distanceFromGeoFenceCenter, unit: UnitLength.meters).converted(to: .kilometers)
//                lblCurrentDistance.text = "Current Location Distance \(lengthmeasurementInKM.value)"
//            } else {
//                lblDetail.text = nil
//            }
//        }
//    }
}

extension HomeVC {
    func update(forProfile profile: Profile) {
        lblProfileName.text = profile.name
    }
}

class HomeVCPlaceHolder: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PostLoginRouter.showHomeView()
    }
}

