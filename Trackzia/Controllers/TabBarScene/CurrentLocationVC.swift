//
//  CurrentLocationViewController.swift
//  Trackzia
//
//  Created by Rohan Bhale on 23/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit

class CurrentLocationVC: UIViewController {
    @IBOutlet var liveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        liveButton.layer.cornerRadius = 7.0
    }
}

