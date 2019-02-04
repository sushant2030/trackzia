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
    
    @IBOutlet var detailsFieldBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet var overlayView: UIView!
    @IBOutlet var overlayGeofenceTypeLabel: UILabel!
    @IBOutlet var overlayRadiusTextField: UITextField!
    @IBOutlet var overlayStartTimeTextField: UITextField!
    @IBOutlet var overlayEndTimeTimeTextField: UITextField!
    
    @IBOutlet var overlayRadiusStackView: UIStackView!
    @IBOutlet var overlayStartTimeStackView: UIStackView!
    @IBOutlet var overlayEndTimeStackView: UIStackView!
    
    @IBOutlet var overlayContainerView: UIView!
    
    @IBOutlet var addButton: UIButton!
    
    @IBOutlet var geofenceButtonsStackView: UIStackView!
    
    var selectedGeoFenceType = GeoFenceType.home {
        didSet {
            if oldValue != selectedGeoFenceType {
                if let device = IMEISelectionManager.shared.selectedDevice {
                    updateView(for: device)
                }
            }
        }
    }
    
    var geofenceListenerToken: GeofenceStoreListenerToken!
    
    lazy var geofenceButtonsArray: [UIButton] = {
       var array = [UIButton]()
        return geofenceButtonsStackView.arrangedSubviews as! [UIButton]
    }()
    
    @IBOutlet var homeGeofenceButton: UIButton!
    @IBOutlet var schoolGeofenceButton: UIButton!
    @IBOutlet var playgroundGeofenceButton: UIButton!
    @IBOutlet var otherGeofenceButton: UIButton!
    @IBOutlet var lockGeofenceButton: UIButton!
    
    deinit {
        GeofenceStore.shared.removeListener(geofenceListenerToken)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeTextFields()
        customizeButtonAppearance()
        preselectButton()
        if let device = IMEISelectionManager.shared.selectedDevice {
            updateView(for: device)
            
            geofenceListenerToken = GeofenceStore.shared.addListener(for: device.imei, listener: { [weak self] (imei) in
                if IMEISelectionManager.shared.selectedDevice?.imei == imei {
                    DispatchQueue.main.async {
                        self?.updateView(for: device)
                    }
                }
            })
        }
        
        overlayContainerView.layer.cornerRadius = 20
        overlayContainerView.layer.masksToBounds = true
    }
    
    func customizeTextFields() {
        let pickerViewFrame = CGRect(x: 0, y: 0, width: 800, height: 300)
        var textFieldTimePickerView = TextFieldTimePicker(frame: pickerViewFrame)
        overlayStartTimeTextField.inputView = textFieldTimePickerView
        textFieldTimePickerView.cancelHandler = { [weak self] in
            self?.overlayStartTimeTextField.resignFirstResponder()
        }
        
        textFieldTimePickerView.selectionHandler = { [weak self] (hr, min) in
            self?.overlayStartTimeTextField.text = String(format: "%02d:%02d", hr, min)
        }
        
        textFieldTimePickerView = TextFieldTimePicker(frame:pickerViewFrame)
        overlayEndTimeTimeTextField.inputView = textFieldTimePickerView
        textFieldTimePickerView.cancelHandler = { [weak self] in
            self?.overlayEndTimeTimeTextField.resignFirstResponder()
        }
        textFieldTimePickerView.selectionHandler = { [weak self] (hr, min) in
            self?.overlayStartTimeTextField.text = String(format: "%02d:%02d", hr, min)
        }
    }
    
    func customizeButtonAppearance() {
        let buttonCornerRadius: CGFloat = 19
        deleteButton.layer.cornerRadius = buttonCornerRadius
        saveButton.layer.cornerRadius = buttonCornerRadius
        saveButton.layer.borderColor = deleteButton.backgroundColor?.cgColor
        saveButton.layer.borderWidth = 1.0
        
        addButton.layer.cornerRadius = 16
        addButton.layer.borderColor = deleteButton.backgroundColor?.cgColor
        addButton.layer.borderWidth = 1.0
        
        let homeImage = UIImage(named: "home_icon")!.withRenderingMode(.alwaysTemplate)
        homeGeofenceButton.setBackgroundImage(homeImage, for: .normal)
        
        let schoolImage = UIImage(named: "school_icon")!.withRenderingMode(.alwaysTemplate)
        schoolGeofenceButton.setBackgroundImage(schoolImage, for: .normal)
        
        let playgroundImage = UIImage(named: "garden_icon")!.withRenderingMode(.alwaysTemplate)
        playgroundGeofenceButton.setBackgroundImage(playgroundImage, for: .normal)
        
        let oetherImage = UIImage(named: "other2_icon")!.withRenderingMode(.alwaysTemplate)
        otherGeofenceButton.setBackgroundImage(oetherImage, for: .normal)
        
        let lockImage = UIImage(named: "lock_geo_fence2")!.withRenderingMode(.alwaysTemplate)
        lockGeofenceButton.setBackgroundImage(lockImage, for: .normal)
    }
    
    func preselectButton() {
        buttonSelected(homeGeofenceButton)
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
    
    @IBAction func homeButtonTapped(_ sender: UIButton) {
        selectedGeoFenceType = .home
        buttonSelected(sender)
    }
    
    @IBAction func schoolButtonTouched(_ sender: UIButton) {
        selectedGeoFenceType = .school
        buttonSelected(sender)
    }
    
    
    @IBAction func playgroundButtonTouched(_ sender: UIButton) {
        selectedGeoFenceType = .playGround
        buttonSelected(sender)
    }
    
    @IBAction func otherButtonTouched(_ sender: UIButton) {
        selectedGeoFenceType = .other
        buttonSelected(sender)
    }
    
    @IBAction func lockButtonTouched(_ sender: UIButton) {
        selectedGeoFenceType = .lock
        buttonSelected(sender)
    }
    
    
    func buttonSelected(_ button: UIButton) {
        for (_,geofenceButton) in geofenceButtonsArray.enumerated() {
            if geofenceButton === button {
                geofenceButton.tintColor = deleteButton.backgroundColor
            } else {
                geofenceButton.tintColor = .darkGray
            }
        }
    }
}


extension GeofenceViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        return true
    }
}

extension GeofenceViewController {
    @objc func keyboardDidShow(_ notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        guard let userInfo = notification.userInfo else { return }
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let targetFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = curFrame.origin.y - targetFrame.origin.y
        
        UIView.animate(withDuration: duration) { [weak self] in
            self?.detailsFieldBottomConstraint.constant = deltaY
        }
        
    }
    
    @objc func keyboardDidHide(_ notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        guard let userInfo = notification.userInfo else { return }
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: duration) { [weak self] in
            self?.detailsFieldBottomConstraint.constant = 0
        }
    }
}

extension GeofenceViewController {
    @IBAction func showOverlayButtonTapped() {
        overlayGeofenceTypeLabel.text = selectedGeoFenceType.rawValue
        overlayView.isHidden = false
    }
    
    @IBAction func overlayButtonTapped() {
        overlayView.isHidden = true
        self.view.endEditing(true)
    }
    
    @IBAction func addGeofenceRadiusAndDuration() {
        
    }
}
