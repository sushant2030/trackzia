//
//  CurrentLocationViewController.swift
//  Trackzia
//
//  Created by Rohan Bhale on 23/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit
import MapKit

class CurrentLocationVC: UIViewController {
    @IBOutlet var liveButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    var region:MKCoordinateRegion!
    
    var deviceInfoObjectObserver: ManagedObjectObserver?
    
    
    @IBOutlet var lblProfileName: UILabel!
    @IBOutlet var lblJustNow: UILabel!
    @IBOutlet var lblCurrentLocation: UILabel!
    
    @IBOutlet var lblUpdatedAt: UILabel!
    
    let geoCoder = CLGeocoder()
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.timeZone = DataPacketDateFormatter.dateFormatter.timeZone
        return dateFormatter
    }()
    
    var updatedAtFieldUpdaterTimer: Timer!
    
    var liveUpdatesTimer: Timer?
    
    var actionInfoStoreChangeListenerToken: DeviceActionsInfoStoreChangeToken!
    
    var currentAnnotation: MKPointAnnotation?
    var liveUpdateInterval: TimeInterval = 35
    
    deinit {
        updatedAtFieldUpdaterTimer.invalidate()
        liveUpdatesTimer?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        liveButton.layer.cornerRadius = 7.0
        region = mapView.region
        
        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
        guard let profile = device.profiles?.filter({ $0.profileType == IMEISelectionManager.shared.profileType.rawValue }).first else { return }
        update(forProfile: profile)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addActionInfoStoreChangeListener()
        
        updatedAtFieldUpdaterTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] (_) in
            guard let device = IMEISelectionManager.shared.selectedDevice else { return }
            guard let actionInfo = DeviceActionsInfoStore.shared.todaysActionInfo(for: device) else { return }
            self?.updateJustnowAndUpdatedAtLabels(for: actionInfo.timeStamp)
        }
        
        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
        guard let actionInfo = DeviceActionsInfoStore.shared.todaysActionInfo(for: device) else { return }
        update(forActionInfo: actionInfo)
        
