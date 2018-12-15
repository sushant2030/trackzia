//
//  PreLoginRouter.swift
//  Trackzia
//
//  Created by Rohan Bhale on 15/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit

class PreLoginRouter {
    class func showHomeView() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "TZLoginVC") as! TZLoginVC
        let navCtrl = UINavigationController(rootViewController: viewController)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window?.rootViewController = navCtrl
        
        navCtrl.navigationBar.isHidden = true
    }
}
