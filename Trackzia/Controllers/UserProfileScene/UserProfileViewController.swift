//
//  UserProfileViewController.swift
//  Trackzia
//
//  Created by Rohan Bhale on 08/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit
import ApiManager

protocol PopoverPresenter: UIPopoverPresentationControllerDelegate, RBOptionItemListViewControllerDelegate {
    func presentOptionsPopover(withOptionItems items: [[RBOptionItem]], from textField: UITextField)
}

extension PopoverPresenter where Self: UIViewController{
    func presentOptionsPopover(withOptionItems items: [[RBOptionItem]], from textField: UITextField) {
        let optionItemListVC = RBOptionItemListViewController()
        optionItemListVC.items = items
        optionItemListVC.delegate = self
        
        guard let popoverPresentationController = optionItemListVC.popoverPresentationController else { fatalError("Set Modal presentation style") }
        popoverPresentationController.sourceView = textField
        popoverPresentationController.sourceRect = textField.bounds
        popoverPresentationController.delegate = self
        popoverPresentationController.permittedArrowDirections = [.down, .up]
        self.present(optionItemListVC, animated: true, completion: nil)
    }
    
    
}

class UserProfileViewController: UITableViewController, PopoverPresenter {
    
    @IBOutlet var userProfileImageView: UIImageView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var genderTextField: UITextField!
    @IBOutlet var birthDateTextField: UITextField!
    @IBOutlet var countryTextField: UITextField!
    @IBOutlet var stateTextField: UITextField!
    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var emailIdTextField: UITextField!
    var userInteraction:Bool!
    var btnEdit:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeAppearance()
        updateFields()
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
        
        userProfileImageView.layer.cornerRadius = 50.0
        userProfileImageView.layer.masksToBounds = true
        
        btnEdit = UIButton.init(type: .system)
        btnEdit .addTarget(self, action: #selector(action(_:)), for: .touchUpInside)
        btnEdit .setTitle("Edit", for: .normal)
        btnEdit .setTitle("X", for: .selected)
        let barButton = UIBarButtonItem.init(customView: btnEdit)
        self.navigationItem.rightBarButtonItem  = barButton
//        submitButton.isHidden = true
        userInteraction = false
    }
    
    func updateFields() {
        let account = UserDataStore.shared.account
        nameTextField.text = account?.fullName
        genderTextField.text = account?.gender
        birthDateTextField.text = account?.dob
        countryTextField.text = account?.country
        stateTextField.text = account?.state
        cityTextField.text = account?.city
        emailIdTextField.text = account?.emailId
    }
    
    func setInteractionForViews(isInteraction:Bool)  {
        for view in self.view.subviews{
            if !view.isKind(of: UIButton.self){
                view.isUserInteractionEnabled = isInteraction
            }
        }
    }
    
    
    @objc func action(_ sender:UIButton){
        btnEdit.isSelected = !btnEdit.isSelected
//        submitButton.isHidden = !btnEdit.isSelected
        userInteraction = btnEdit.isSelected
        setInteractionForViews(isInteraction: true)
    }
    
    @IBAction func genderDropDownTouched(_ sender: UIButton) {
        presentOptionsPopover(withOptionItems: genderOptionItems(), from: genderTextField)
    }
    
    @IBAction func countryDropDownTouched(_ sender: UIButton) {
        presentOptionsPopover(withOptionItems: countryOptionItems(), from: countryTextField)
    }
    
    @IBAction func stateDropDownTouched(_ sender: UIButton) {
        presentOptionsPopover(withOptionItems: stateOptionItems(), from: stateTextField)
    }
    
    @IBAction func cityDropDownTouched(_ sender: UIButton) {
        presentOptionsPopover(withOptionItems: cityOptionItems(), from: cityTextField)
    }
}

extension UserProfileViewController: RBOptionItemListViewControllerDelegate {
    func optionItemListViewController(_ controller: RBOptionItemListViewController, didSelectOptionItem item: RBOptionItem) {
        switch item {
        case let option as GenderOptionItem:
            genderTextField.text = option.text
        
        case let option as CountryOptionItem:
            countryTextField.text = option.text
            
        case let option as StateOptionItem:
            stateTextField.text = option.text
            
        case let option as CityOptionItem:
            cityTextField.text = option.text
        default:
            break
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension UserProfileViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
//let userAccntData = UserAccountData(accName: accName,
//                                    city: city,
//                                    country: country,
//                                    dob: dob,
//                                    emailId: emailId,
//                                    gender: gender,
//                                    mobile: mobile,
//                                    stateName: stateName,
//                                    result: result)
