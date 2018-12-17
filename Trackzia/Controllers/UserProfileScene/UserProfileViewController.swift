//
//  UserProfileViewController.swift
//  Trackzia
//
//  Created by Rohan Bhale on 08/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit
import ApiManager

class UserProfileViewController: UITableViewController {
    
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


//let userAccntData = UserAccountData(accName: accName,
//                                    city: city,
//                                    country: country,
//                                    dob: dob,
//                                    emailId: emailId,
//                                    gender: gender,
//                                    mobile: mobile,
//                                    stateName: stateName,
//                                    result: result)
