//
//  DashboardOptionsListViewController.swift
//  Trackzia
//
//  Created by Rohan Bhale on 08/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit

class DashboardOptionsListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    
    
}

extension DashboardOptionsListViewController: UITableViewDelegate {
    
}

class DashboardCell: UITableViewCell {
    @IBOutlet var optionLabel: UILabel!
}

class TrackCategoryCell: UITableViewCell {
    @IBOutlet var optionLabel: UILabel!
    @IBOutlet var addButton: UIButton!
}

