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
        guard let geoFence = device.geoFences?.filter({ $0.type == selectedGeoFenceType.rawValue }).first else {
            nameTextField.text = "0"
            return
        }
        
        nameTextField.text = geoFence.name
        guard geoFence.lat != "0" && geoFence.long != "0" else { return }
        guard let latitude = CLLocationDegrees(geoFence.lat) else { return }
        guard let longitude = CLLocationDegrees(geoFence.long) else { return }
        
        let coordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: coordinate2D, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
    
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate2D
        annotation.title = "\(coordinate2D.latitude, coordinate2D.longitude)"
        mapView.addAnnotation(annotation)
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


