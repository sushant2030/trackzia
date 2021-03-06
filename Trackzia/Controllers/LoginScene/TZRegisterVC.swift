//
//  TZRegisterVC.swift
//  Trackzia
//
//  Created by Sushant Alone on 06/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit
import ApiManager

class TZRegisterVC: UIViewController {

    @IBOutlet var mobileTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        mobileTextField.delegate = self
        customizingViews()
        // Do any additional setup after loading the view.
    }
    
    //MARK : - Customizing View
    func customizingViews() {
        mobileTextField.attributedPlaceholder = NSAttributedString(string: "Enter Mobile Number", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])

    }
    @IBAction func backgroundBtnAction(_ sender: UIButton) {
        mobileTextField.resignFirstResponder()
    }
    
    @IBAction func loginBtnAction(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    @IBAction func sendVerificationAction(_ sender: UIButton) {
    CommunicationManager.getCommunicator().performOpertaion(with: OTPRegisterService.init(withAccName: "", mobile: mobileTextField.text ?? "", listener: self))
        
        
    }
}

//MARK: - UITextField Delegates
extension TZRegisterVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        mobileTextField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        mobileTextField.resignFirstResponder()
        
    }
}

//MARK: Communication Service Delegate
extension TZRegisterVC : CommunicationResultListener
{
    func onSuccess(operationId: Int, operation: CommunicationOperationResult) {
        if let otpOperation = operation as? OTPRegisterModel{
            if otpOperation.success {
                let verifyVC : TZVerifyVC = UIStoryboard.init(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "TZVerifyVC") as! TZVerifyVC
                //verifyVC.txtVerification.text = otpOperation.otp
                self.present(verifyVC, animated: false, completion: nil)
            }
        }
    }
    func onFailure(operationId: Int, error: Error, data: Data?) {
        
    }
}
