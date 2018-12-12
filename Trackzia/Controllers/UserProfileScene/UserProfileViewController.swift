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
    }
}



extension UserProfileViewController: CommunicationResultListener {
    func onSuccess(operationId: Int, operation: CommunicationOperationResult) {
        print("Success")
    }
    
    func onFailure(operationId: Int, error: Error, data: Data?) {
        print("Failure")
    }
    
    
}
