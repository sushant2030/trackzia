//
//  OtherProfileViewController.swift
//  Trackzia
//
//  Created by Rohan Bhale on 11/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit

class OtherProfileViewController: UITableViewController {
    @IBOutlet var otherImageView: UIImageView!
    @IBOutlet var imeiNumberTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var descriptionTextField: UITextField!
    @IBOutlet var submitButton: UIButton!
    var btnEdit:UIButton!
    var userInteraction:Bool!
    var account: Account!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeAppearance()
        updateFields()
        account = UserDataStore.shared.account
    }
    
    
    func customizeAppearance() {
        let bgImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 320, height:624))
        bgImage.image = UIImage(named: "screenbackground")
        tableView.backgroundColor = .clear
        tableView.backgroundView = bgImage
        
        otherImageView.layer.cornerRadius = 50.0
        otherImageView.layer.masksToBounds = true
        
        submitButton.layer.cornerRadius = 22.0
        submitButton.layer.borderColor = UIColor(red: CGFloat(168.0 / 255.0), green: 0.0, blue: 0.0, alpha: 1.0).cgColor
        submitButton.layer.borderWidth = 1.0
        
        btnEdit = UIButton.init(type: .system)
        btnEdit .addTarget(self, action: #selector(action(_:)), for: .touchUpInside)
        btnEdit .setTitle("Edit", for: .normal)
        btnEdit .setTitle("X", for: .selected)
        let barButton = UIBarButtonItem.init(customView: btnEdit)
        self.navigationItem.rightBarButtonItem  = barButton
        submitButton.isHidden = true
        userInteraction = false
    }
    
    
    
    @objc func action(_ sender:UIButton){
        btnEdit.isSelected = !btnEdit.isSelected
        submitButton.isHidden = !btnEdit.isSelected
        userInteraction = btnEdit.isSelected
        setInteractionForViews(isInteraction: true)
    }
    
    func setInteractionForViews(isInteraction:Bool)  {
        for view in self.view.subviews{
            if !view.isKind(of: UIButton.self){
                view.isUserInteractionEnabled = isInteraction
            }
        }
    }
    @IBAction func actionSubmit(_ sender: Any) {
    }
}

extension OtherProfileViewController: IMEIWiseProfileListenerChangeListener {
    func updateFields() {
        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
        let otherProfile = IMEIWiseProfilesStore.shared.profileTypeOtherFrom(imeiNumber: device.imei)
        
        imeiNumberTextField.text = String(device.imei)
        nameTextField.text = otherProfile.name
        descriptionTextField.text = otherProfile.description
    }
}
