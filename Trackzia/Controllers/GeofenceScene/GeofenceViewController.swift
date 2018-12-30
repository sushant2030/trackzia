//
//  GeofenceViewController.swift
//  Trackzia
//
//  Created by Rohan Bhale on 08/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import MapKit

class GeofenceViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    
    var selectedGeoFenceType = GeoFenceType.home {
        didSet {
            if oldValue != selectedGeoFenceType {
                if let device = IMEISelectionManager.shared.selectedDevice {
                    updateView(for: device)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeButtonAppearance()
        
        if let device = IMEISelectionManager.shared.selectedDevice {
            updateView(for: device)
            UserDataManager.shared.getGeoFenceDetails(imei: device.imei) { [weak self](imei) in
                if device.imei == imei {
                    DispatchQueue.main.async {
                        self?.updateView(for: device)
                    }
                    
                }
            }
        }
        
    }
    
    func customizeButtonAppearance() {
        let buttonCornerRadius: CGFloat = 19
        deleteButton.layer.cornerRadius = buttonCornerRadius
        saveButton.layer.cornerRadius = buttonCornerRadius
        saveButton.layer.borderColor = deleteButton.backgroundColor?.cgColor
        saveButton.layer.borderWidth = 1.0
        
    }
    
    func updateView(for device: Device) {
        nameTextField.text = device.geoFences?.filter({ $0.type == selectedGeoFenceType.rawValue }).first?.name ?? "0"
    }
    
    @IBAction func homeButtonTapped(_ sender: Any) {
        selectedGeoFenceType = .home
    }
    
    @IBAction func schoolButtonTouched(_ sender: Any) {
        selectedGeoFenceType = .school
    }
    
    
    @IBAction func playgroundButtonTouched(_ sender: Any) {
        selectedGeoFenceType = .playGround
    }
    
    @IBAction func otherButtonTouched(_ sender: Any) {
        selectedGeoFenceType = .other
    }
    
    @IBAction func lockButtonTouched(_ sender: Any) {
        selectedGeoFenceType = .lock
    }
    
}


