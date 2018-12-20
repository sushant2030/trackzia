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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeAppearance()
    }
    
    func customizeAppearance() {
        let bgImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 320, height:624))
        bgImage.image = UIImage(named: "screenbackground")
        tableView.backgroundColor = .clear
        tableView.backgroundView = bgImage
        
        userProfileImageView.layer.cornerRadius = 50.0
        userProfileImageView.layer.masksToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        CommunicationManager.getCommunicator().performOpertaion(with: GetAccountDetailsService(mobileNumber: "9422680548", listener: self))
        
//        CommunicationManager.getCommunicator().performOpertaion(with: GetAccountDetailsService(mobileNumber: "9422680567", listener: self))
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



extension UserProfileViewController: CommunicationResultListener {
    func onSuccess(operationId: Int, operation: CommunicationOperationResult) {
        print("Success")
        if let result = operation as? GetAccountDetailsServiceResult, result.success {
            nameTextField.text = result.data?.accName
            genderTextField.text = result.data?.gender
            birthDateTextField.text = result.data?.dob
            countryTextField.text = result.data?.country
            stateTextField.text = result.data?.stateName
            cityTextField.text = result.data?.city
            emailIdTextField.text = result.data?.emailId
        }
    }
    
    func onFailure(operationId: Int, error: Error, data: Data?) {
        print("Failure")
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
