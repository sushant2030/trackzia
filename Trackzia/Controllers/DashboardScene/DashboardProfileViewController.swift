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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userProfileImageView.layer.cornerRadius = 30
        userProfileImageView.layer.masksToBounds = true
    }
    
    @IBAction func arrowButtonTouched(_ sender: UIButton) {
        delegate.arrowButtonTouched(sender)
    }
}

extension DashboardProfileViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackedProfileCell", for: indexPath)
        return cell
    }
}

extension DashboardProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
