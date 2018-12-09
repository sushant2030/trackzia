//
//  PostLoginRouter.swift
//  Trackzia
//
//  Created by Rohan Bhale on 09/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit

class PostLoginRouter {
    
    private class var splitViewController: UISplitViewController {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        guard let splitViewController = delegate.window?.rootViewController as? UISplitViewController else { fatalError("No splitviewcontroller found") }
        return splitViewController
    }
    
    class func dashboardOptionsListViewController(_ dashboardOptionsListViewController: DashboardOptionsListViewController, didSelectUserOption option: DashboardListUserOption) {
        
        var storyboard = UIStoryboard(name: "TabBar", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "HomeVC")
        let navCtrl = UINavigationController(rootViewController: viewController)
        
        switch option {
        case .profile:
            storyboard = UIStoryboard(name: "ProfileEditing", bundle: nil)
            let profileEditingViewController = storyboard.instantiateViewController(withIdentifier: "UserProfileViewController")
            navCtrl.pushViewController(profileEditingViewController, animated: true)
        
        case .geofence:
            storyboard = UIStoryboard(name: "PostLogin", bundle: nil)
            let geofenceViewController = storyboard.instantiateViewController(withIdentifier: "GeofenceViewController")
            navCtrl.pushViewController(geofenceViewController, animated: true)
            
        case .alertSettings:
            storyboard = UIStoryboard(name: "PostLogin", bundle: nil)
            let alertSettingsViewController = storyboard.instantiateViewController(withIdentifier: "AlertSettingsViewController")
            navCtrl.pushViewController(alertSettingsViewController, animated: true)
        default: print("No other implementations")
            
        }
        splitViewController.showDetailViewController(navCtrl, sender: nil)
    }
    
    
}