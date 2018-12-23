//
//  HomeVC.swift
//  Trackzia
//
//  Created by Sushant Alone on 09/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {

    @IBOutlet var lblProfileName: UILabel!
    @IBOutlet var lblJustNow: UILabel!
    @IBOutlet var lblCurrentLocation: UILabel!

    @IBOutlet var lblRestingHours: UILabel!
    @IBOutlet var lblExploring: UILabel!
    @IBOutlet var lblPlayinHours: UILabel!
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var lblCurrentDistance: UILabel!
    @IBOutlet var lblDetail: UILabel!
    @IBOutlet var lblUpdatedAt: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnMapAction(_ sender: Any) {
        PostLoginRouter.showTabBarView()
    }
    
    @IBAction func btnMenuAction(_ sender: Any) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


class HomeVCPlaceHolder: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PostLoginRouter.showHomeView()
    }
}
