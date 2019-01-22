//
//  ActivityVC.swift
//  Trackzia
//
//  Created by Rohan Bhale on 20/01/19.
//  Copyright © 2019 Private. All rights reserved.
//

import UIKit
import CoreLocation

class ActivityVC: UIViewController {
    @IBOutlet var lblProfileName: UILabel!
    @IBOutlet var lblJustNow: UILabel!
    @IBOutlet var lblCurrentLocation: UILabel!
    
    @IBOutlet var lblRestingHours: UILabel!
    @IBOutlet var lblExploring: UILabel!
    @IBOutlet var lblPlayinHours: UILabel!
    
    @IBOutlet var datePicker: UIDatePicker!
    
    var packets: [DataPacket] = [] {
        didSet {
            
        }
    }
    
    let geoCoder = CLGeocoder()
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.timeZone = DataPacketDateFormatter.dateFormatter.timeZone
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateProfileName()
        
        datePicker.calendar = DataPacketDateFormatter.calendar
        datePicker.date = Date()
    }
    
    
    func updateProfileName() {
        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
        guard let profile = device.profiles?.filter({ $0.profileType == IMEISelectionManager.shared.profileType.rawValue }).first else { return }
        lblProfileName.text = profile.name
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
//        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
//        let pickerDate = datePicker.date
//        var components = DataPacketDateFormatter.calendar.dateComponents([.year, .month, .day], from: pickerDate)
//        components.hour = 0
//        components.minute = 0
//        components.second = 0
//        let date = DataPacketDateFormatter.calendar.date(from: components)!
//        
//        packets.removeAll()
//        
//        DeviceActionsInfoStore.shared.getPackets(for: device, for: date) { [weak self] dataPacketsTuple in
//            
//            if let pickerDate = self?.datePicker.date {
//                var components = DataPacketDateFormatter.calendar.dateComponents([.year, .month, .day], from: pickerDate)
//                components.hour = 0
//                components.minute = 0
//                components.second = 0
//                let date = DataPacketDateFormatter.calendar.date(from: components)!
//                
//                if date.compare(dataPacketsTuple.date) == .orderedSame {
//                    self?.packets = dataPacketsTuple.allPackets
//                }
//            }
//            
//        }
    }
}