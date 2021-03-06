//
//  PetProfileViewController.swift
//  Trackzia
//
//  Created by Rohan Bhale on 09/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit


protocol IMEIWiseProfileListenerChangeListener {
    func updateFields()
    func imeiWiseProfileChangesListener(_ imeiNumber: IMEI)
}

extension IMEIWiseProfileListenerChangeListener {
    func imeiWiseProfileChangesListener(_ imeiNumber: IMEI) {
        if let device = IMEISelectionManager.shared.selectedDevice {
            if device.imei == imeiNumber {
                updateFields()
            }
        }
    }
}

class PetProfileViewController: UITableViewController, PopoverPresenter {
    @IBOutlet var petImageView: UIImageView!
    @IBOutlet var imeiNumberTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var birthDateTextField: UITextField!
    @IBOutlet var genderTextField: UITextField!
    @IBOutlet var typeTextField: UITextField!
    @IBOutlet var heightTextField: UITextField!
    @IBOutlet var weightTextField: UITextField!
    @IBOutlet var colorTextField: UITextField!
    @IBOutlet var breedTextField: UITextField!
    @IBOutlet var doctorsInfoTextField: UITextField!
    var btnEdit : UIButton!
    @IBOutlet var submitButton: UIButton!
    var userInteraction : Bool!
    var imeiWiseProfileListenerToken:IMEIWiseProfileListenerToken!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userInteraction = false
        customizeAppearance()
        updateFields()
        imeiWiseProfileListenerToken = UserDataManager.shared.addListener(imeiWiseProfileChangesListener)
        btnEdit = UIButton.init(type: .system)
        btnEdit .addTarget(self, action: #selector(action(_:)), for: .touchUpInside)
        btnEdit .setTitle("Edit", for: .normal)
        btnEdit .setTitle("X", for: .selected)
        btnEdit.isHighlighted = false
        let barButton = UIBarButtonItem.init(customView: btnEdit)
        self.navigationItem.rightBarButtonItem  = barButton
        submitButton.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setInteractionForViews(isInteraction: userInteraction)
    }

    
    func customizeAppearance() {
        let bgImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 320, height:624))
        bgImage.image = UIImage(named: "screenbackground")
        tableView.backgroundColor = .clear
        tableView.backgroundView = bgImage
        petImageView.layer.cornerRadius = 50.0
        petImageView.layer.masksToBounds = true
        
        submitButton.layer.cornerRadius = 22.0
        submitButton.layer.borderColor = UIColor(red: CGFloat(168.0 / 255.0), green: 0.0, blue: 0.0, alpha: 1.0).cgColor
        submitButton.layer.borderWidth = 1.0
    }
    
    @IBAction func genderDropDownTouched(_ sender: UIButton) {
        presentOptionsPopover(withOptionItems: genderOptionItems(), from: genderTextField)
    }
    
    @objc func action(_ sender:UIButton){
        btnEdit.isSelected = !btnEdit.isSelected
        submitButton.isHidden = !btnEdit.isSelected
        userInteraction = btnEdit.isSelected
        setInteractionForViews(isInteraction: true)
    }
    @IBAction func submitAction(_ sender: UIButton) {
        
    }
    
    func setInteractionForViews(isInteraction:Bool)  {
        for view in self.view.subviews{
            if !view.isKind(of: UIButton.self){
                view.isUserInteractionEnabled = isInteraction
            }
        }
    }
}

extension PetProfileViewController: IMEIWiseProfileListenerChangeListener {
    func updateFields() {
        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
        let petProfile = IMEIWiseProfilesStore.shared.profileTypePetFrom(imeiNumber: device.imei)
        imeiNumberTextField.text = String(device.imei)
        nameTextField.text = petProfile.name
        birthDateTextField.text = petProfile.birthDate
        genderTextField.text = petProfile.gender
        typeTextField.text = petProfile.type
        heightTextField.text = petProfile.height
        weightTextField.text = petProfile.weight
        colorTextField.text = petProfile.color
        breedTextField.text = petProfile.breed
        doctorsInfoTextField.text = petProfile.doctorInfo
    }
}

extension PetProfileViewController: RBOptionItemListViewControllerDelegate {
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

extension PetProfileViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
