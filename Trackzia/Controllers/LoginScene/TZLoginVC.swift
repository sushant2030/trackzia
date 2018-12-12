//
//  TZLoginVC.swift
//  Trackzia
//
//  Created by Sushant Alone on 06/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit
import ApiManager

class TZLoginVC: UIViewController {

    @IBOutlet var mobileNumbertextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        mobileNumbertextField.delegate = self;
        passwordTextField.delegate = self;
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        customizingViews()

    }
    
    @IBAction func showPasswordBtnAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        passwordTextField.isSecureTextEntry = !sender.isSelected
    }
    @IBAction func backgroundBtnAction(_ sender: UIButton) {
        mobileNumbertextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    @IBAction func registerBtnAction(_ sender: UIButton) {
        let register = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "TZRegisterVC")
        self.present(register, animated: false, completion: nil)
    }
    
    @IBAction func forgetBtnAction(_ sender: UIButton) {
        let forgetVC = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "TZForgetVC")
        self.present(forgetVC, animated: false, completion: nil)
    }
    
    @IBAction func signInBtnAction(_ sender: UIButton) {
        guard let mobileNumber = mobileNumbertextField.text else { return }
        guard let password = passwordTextField.text else { return }
        CommunicationManager.getCommunicator().performOpertaion(with: LoginService(mobileNumber: mobileNumber, password: password, listener: self))
    }
    //MARK : - Customizing Views
    func customizingViews() {
        mobileNumbertextField.attributedPlaceholder = NSAttributedString(string: "Enter Mobile Number", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
         passwordTextField.attributedPlaceholder = NSAttributedString(string: "Enter Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
}
//MARK: - UITextField Delegates
extension TZLoginVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    mobileNumbertextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        mobileNumbertextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()

    }
}

extension TZLoginVC: CommunicationResultListener {
    func onSuccess(operationId: Int, operation: CommunicationOperationResult) {
        guard let result = operation as? LoginServiceResult else { return }
        PostLoginRouter.showPostLoginHomeView()
    }
    
    func onFailure(operationId: Int, error: Error, data: Data?) {
        
    }
    
    
}
