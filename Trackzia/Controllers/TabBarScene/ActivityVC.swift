//
//  ActivityVC.swift
//  Trackzia
//
//  Created by Rohan Bhale on 20/01/19.
//  Copyright © 2019 Private. All rights reserved.
//

import UIKit
import CoreLocation
import Charts
import FSCalendar

class ActivityVC: UIViewController {
    @IBOutlet var lblProfileName: UILabel!
    @IBOutlet var lblJustNow: UILabel!
    @IBOutlet var lblCurrentLocation: UILabel!
    
    @IBOutlet var lblRestingHours: UILabel!
    @IBOutlet var lblExploring: UILabel!
    @IBOutlet var lblPlayinHours: UILabel!
    
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var calendarView: FSCalendar!
    
    var datePicked: Date! {
        didSet {
            if oldValue != datePicked {
                dateComponentsOfDatePicked = DataPacketDateFormatter.calendar.dateComponents([.year, .month, .day], from: datePicked)
                didPickDate()
            }
        }
    }
    
    var dateComponentsOfDatePicked: DateComponents!
    
    var device: Device!
    
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
    
    var actionInfoStoreChangeListenerToken: DeviceActionsInfoStoreChangeToken!
    
    deinit {
        DeviceActionsInfoStore.shared.removeListener(token: actionInfoStoreChangeListenerToken)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateProfileName()
        
        device = IMEISelectionManager.shared.selectedDevice!
        
        configureCalendarView()
        datePicked = calendarView.selectedDate!
        
        
        barChart.xAxis.enabled = true
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.xAxis.drawAxisLineEnabled = true
        barChart.xAxis.axisLineColor = .red
    
        barChart.getAxis(.left).enabled = false
        barChart.getAxis(.right).enabled = false
        
        addActionInfoStoreChangeListener()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var calendarWeekdayViewFrame = calendarView.calendarWeekdayView.frame
        var collectionViewFrame = calendarView.collectionView.frame
        
        collectionViewFrame.origin.y = calendarWeekdayViewFrame.origin.y
        calendarWeekdayViewFrame.origin.y = collectionViewFrame.maxY
        
        calendarView.calendarWeekdayView.frame = calendarWeekdayViewFrame
        calendarView.collectionView.frame = collectionViewFrame
    }
    
    func configureCalendarView() {
        calendarView.select(Date())
        calendarView.setScope(.week, animated: false)
        calendarView.headerHeight = 0
    }
    
    func addActionInfoStoreChangeListener() {
        actionInfoStoreChangeListenerToken = DeviceActionsInfoStore.shared.addListener { [weak self] (change) in
            self?.actionsInfoStoreChange(change)
        }
    }
    
    
    func updateProfileName() {
        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
        guard let profile = device.profiles?.filter({ $0.profileType == IMEISelectionManager.shared.profileType.rawValue }).first else { return }
        lblProfileName.text = profile.name
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        print("datePickerValueChanged*******************************")
//        datePicked = datePicker.date
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
    
    func actionsInfoStoreChange(_ change: DeviceActionsInfoStoreChange) {
        switch change {
        case .addedForToday(let imei, let actionInfo):
            guard imei == IMEISelectionManager.shared.selectedDevice?.imei else { return }
            update(forActionInfo: actionInfo)
        case .updated(let imei, let dateComponents, let actionInfo):
            guard imei == IMEISelectionManager.shared.selectedDevice?.imei else { return }
            if dateComponentsOfDatePicked == dateComponents {
                update(forActionInfo: actionInfo)
            }
            
        default: break
        }
    }
}

extension ActivityVC: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("Date selected")
        datePicked = date
    }
}

extension ActivityVC {
    func update(forActionInfo actionInfo: DeviceActionsInfo) {
        updateView(forActionInfo: actionInfo)
    }
}

extension ActivityVC {
    func didPickDate() {
        if let actionInfo = DeviceActionsInfoStore.shared.actionInfo(forDevice: device, year: dateComponentsOfDatePicked.year!, month: dateComponentsOfDatePicked.month!, day: dateComponentsOfDatePicked.day!) {
            updateView(forActionInfo: actionInfo)
        } else {
            updateBarChart(withSpeedValues: Array<Double>(repeating: 0, count: 24))
            DeviceActionsInfoStore.shared.updateActionInfo(forDevice: device, forDateComponents: dateComponentsOfDatePicked)
        }
    }
    
    func updateView(forActionInfo actionInfo: DeviceActionsInfo) {
        let dateComponents = DataPacketDateFormatter.calendar.dateComponents([.year, .month, .day], from: actionInfo.timeStamp)
        let maxSpeedValuesForEachHour: [Double] = DeviceActionsInfoStore.shared.maxSpeedValuesForEachHourOfDay(forDevice: device, represntedByDateComponents: dateComponents, secondsFromGMT: DataPacketDateFormatter.secondsFromGMT)
        updateBarChart(withSpeedValues: maxSpeedValuesForEachHour)
    }
    
    func updateBarChart(withSpeedValues speedValues: [Double]) {
        var entries = [BarChartDataEntry]()
        for (index, value) in speedValues.enumerated() {
            let entry = BarChartDataEntry(x: Double(index + 1), y: value)
            entries.append(entry)
        }
        let dataSet = BarChartDataSet(values: entries, label: "Max speed")
        dataSet.colors = [UIColor(red: CGFloat(23.0 / 255.0), green: CGFloat( 201.0 / 255.0), blue: CGFloat(214.0 / 255.0), alpha: 1.0)]
        dataSet.drawValuesEnabled = false
        let data = BarChartData(dataSets: [dataSet])
        barChart.data = data
        barChart.chartDescription?.text = "Max speed every hour of the day"
        barChart.notifyDataSetChanged()
        
    }
}
