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
    
    var geofenceListenerToken: GeofenceStoreListenerToken!
    
    var currentAnnotation: MKPointAnnotation?
    var editedLocationAnnotation: MKPointAnnotation?
    
    lazy var geofenceButtonsArray: [UIButton] = {
        var array = [UIButton]()
        return geofenceButtonsStackView.arrangedSubviews as! [UIButton]
    }()
    
    @IBOutlet var homeGeofenceButton: UIButton!
    @IBOutlet var schoolGeofenceButton: UIButton!
    @IBOutlet var playgroundGeofenceButton: UIButton!
    @IBOutlet var otherGeofenceButton: UIButton!
    @IBOutlet var lockGeofenceButton: UIButton!
    
    lazy var editedValues: EditedValues = {
        return EditedValues(name: nil, radius: nil, startTime: nil, endTime: nil)
    }()
    
    var selectedGeoFenceType = GeoFenceType.home {
        didSet {
            if oldValue != selectedGeoFenceType {
                if let device = IMEISelectionManager.shared.selectedDevice {
                    editedValues.reset()
                    editedStartTime.hour = nil
                    editedStartTime.minute = nil
                    
                    editedEndTime.hour = nil
                    editedEndTime.minute = nil
                    
                    currentAnnotation.flatMap({ mapView.removeAnnotation($0) })
                    currentAnnotation = nil
                    
                    editedLocationAnnotation.flatMap({ mapView.removeAnnotation($0) })
                    editedLocationAnnotation = nil
                    updateView(for: device)
                }
            }
        }
    }
    
    var editedStartTime: (hour: Int?, minute: Int?) = (nil, nil)
    var editedEndTime: (hour: Int?, minute: Int?) = (nil, nil)
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    deinit {
        GeofenceStore.shared.removeListener(geofenceListenerToken)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMapView()
        
        customizeTextFields()
        customizeButtonAppearance()
        preselectButton()
        if let device = IMEISelectionManager.shared.selectedDevice {
            updateView(for: device)
            
            geofenceListenerToken = GeofenceStore.shared.addListener(for: device.imei, listener: { [weak self] (imei) in
                if IMEISelectionManager.shared.selectedDevice?.imei == imei {
                    DispatchQueue.main.async {
                        self?.activityIndicator.stopAnimating()
                        self?.view.isUserInteractionEnabled = true
                        self?.updateView(for: device)
                    }
                }
            })
        }
        
        overlayContainerView.layer.cornerRadius = 20
        overlayContainerView.layer.masksToBounds = true
    }
    
    func configureMapView() {
        mapView.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureTapped(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        mapView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapGestureTapped(_ sender: UITapGestureRecognizer) {
        if let device = IMEISelectionManager.shared.selectedDevice, let geofences = device.geoFences {
            if let geoFence = geofences.filter({ $0.type == selectedGeoFenceType.rawValue }).first {
                if geoFence.name != "0" {
                    if geoFence.name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0 {
                        return
                    }
                }
            }
        }
        let locationPoint = sender.location(in: mapView)
        let locationCoordinate2D = mapView.convert(locationPoint, toCoordinateFrom: mapView)
        
        if sender.numberOfTouches == 1 {
            print(locationCoordinate2D)
            editedLocationAnnotation.flatMap({ mapView.removeAnnotation($0) })
            editedLocationAnnotation = MKPointAnnotation()
            editedLocationAnnotation?.coordinate = locationCoordinate2D
            mapView.addAnnotation(editedLocationAnnotation!)
        }
    }
    
    func customizeTextFields() {
        let pickerViewFrame = CGRect(x: 0, y: 0, width: 800, height: 300)
        var textFieldTimePickerView = TextFieldTimePicker(frame: pickerViewFrame)
        overlayStartTimeTextField.inputView = textFieldTimePickerView
        textFieldTimePickerView.cancelHandler = { [weak self] in
            self?.detailsFieldBottomConstraint.constant = 0
            self?.overlayStartTimeTextField.resignFirstResponder()
        }
        
        textFieldTimePickerView.selectionHandler = { [weak self] (hr, min) in
            self?.detailsFieldBottomConstraint.constant = 0
            self?.overlayStartTimeTextField.text = String(format: "%02d:%02d", hr, min)
        }
        
        textFieldTimePickerView = TextFieldTimePicker(frame:pickerViewFrame)
        overlayEndTimeTimeTextField.inputView = textFieldTimePickerView
        textFieldTimePickerView.cancelHandler = { [weak self] in
            self?.detailsFieldBottomConstraint.constant = 0
            self?.overlayEndTimeTimeTextField.resignFirstResponder()
        }
        textFieldTimePickerView.selectionHandler = { [weak self] (hr, min) in
            self?.detailsFieldBottomConstraint.constant = 0
            self?.overlayEndTimeTimeTextField.text = String(format: "%02d:%02d", hr, min)
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
}

extension GeofenceViewController {
    func updateView(for device: Device) {
        guard let geoFence = device.geoFences?.filter({ $0.type == selectedGeoFenceType.rawValue }).first else {
            nameTextField.text = "0"
            return
        }
        
        if geoFence.name == "0" {
            saveButton.isHidden = false
            deleteButton.isHidden = true
            
            nameTextField.isUserInteractionEnabled = true
            overlayRadiusTextField.isUserInteractionEnabled = true
            overlayStartTimeTextField.isUserInteractionEnabled = true
            overlayEndTimeTimeTextField.isUserInteractionEnabled = true
            addButton.isUserInteractionEnabled = true
        } else {
            if geoFence.name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0 {
                deleteButton.isHidden = false
                saveButton.isHidden = true
                
                nameTextField.isUserInteractionEnabled = false
                overlayRadiusTextField.isUserInteractionEnabled = false
                overlayStartTimeTextField.isUserInteractionEnabled = false
                overlayEndTimeTimeTextField.isUserInteractionEnabled = false
                addButton.isUserInteractionEnabled = false
                
            } else {
                saveButton.isHidden = false
                deleteButton.isHidden = true
                
                nameTextField.isUserInteractionEnabled = true
                overlayRadiusTextField.isUserInteractionEnabled = true
                overlayStartTimeTextField.isUserInteractionEnabled = true
                overlayEndTimeTimeTextField.isUserInteractionEnabled = true
                addButton.isUserInteractionEnabled = true
                
            }
        }
        
        
        
        nameTextField.text = geoFence.name
        
        overlayRadiusTextField.text = geoFence.radius
        if geoFence.type == GeoFenceType.lock.rawValue {
            overlayStartTimeStackView.isHidden = true
            overlayEndTimeTimeTextField.text = geoFence.endTime ?? "00:00"
            if overlayEndTimeTimeTextField.text == "0" { overlayEndTimeTimeTextField.text = "00:00" }
        } else {
            overlayStartTimeStackView.isHidden = false
            overlayEndTimeTimeTextField.text = geoFence.endTime ?? "00:00"
            overlayStartTimeTextField.text = geoFence.startTime ?? "00:00"
            
            if overlayEndTimeTimeTextField.text == "0" { overlayEndTimeTimeTextField.text = "00:00" }
            if overlayStartTimeTextField.text == "0" { overlayStartTimeTextField.text = "00:00" }
            
        }
        
        guard geoFence.lat != "0" && geoFence.long != "0" else { return }
        guard let latitude = CLLocationDegrees(geoFence.lat) else { return }
        guard let longitude = CLLocationDegrees(geoFence.long) else { return }
        
        let coordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: coordinate2D, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
        
        currentAnnotation.flatMap({ mapView.removeAnnotation($0) })
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate2D
        annotation.title = "\(coordinate2D.latitude, coordinate2D.longitude)"
        mapView.addAnnotation(annotation)
        currentAnnotation = annotation
    }
}

extension GeofenceViewController {
    @IBAction func nameTextFieldEditingChanged() {
        editedValues.name = nameTextField.text
    }
}

extension GeofenceViewController {
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

extension GeofenceViewController {
    @IBAction func deleteButtonPressed() {
        
    }
    
    @IBAction func saveButtonPressed() {
        if let _ = editedLocationAnnotation {
            do {
                try editedValues.allFieldsFilled(forGeofenceType: selectedGeoFenceType)
                saveGeofenceToServer()
            } catch let error as GeofenceEditFieldErrors {
                showOkAlert(message: error.rawValue)
            } catch {
                
            }
        } else {
            showOkAlert(message: "Please select a location by tapping in the map")
        }
    }
}

extension GeofenceViewController {
    func saveGeofenceToServer() {
        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        let model: GeoFenceCreateUpdateModel
        if selectedGeoFenceType == .lock {
            model = GeoFenceCreateUpdateModel(geoLockWithName: editedValues.name!, imei: device.imei, lat: editedLocationAnnotation!.coordinate.latitude, long: editedLocationAnnotation!.coordinate.longitude, radius: Int(editedValues.radius!), geoEndTime: String(format: "%02d:%02d", editedValues.endTime!.hour, editedValues.endTime!.min))
        } else {
            model = GeoFenceCreateUpdateModel(geoFenceWithName: editedValues.name!, imei: device.imei, lat: editedLocationAnnotation!.coordinate.latitude, long: editedLocationAnnotation!.coordinate.longitude, radius: Int(editedValues.radius!), startTime: String(format: "%02d:%02d", editedValues.startTime!.hour, editedValues.startTime!.min), endTime: String(format: "%02d:%02d", editedValues.endTime!.hour, editedValues.endTime!.min), type: selectedGeoFenceType.rawValue)
        }
        
        GeofenceStore.shared.updateGeoFence(model) { [weak  self](imei, type, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.view.isUserInteractionEnabled = true
                }
                return
            }
            
            if IMEISelectionManager.shared.selectedDevice?.imei == imei {
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.view.isUserInteractionEnabled = true
                    self?.editedLocationAnnotation.flatMap({ self?.mapView.removeAnnotation($0) })
                    self?.updateView(for: device)
                }
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        self.view.endEditing(true)
        overlayGeofenceTypeLabel.text = selectedGeoFenceType.rawValue
        overlayView.isHidden = false
    }
    
    @IBAction func overlayButtonTapped() {
        overlayView.isHidden = true
        self.view.endEditing(true)
        detailsFieldBottomConstraint.constant = 0
    }
    
    @IBAction func addGeofenceRadiusAndDuration() {
        if let text = overlayRadiusTextField.text, let radius = Double(text), radius > 0 {
            if selectedGeoFenceType == .lock {
                if let text = overlayEndTimeTimeTextField.text {
                    let components = text.components(separatedBy: ":")
                    if components.count == 2  {
                        if let hour = Int(components[0]), let minute = Int(components[1]) {
                            editedEndTime.hour = hour
                            editedEndTime.minute = minute
                        }
                    }
                    
                    if editedEndTime.hour == nil || editedEndTime.minute == nil {
                        showOkAlert(message: GeofenceEditFieldErrors.noEndTime.rawValue)
                        return
                    }
                    
                    editedValues.endTime = (editedEndTime.hour!, editedEndTime.minute!)
                    editedValues.radius = radius
                    overlayButtonTapped()
                } else {
                    showOkAlert(message: GeofenceEditFieldErrors.noEndTime.rawValue)
                    return
                }
            } else {
                if let text = overlayEndTimeTimeTextField.text {
                    let components = text.components(separatedBy: ":")
                    if components.count == 2  {
                        if let hour = Int(components[0]), let minute = Int(components[1]) {
                            editedEndTime.hour = hour
                            editedEndTime.minute = minute
                        }
                    }
                } else {
                    showOkAlert(message: GeofenceEditFieldErrors.noEndTime.rawValue)
                    return
                }
                
                if let text = overlayStartTimeTextField.text {
                    let components = text.components(separatedBy: ":")
                    if components.count == 2  {
                        if let hour = Int(components[0]), let minute = Int(components[1]) {
                            editedStartTime.hour = hour
                            editedStartTime.minute = minute
                        }
                    }
                } else {
                    showOkAlert(message: GeofenceEditFieldErrors.noStartTime.rawValue)
                    return
                }
                
                if editedStartTime.hour == nil || editedStartTime.minute == nil {
                    showOkAlert(message: GeofenceEditFieldErrors.noStartTime.rawValue)
                    return
                }
                
                if editedEndTime.hour == nil || editedEndTime.minute == nil {
                    showOkAlert(message: GeofenceEditFieldErrors.noEndTime.rawValue)
                    return
                }
                
                let startSeconds = editedStartTime.hour! * 60 * 60 + editedStartTime.minute! * 60
                let endSeconds = editedEndTime.hour! * 60 * 60 + editedEndTime.minute! * 60
                
                if startSeconds >= endSeconds {
                    showOkAlert(message: "End time should be after start time")
                    return
                }
                
                editedValues.endTime = (editedEndTime.hour!, editedEndTime.minute!)
                editedValues.startTime = (editedStartTime.hour!, editedStartTime.minute!)
                editedValues.radius = radius
                
                overlayButtonTapped()
            }
        } else {
            showOkAlert(message: GeofenceEditFieldErrors.noRadius.rawValue)
        }
    }
}

extension GeofenceViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let editedLocationAnnotation = editedLocationAnnotation {
            if annotation === editedLocationAnnotation {
                if let anView = mapView.dequeueReusableAnnotationView(withIdentifier: "editedLocationAnnotation") {
                    return anView
                } else {
                    let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "editedLocationAnnotation")
                    pinAnnotationView.pinTintColor = .blue
                    return pinAnnotationView
                }
            }
        }
        
        if let anView = mapView.dequeueReusableAnnotationView(withIdentifier: "previousPoint") {
            return anView
        } else {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "previousPoint")
            pinAnnotationView.pinTintColor = .red
            return pinAnnotationView
        }
    }
}

extension GeofenceViewController {
    func showOkAlert(message: String?) {
        let alertViewController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertViewController, animated: true, completion: nil)
    }
}

struct EditedValues {
    var name: String?
    
    var radius: Double?
    var startTime: (hour: Int, min: Int)?
    var endTime: (hour: Int, min: Int)?
    
    mutating func reset() {
        name = nil
        radius = nil
        startTime = nil
        endTime = nil
    }
    
    func allFieldsFilled(forGeofenceType type: GeoFenceType) throws {
        if let name = name, name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0 && name != "0" {
            if radius == nil {
                throw GeofenceEditFieldErrors.noRadius
            }
            
            if startTime == nil, type != .lock {
                throw GeofenceEditFieldErrors.noStartTime
            }
            
            if endTime == nil {
                throw GeofenceEditFieldErrors.noEndTime
            }
            
            
        } else {
            throw GeofenceEditFieldErrors.noName
        }
    }
}

enum GeofenceEditFieldErrors: String, Error {
    case noName = "Please enter a name"
    case noRadius = "Please enter a radius greater then 0 meters"
    case noStartTime = "Please enter a start time"
    case noEndTime = "Please enter an end time"
}

