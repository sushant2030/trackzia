//
//  PetProfileViewController.swift
//  Trackzia
//
//  Created by Rohan Bhale on 09/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit

class PetProfileViewController: UITableViewController {
    @IBOutlet var petImageView: UIImageView!
    
    func customizeAppearance() {
        let bgImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 320, height:624))
        bgImage.image = UIImage(named: "screenbackground")
        tableView.backgroundColor = .clear
        tableView.backgroundView = bgImage
        
        petImageView.layer.cornerRadius = 50.0
        petImageView.layer.masksToBounds = true
    }
    
}
