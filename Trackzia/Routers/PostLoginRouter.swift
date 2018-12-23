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
    
    class func dashboardOptionsListViewController(_ dashboardOptionsListViewController: DashboardOptionsListViewController, didSelectTrackListOption option: DashboardTrackListOptions) {
        var storyboard = UIStoryboard(name: "TabBar", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "HomeVC")
        let navCtrl = UINavigationController(rootViewController: viewController)
        
        switch option {
        case .pet:
            storyboard = UIStoryboard(name: "ProfileEditing", bundle: nil)
            let petProfileViewController = storyboard.instantiateViewController(withIdentifier: "PetProfileViewController")
            navCtrl.pushViewController(petProfileViewController, animated: true)
            
        case .kid:
            storyboard = UIStoryboard(name: "ProfileEditing", bundle: nil)
            let kidProfileViewController = storyboard.instantiateViewController(withIdentifier: "KidProfileViewController")
            navCtrl.pushViewController(kidProfileViewController, animated: true)
            
        case .other:
            storyboard = UIStoryboard(name: "ProfileEditing", bundle: nil)
            let otherProfileViewController = storyboard.instantiateViewController(withIdentifier: "OtherProfileViewController")
            navCtrl.pushViewController(otherProfileViewController, animated: true)
            
        case .seniorCitizen:
            storyboard = UIStoryboard(name: "ProfileEditing", bundle: nil)
            let seniorCitizenProfileViewController = storyboard.instantiateViewController(withIdentifier: "SeniorCitizenProfileViewController")
            navCtrl.pushViewController(seniorCitizenProfileViewController, animated: true)
            
        case .vehicle:
            storyboard = UIStoryboard(name: "ProfileEditing", bundle: nil)
            let vehicleProfileViewController = storyboard.instantiateViewController(withIdentifier: "VehicleProfileViewController")
            navCtrl.pushViewController(vehicleProfileViewController, animated: true)
            
            
        default:
            print("No other implementations")
        }
        splitViewController.showDetailViewController(navCtrl, sender: nil)
    }
    
    class func showHomeView() {
        let storyboard = UIStoryboard(name: "PostLogin", bundle: nil)
        let splitViewController = storyboard.instantiateViewController(withIdentifier: "MainSplitViewController") as! UISplitViewController
        
        let tabBarstoryboard = UIStoryboard(name: "TabBar", bundle: nil)
        let viewController = tabBarstoryboard.instantiateViewController(withIdentifier: "HomeVC")
        let navCtrl = UINavigationController(rootViewController: viewController)
        splitViewController.viewControllers[1] = navCtrl
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window?.rootViewController = splitViewController
        
    }
    
    class func showTabBarView() {
        let storyboard = UIStoryboard(name: "TabBar", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as! UITabBarController
        tabBarController.selectedIndex = 1
        splitViewController.showDetailViewController(tabBarController, sender: nil)
    }
}
