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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeButtonAppearance()
    }
    
    func customizeButtonAppearance() {
        let buttonCornerRadius: CGFloat = 19
        deleteButton.layer.cornerRadius = buttonCornerRadius
        saveButton.layer.cornerRadius = buttonCornerRadius
        saveButton.layer.borderColor = deleteButton.backgroundColor?.cgColor
        saveButton.layer.borderWidth = 1.0
        
    }
}
