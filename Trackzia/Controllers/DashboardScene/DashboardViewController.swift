//
//  DashboardViewController.swift
//  Trackzia
//
//  Created by Rohan Bhale on 07/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {
    
    var dashboardProfileController: DashboardProfileViewController!
    var dashboardOptionsController: DashboardOptionsListViewController!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileDashboardSegue" {
            dashboardProfileController = (segue.destination as! DashboardProfileViewController)
            dashboardProfileController.delegate = self
        }
        
        if segue.identifier == "OptionsDashboardSegue" {
            dashboardOptionsController = (segue.destination as! DashboardOptionsListViewController)
        }
    }
    
    
}

extension DashboardViewController: DashboardProfileViewControllerDelegate {
    func arrowButtonTouched(_ sender: UIButton) {
        dashboardOptionsController.switchTableMode()
    }
}
