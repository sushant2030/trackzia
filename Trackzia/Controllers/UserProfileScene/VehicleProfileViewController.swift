//
//  VehicleProfileViewController.swift
//  Trackzia
//
//  Created by Rohan Bhale on 11/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit

class VehicleProfileViewController: UITableViewController {
    @IBOutlet var vehicleImageView: UIImageView!
    
    @IBOutlet var imeiNumberTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var typeTextField: UITextField!
    @IBOutlet var chasisNoTextField: UITextField!
    @IBOutlet var purchaseDateTextField: UITextField!
    @IBOutlet var colorTextField: UITextField!
    @IBOutlet var modelTextField: UITextField!
    
    @IBOutlet var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeAppearance()
        updateFields()
    }
    
    
    func customizeAppearance() {
        let bgImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 320, height:624))
        bgImage.image = UIImage(named: "screenbackground")
        tableView.backgroundColor = .clear
        tableView.backgroundView = bgImage
        
        vehicleImageView.layer.cornerRadius = 50.0
        vehicleImageView.layer.masksToBounds = true
        
        submitButton.layer.cornerRadius = 22.0
        submitButton.layer.borderColor = UIColor(red: CGFloat(168.0 / 255.0), green: 0.0, blue: 0.0, alpha: 1.0).cgColor
        submitButton.layer.borderWidth = 1.0
    }
}

extension VehicleProfileViewController: IMEIWiseProfileListenerChangeListener {
    func updateFields() {
        if UserDataManager.shared.imeiList.count > IMEISelectionManager.shared.selectedIndex {
            let imeiNumber = UserDataManager.shared.imeiList[IMEISelectionManager.shared.selectedIndex]
            let imeiWiseProfiles = UserDataManager.shared.profileTypesFrom(imeiNumber: imeiNumber)
            
            imeiWiseProfiles.forEach { profile in
                switch profile {
                case let vehicleProfile as ProfileTypeVehicle:
                    imeiNumberTextField.text = imeiNumber
                    nameTextField.text = vehicleProfile.name
                    typeTextField.text = vehicleProfile.type
                    chasisNoTextField.text = vehicleProfile.chasisNo
                    purchaseDateTextField.text = vehicleProfile.purchaseDate
                    colorTextField.text = vehicleProfile.color
                    modelTextField.text = vehicleProfile.model
                    
                default: break
                }
            }
        }
        
    }
}
