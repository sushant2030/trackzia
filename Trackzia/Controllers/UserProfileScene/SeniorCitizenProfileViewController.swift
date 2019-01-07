//
//  SeniorCitizenProfileViewController.swift
//  Trackzia
//
//  Created by Rohan Bhale on 11/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit

class SeniorCitizenProfileViewController: UITableViewController, PopoverPresenter {
    @IBOutlet var seniorCitizenImageView: UIImageView!
    @IBOutlet var imeiNumberTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var relationTextField: UITextField!
    @IBOutlet var birthDateTextField: UITextField!
    @IBOutlet var genderTextField: UITextField!
    @IBOutlet var bodyTypeTextField: UITextField!
    @IBOutlet var heightTextField: UITextField!
    @IBOutlet var colorTextField: UITextField!
    @IBOutlet var doctorInfoTextField: UITextField!
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
        
        seniorCitizenImageView.layer.cornerRadius = 50.0
        seniorCitizenImageView.layer.masksToBounds = true
        
        submitButton.layer.cornerRadius = 22.0
        submitButton.layer.borderColor = UIColor(red: CGFloat(168.0 / 255.0), green: 0.0, blue: 0.0, alpha: 1.0).cgColor
        submitButton.layer.borderWidth = 1.0
    }
    
    @IBAction func genderDropDownTouched(_ sender: UIButton) {
        presentOptionsPopover(withOptionItems: genderOptionItems(), from: genderTextField)
    }
}

extension SeniorCitizenProfileViewController: IMEIWiseProfileListenerChangeListener {
    func updateFields() {
        if let device = IMEISelectionManager.shared.selectedDevice {
            let imeiWiseProfiles = UserDataManager.shared.profileTypesFrom(imeiNumber: device.imei)
            
            imeiWiseProfiles.forEach { profile in
                switch profile {
                case let seniorCitizenProfile as ProfileTypeSeniorCitizen:
                    imeiNumberTextField.text = String(device.imei)
                    nameTextField.text = seniorCitizenProfile.name
                    relationTextField.text = seniorCitizenProfile.sonDaughter
                    birthDateTextField.text = seniorCitizenProfile.birthDate
                    genderTextField.text = seniorCitizenProfile.gender
                    bodyTypeTextField.text = seniorCitizenProfile.bodyType
                    heightTextField.text = seniorCitizenProfile.height
                    colorTextField.text = seniorCitizenProfile.color
                    doctorInfoTextField.text = seniorCitizenProfile.doctorInfo
                default: break
                }
            }
        }
        
    }
}

extension SeniorCitizenProfileViewController: RBOptionItemListViewControllerDelegate {
    func optionItemListViewController(_ controller: RBOptionItemListViewController, didSelectOptionItem item: RBOptionItem) {
        switch item {
        case let option as GenderOptionItem:
            genderTextField.text = option.text
        default:
            break
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension SeniorCitizenProfileViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
