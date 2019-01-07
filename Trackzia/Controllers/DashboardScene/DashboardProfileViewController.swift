//
//  DashboardProfileViewController.swift
//  Trackzia
//
//  Created by Rohan Bhale on 07/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit

protocol DashboardProfileViewControllerDelegate: class {
    func arrowButtonTouched(_ sender: UIButton)
}

class DashboardProfileViewController: UIViewController {
    @IBOutlet var userProfileImageView: UIImageView!
    @IBOutlet var trackedProfilesCollectionView: UICollectionView!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var button: UIButton!
    
    weak var delegate: DashboardProfileViewControllerDelegate!
    let gradientLayer = CAGradientLayer()
    
    var account: Account!
    var devices: [Device] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        account = UserDataStore.shared.account!
        if let accountDevices = account.devices {
            let sortedArray:[Device] = accountDevices.sorted(by: { $0.order > $1.order })
            devices.append(contentsOf: sortedArray)
            if let firstDevice = devices.first {
                DispatchQueue.main.async {
                    IMEISelectionManager.shared.selectedDevice = firstDevice
                }
            }
        }
        
        userProfileImageView.layer.cornerRadius = 30
        userProfileImageView.layer.masksToBounds = true
        
        gradientLayer.colors = [UIColor(red: CGFloat(255.0 / 255.0), green: CGFloat(153.0 / 255.0), blue: CGFloat(39.0 / 255.0), alpha: 1.0).cgColor,
                                UIColor.red.cgColor,
                                UIColor(red: CGFloat(137.0 / 255.0), green: 0.0, blue: CGFloat(175.0 / 255.0), alpha: 1.0).cgColor]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        view.layer.insertSublayer(gradientLayer, at:0)
        //896574231025467
        
        updateFields()
    }
    
    func updateFields() {
        nameLabel.text = account.fullName
        emailLabel.text = account.emailId
    }
    
    @IBAction func arrowButtonTouched(_ sender: UIButton) {
        delegate.arrowButtonTouched(sender)
    }
    
    override func viewWillLayoutSubviews() {
        gradientLayer.frame = view.bounds
    }
}

extension DashboardProfileViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return devices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackedProfileCell", for: indexPath) as! TrackedProfileCell
        cell.imageView.layer.cornerRadius = CGFloat(45 / 2)
        cell.imageView.layer.masksToBounds = true
        let device = devices[indexPath.item]
        cell.label.text = String(device.imei)
        return cell
    }
}

extension DashboardProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let device = devices[indexPath.item]
        IMEISelectionManager.shared.selectedDevice = device
    }
}

class TrackedProfileCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var label: UILabel!
}
