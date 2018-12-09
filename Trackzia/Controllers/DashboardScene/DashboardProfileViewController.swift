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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userProfileImageView.layer.cornerRadius = 30
        userProfileImageView.layer.masksToBounds = true
        
        gradientLayer.colors = [UIColor(red: CGFloat(255.0 / 255.0), green: CGFloat(153.0 / 255.0), blue: CGFloat(39.0 / 255.0), alpha: 1.0).cgColor,
                                UIColor.red.cgColor,
                                UIColor(red: CGFloat(137.0 / 255.0), green: 0.0, blue: CGFloat(175.0 / 255.0), alpha: 1.0).cgColor]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        view.layer.insertSublayer(gradientLayer, at:0)
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
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackedProfileCell", for: indexPath) as! TrackedProfileCell
        cell.imageView.layer.cornerRadius = CGFloat(45 / 2)
        cell.imageView.layer.masksToBounds = true
        return cell
    }
}

extension DashboardProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

class TrackedProfileCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var label: UILabel!
}
