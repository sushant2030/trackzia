//
//  DashboardOptionsListViewController.swift
//  Trackzia
//
//  Created by Rohan Bhale on 08/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit

enum DashboardOptionListMode {
    case userOptions
    case userTrackOptions
}


class DashboardOptionsListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    var dashboardOptionsDataSource: DashboardTableDataSource< DashboardCell, UserDashboardOption>!
    var userTrackingOptionsDataSource: DashboardTableDataSource<TrackCategoryCell, UserDashboardOption>!
    
    var dashboardOptionListMode = DashboardOptionListMode.userOptions {
        didSet {
            switch dashboardOptionListMode {
            case .userOptions: setupTableForUserOptionsMode()
                
            case .userTrackOptions: setupTableForUserTrackOptionsMode()
                
            }
        }
    }
    
    override func viewDidLoad() {
        setupTableForUserOptionsMode()
    }
    
    func setupTableForUserOptionsMode() {
        dashboardOptionsDataSource = DashboardTableDataSource< DashboardCell, UserDashboardOption>(models: userDashboardOptionsModels(), delegate: self, tableView: tableView)
    }
    
    func setupTableForUserTrackOptionsMode() {
        userTrackingOptionsDataSource = DashboardTableDataSource< TrackCategoryCell, UserDashboardOption>(models: userTrackingOptionsModels(), delegate: self, tableView: tableView)
    }
    
    func switchTableMode() {
        dashboardOptionListMode = dashboardOptionListMode == .userOptions ? .userTrackOptions : .userOptions
        tableView.reloadData()
    }
}

extension DashboardOptionsListViewController: DashboardTableDataSourceDelegate {
    func configure(_ cell: UITableViewCell, model: DashboardCellModel) {
        if let dashboardCell = cell as? DashboardCell {
            dashboardCell.optionLabel.text = model.text
        }
        
        if let trackCategoryCell = cell as? TrackCategoryCell {
            trackCategoryCell.optionLabel.text = model.text
            trackCategoryCell.addButton.isHidden = !model.showAddButton
            trackCategoryCell.accessoryType = model.isSelected ? .checkmark : .none
        }
    }
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


struct UserDashboardOption:DashboardCellModel {
    var text: String
    var showAddButton: Bool
    var isSelected: Bool
    var cellIdentifier: String
}

func userDashboardOptionsModels() -> [[UserDashboardOption]] {
    let profile = UserDashboardOption(text: "Profile", showAddButton: false, isSelected: false, cellIdentifier: "DashboardCell")
    let geofence = UserDashboardOption(text: "Geo Fence", showAddButton: false, isSelected: false, cellIdentifier: "DashboardCell")
    let changePassword = UserDashboardOption(text: "Change Password", showAddButton: false, isSelected: false, cellIdentifier: "DashboardCell")
    let alertSettings = UserDashboardOption(text: "Alert Settings", showAddButton: false, isSelected: false, cellIdentifier: "DashboardCell")
    return [[profile, geofence, changePassword, alertSettings]]
}

func userTrackingOptionsModels() -> [[UserDashboardOption]] {
    let pet = UserDashboardOption(text: "Pet", showAddButton: false, isSelected: false, cellIdentifier: "TrackCategoryCell")
    let kid = UserDashboardOption(text: "Kid", showAddButton: false, isSelected: true, cellIdentifier: "TrackCategoryCell")
    let seniorCitizen = UserDashboardOption(text: "Senior Citizen", showAddButton: false, isSelected: false, cellIdentifier: "TrackCategoryCell")
    let vehicle = UserDashboardOption(text: "Vehicle", showAddButton: false, isSelected: false, cellIdentifier: "TrackCategoryCell")
    let other = UserDashboardOption(text: "Other", showAddButton: false, isSelected: false, cellIdentifier: "TrackCategoryCell")
    let addDevice = UserDashboardOption(text: "Add Device", showAddButton: true, isSelected: false, cellIdentifier: "TrackCategoryCell")
    return [[pet, kid, seniorCitizen, vehicle, other, addDevice]]
}
