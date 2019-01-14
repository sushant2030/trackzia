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
    
    var imeiChangeListenerToken: IMEISelectionManagerListenerToken!
    var profileChangeListenerToken: ProfileSectionListenerToken!
    
    var deviceInfoObjectObserver: ManagedObjectObserver?
    
    deinit {
        IMEISelectionManager.shared.removeListener(token: imeiChangeListenerToken)
        IMEISelectionManager.shared.removeProfileListener(token: profileChangeListenerToken)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateFields()
        imeiSelectionChangeListener()
        profileChangeListener()
        imeiChangeListenerToken = IMEISelectionManager.shared.addListener(imeiSelectionChangeListener)
        profileChangeListenerToken = IMEISelectionManager.shared.addListener(profileChangeListener)
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

    func imeiSelectionChangeListener() {
        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
        startObserving(device: device)
    }
    
    func profileChangeListener() {
        guard let device = IMEISelectionManager.shared.selectedDevice else { return }
        guard let profile = device.profiles?.filter({ $0.profileType == IMEISelectionManager.shared.profileType.rawValue }).first else { return }
        lblProfileName.text = profile.name
        
    }
    
    func startObserving(device: Device) {
        deviceInfoObjectObserver = ManagedObjectObserver(object: device.actionsInfo, changeHandler: objectChangeObserver(changeType:))
    }
    
    func objectChangeObserver(changeType: ManagedObjectObserver.ChangeType) {
        if changeType == .update{
            updateFields()
        }
    }
    
    func updateFields() {
        guard let actionsInfo = IMEISelectionManager.shared.selectedDevice?.actionsInfo else { return }
        
        lblPlayinHours.text = splitHrsMinsString(actionsInfo.running) != nil ? "Playing" + " " + splitHrsMinsString(actionsInfo.running)! : nil
        lblExploring.text = splitHrsMinsString(actionsInfo.exploring) != nil ? "Exploring" + " " + splitHrsMinsString(actionsInfo.running)! : nil
        lblRestingHours.text = splitHrsMinsString(actionsInfo.resting) != nil ? "Resting" + " " +  splitHrsMinsString(actionsInfo.running)! : nil
    }
    
    func splitHrsMinsString(_ hrsMinsString: String) -> String? {
        let components = hrsMinsString.split(separator: ":")
        if components.count == 3 {
            let hrs = Int(components[0])!
            let minutes = Int(components[1])!
            let seconds = Int(components[2])!
            let hrsString: String
            let minString: String
            let secString: String
            if hrs == 0 {
                if minutes > 0 {
                    hrsString = "0 hrs"
                } else {
                    hrsString = ""
                }
            } else {
                if hrs == 1 {
                    hrsString = "1 hr"
                } else {
                    hrsString = "\(hrs) hrs"
                }
            }
            
            if minutes == 0 {
                if seconds > 0 {
                    minString = "0 mins"
                } else {
                    minString = ""
                }
            } else {
                if minutes == 1 {
                    minString = "1 min"
                } else {
                    minString = "\(minutes) mins"
                }
            }
            
            if seconds == 0 {
                secString = ""
            } else {
                if seconds == 1 {
                    secString = "1 sec"
                } else {
                    secString = "\(seconds) secs"
                }
            }
            
            let finalString = hrsString + minString + secString == "" ? "0 mins" : hrsString + minString + secString
            
            return finalString
        }
        return nil
    }
}

class HomeVCPlaceHolder: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PostLoginRouter.showHomeView()
    }
}
