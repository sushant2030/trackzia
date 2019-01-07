//
//  KidProfileViewController.swift
//  Trackzia
//
//  Created by Rohan Bhale on 10/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit

class KidProfileViewController: UITableViewController, PopoverPresenter {
    @IBOutlet var kidImageView: UIImageView!
    @IBOutlet var imeiNumberTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var relationTextField: UITextField!
    @IBOutlet var birthDateTextField: UITextField!
    @IBOutlet var genderTextField: UITextField!
    @IBOutlet var bodyTypeTextField: UITextField!
    @IBOutlet var colorTextField: UITextField!
    @IBOutlet var schoolTextField: UITextField!
    @IBOutlet var heightTextField: UITextField!
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
        
        kidImageView.layer.cornerRadius = 50.0
        kidImageView.layer.masksToBounds = true
        
        submitButton.layer.cornerRadius = 22.0
        submitButton.layer.borderColor = UIColor(red: CGFloat(168.0 / 255.0), green: 0.0, blue: 0.0, alpha: 1.0).cgColor
        submitButton.layer.borderWidth = 1.0
    }
    
    @IBAction func genderDropDownTouched(_ sender: UIButton) {
        presentOptionsPopover(withOptionItems: genderOptionItems(), from: genderTextField)
    }
}

extension KidProfileViewController: IMEIWiseProfileListenerChangeListener {
    func updateFields() {
        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
        let kidProfile = IMEIWiseProfilesStore.shared.profileTypeKidFrom(imeiNumber: device.imei)
        
        imeiNumberTextField.text = String(device.imei)
        nameTextField.text = kidProfile.name
        relationTextField.text = kidProfile.sonDaughter
        birthDateTextField.text = kidProfile.birthDate
        genderTextField.text = kidProfile.gender
        bodyTypeTextField.text = kidProfile.bodyType
        colorTextField.text = kidProfile.color
        schoolTextField.text = kidProfile.school
        heightTextField.text = kidProfile.height
    }
}

extension KidProfileViewController: RBOptionItemListViewControllerDelegate {
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

extension KidProfileViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
