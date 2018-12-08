//
//  TZForgetVC.swift
//  Trackzia
//
//  Created by Sushant Alone on 06/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit

class TZForgetVC: UIViewController {

    @IBOutlet var registerTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTextField.delegate = self
        customizingViews()
        // Do any additional setup after loading the view.
    }
    //MARK : - Customizing Views
    func customizingViews() {
        registerTextField.attributedPlaceholder = NSAttributedString(string: "Enter Your Register Mobile No", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    @IBAction func backgroundBtnAction(_ sender: UIButton) {
        registerTextField.resignFirstResponder()

    }
    @IBAction func loginBtnAction(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
}

//MARK: - UITextField Delegates
extension TZForgetVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        registerTextField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        registerTextField.resignFirstResponder()
        
    }
}
