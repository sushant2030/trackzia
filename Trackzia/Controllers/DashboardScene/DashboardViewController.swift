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
            dashboardOptionsController.delegate = self
        }
    }
}

extension DashboardViewController: DashboardProfileViewControllerDelegate {
    func arrowButtonTouched(_ sender: UIButton) {
        dashboardOptionsController.switchTableMode()
    }
}

extension DashboardViewController: DashboardOptionsListViewControllerDelegate {
    func dashboardOptionsListViewController(_ dashboardOptionsListViewController: DashboardOptionsListViewController, didSelectUserOption option: DashboardListUserOption) {
        PostLoginRouter.dashboardOptionsListViewController(dashboardOptionsListViewController, didSelectUserOption: option)
    }
    
    func dashboardOptionsListViewController(_ dashboardOptionsListViewController: DashboardOptionsListViewController, didSelectTrackListOption option: DashboardTrackListOptions) {
        PostLoginRouter.dashboardOptionsListViewController(dashboardOptionsListViewController, didSelectTrackListOption: option)
        switch option {
        case .kid: IMEISelectionManager.shared.profileType = .kid
        
        case .pet: IMEISelectionManager.shared.profileType = .pet
            
        case .other: IMEISelectionManager.shared.profileType = .other
            
        case .seniorCitizen: IMEISelectionManager.shared.profileType = .seniorCitizen
            
        case .vehicle: IMEISelectionManager.shared.profileType = .vehicle
            
        default: break
        }
    }
}