//        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
//        updateDeviceInfoFields()
//        profileChangeListener()
//        startObserving(device: device)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updatedAtFieldUpdaterTimer.invalidate()
        liveUpdatesTimer?.invalidate()
        
        removeActionInfoStoreChangeListener()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        liveButton.isHidden = false
    }
    
    
    
    
    //-------------------------------------------------------------------------------------
    
    func addActionInfoStoreChangeListener() {
        actionInfoStoreChangeListenerToken = DeviceActionsInfoStore.shared.addListener { [weak self] (change) in
            self?.actionsInfoStoreChange(change)
        }
    }
    
    func removeActionInfoStoreChangeListener() {
        DeviceActionsInfoStore.shared.removeListener(token: actionInfoStoreChangeListenerToken)
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
    
    
    //-------------------------------------------------------------------------------------

    
    private func registerDelegatesSetupViews() {
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    func setupViewWithLatAndLong(lat:Float,long:Float){
        region.center = CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(long))
        region.span.longitudeDelta /= 1.0
        region.span.latitudeDelta /= 1.0
        mapView .setRegion(region, animated: false)
        
    }
    
    func setupMapWIthMultipleAnnotations(locations:[LocationDetailModel]) {
        let annotations = locations.map { location -> MKAnnotation in
            let annotation = MKPointAnnotation()
            annotation.title = location.title
            let lat = Double(location.latitude);
            let long = Double(location.longitude)
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat ?? 0.0, longitude: long ?? 0.0)
            return annotation
        }
        mapView.addAnnotations(annotations)
    }
    
    func startObserving(device: Device) {
//        deviceInfoObjectObserver = ManagedObjectObserver(object: device.actionsInfo, changeHandler: { [weak self](changeType) in
//            self?.objectChangeObserver(changeType: changeType)
//        })
    }
    
    func objectChangeObserver(changeType: ManagedObjectObserver.ChangeType) {
        if changeType == .update{
            updateDeviceInfoFields()
        }
    }
    
    func updateDeviceInfoFields() {
//        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
//        let actionsInfo = device.actionsInfo
//        let location = CLLocation(latitude: actionsInfo.lat as CLLocationDegrees, longitude: actionsInfo.long as CLLocationDegrees)
//        geoCoder.reverseGeocodeLocation(location) { [weak self](placemarks, error) in
//            var placeMark: CLPlacemark!
//            placeMark = placemarks?[0]
//
//            // Address dictionary
//            //print(placeMark.addressDictionary ?? "")
//
//            // Location name
//            var address = ""
//            if let locationName = placeMark.name {
//                //print(locationName)
//                address += locationName
//
//            }
//
//            // Street address
//            if let street = placeMark.thoroughfare {
//                //print(street)
//                address += ", \(street)"
//            }
//
//            // City
//            if let city = placeMark.locality {
//                //print(city)
//                address += ", \(city)"
//            }
//
//            // Zip code
//            if let zip = placeMark.postalCode {
//                //print(zip)
//                address += "-\(zip)"
//            }
//
//            // Country
//            if let country = placeMark.country {
//                //print(country)
//                address += ", \(country)"
//            }
//
//            self?.lblCurrentLocation.text = address
//        }
//
//        updateUpdatedAtLabels(for: actionsInfo.timeStamp)
//        updateMapView(for: device)
    }
    
    func profileChangeListener() {
        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
        guard let profile = device.profiles?.filter({ $0.profileType == IMEISelectionManager.shared.profileType.rawValue }).first else { return }
        lblProfileName.text = profile.name
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
    
//    func updateMapView(for device: Device) {
//        let actionsInfo = device.actionsInfo
//
//
//        let coordinate2D = CLLocationCoordinate2D(latitude: actionsInfo.lat as CLLocationDegrees, longitude: actionsInfo.long as CLLocationDegrees)
//        let region = MKCoordinateRegion(center: coordinate2D, latitudinalMeters: 10000, longitudinalMeters: 10000)
//        mapView.setRegion(region, animated: true)
//
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = coordinate2D
//        annotation.title = "\(coordinate2D.latitude, coordinate2D.longitude)"
//        mapView.addAnnotation(annotation)
//    }
    
    @IBAction func liveButtonTapped(_ sender: UIButton) {
        sender.isHidden = true
        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
        DeviceActionsInfoStore.shared.update(forDevice: device, forceUpdate: true)
        liveUpdatesTimer = Timer.scheduledTimer(withTimeInterval: liveUpdateInterval, repeats: true, block: { _ in
            guard let device = IMEISelectionManager.shared.selectedDevice else { return }
            print("Updating packets")
            DeviceActionsInfoStore.shared.update(forDevice: device, forceUpdate: true)
        })
    }
    
    
    
    
    // TODO: New Implementations
    
    
    
    
    
    
}

extension CurrentLocationVC {
    func update(forActionInfo actionInfo: DeviceActionsInfo) {
        updateJustnowAndUpdatedAtLabels(for: actionInfo.timeStamp)
        let location = CLLocation(latitude: actionInfo.lat as CLLocationDegrees, longitude: actionInfo.long as CLLocationDegrees)
        updateAddressField(forLocation: location)
        updateMapPin(actionInfo: actionInfo)
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
    
    func updateMapPin(actionInfo: DeviceActionsInfo) {
        let coordinate2D = CLLocationCoordinate2D(latitude: actionInfo.lat as CLLocationDegrees, longitude: actionInfo.long as CLLocationDegrees)
        let region = MKCoordinateRegion(center: coordinate2D, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
        
        currentAnnotation.flatMap({ self.mapView.removeAnnotation($0) })
        currentAnnotation = MKPointAnnotation()
        currentAnnotation?.coordinate = coordinate2D
        currentAnnotation?.title = "\(coordinate2D.latitude, coordinate2D.longitude)"
        currentAnnotation.flatMap({ self.mapView.addAnnotation($0) })
        print("Updated annotation")
    }
}

extension CurrentLocationVC {
    func update(forProfile profile: Profile) {
        lblProfileName.text = profile.name
    }
}


extension CurrentLocationVC : MKMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        
    }
    
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        
    }
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
    }
}

