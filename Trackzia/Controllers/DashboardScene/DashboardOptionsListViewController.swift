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

protocol DashboardOptionsListViewControllerDelegate: class {
    func dashboardOptionsListViewController(_ dashboardOptionsListViewController: DashboardOptionsListViewController, didSelectUserOption option: DashboardListUserOption)
    
    func dashboardOptionsListViewController(_ dashboardOptionsListViewController: DashboardOptionsListViewController, didSelectTrackListOption option: DashboardTrackListOptions)
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
    
    weak var delegate: DashboardOptionsListViewControllerDelegate!
    
    var imeiSelectionManagerListenerToken: IMEISelectionManagerListenerToken!
    
    var imeiWiseProfileListenerToken:IMEIWiseProfileListenerToken!
    
    deinit {
        IMEISelectionManager.shared.removeListener(token: imeiSelectionManagerListenerToken)
        UserDataManager.shared.removeListener(imeiWiseProfileListenerToken)
    }
    
    override func viewDidLoad() {
        setupTableForUserOptionsMode()
        imeiSelectionManagerListenerToken = IMEISelectionManager.shared.addListener(imeiSelectionManagerListener)
        imeiWiseProfileListenerToken = UserDataManager.shared.addListener(imeiWiseProfileChangesListener)
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
    
    func imeiSelectionManagerListener() {
        if dashboardOptionListMode == .userTrackOptions {
            userTrackingOptionsDataSource.models = userTrackingOptionsModels()
            tableView.reloadData()
        }
    }
    
    func imeiWiseProfileChangesListener(_ imeiNumber: String) {
        if dashboardOptionListMode == .userTrackOptions {
            if UserDataManager.shared.imeiList.count > IMEISelectionManager.shared.selectedIndex {
                let dataDisplayedForIMEINumber = UserDataManager.shared.imeiList[IMEISelectionManager.shared.selectedIndex]
                if dataDisplayedForIMEINumber == imeiNumber {
                    userTrackingOptionsDataSource.models = userTrackingOptionsModels()
                    tableView.reloadData()
                }
            }
        }
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch dashboardOptionListMode {
        case .userOptions:
            guard let selectedOption = DashboardListUserOption(rawValue: indexPath.row) else { fatalError("No such option for DashboardListUserOption") }
            delegate.dashboardOptionsListViewController(self, didSelectUserOption: selectedOption)
        case .userTrackOptions:
            guard let selectedOption = DashboardTrackListOptions(rawValue: indexPath.row) else { fatalError("No such option for DashboardTrackListOptions") }
            delegate.dashboardOptionsListViewController(self, didSelectTrackListOption: selectedOption)
            
        }
    }
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
    if UserDataManager.shared.imeiList.count > IMEISelectionManager.shared.selectedIndex {
        var pet = UserDashboardOption(text: "Pet", showAddButton: false, isSelected: false, cellIdentifier: "TrackCategoryCell")
        var kid = UserDashboardOption(text: "Kid", showAddButton: false, isSelected: false, cellIdentifier: "TrackCategoryCell")
        var seniorCitizen = UserDashboardOption(text: "Senior Citizen", showAddButton: false, isSelected: false, cellIdentifier: "TrackCategoryCell")
        var vehicle = UserDashboardOption(text: "Vehicle", showAddButton: false, isSelected: false, cellIdentifier: "TrackCategoryCell")
        var other = UserDashboardOption(text: "Other", showAddButton: false, isSelected: false, cellIdentifier: "TrackCategoryCell")
        let addDevice = UserDashboardOption(text: "Add Device", showAddButton: true, isSelected: false, cellIdentifier: "TrackCategoryCell")
        
        let imeiNumber = UserDataManager.shared.imeiList[IMEISelectionManager.shared.selectedIndex]
        let profileTypes = UserDataManager.shared.profileTypesFrom(imeiNumber: imeiNumber)
        
        profileTypes.forEach({
            switch $0 {
            case let petProfile as ProfileTypePet: pet.isSelected = petProfile.name.count > 0 ? true : false
            case let kidProfile as ProfileTypeKid: kid.isSelected = kidProfile.name.count > 0 ? true : false
            case let seniorCitizenProfile as ProfileTypeSeniorCitizen: seniorCitizen.isSelected = seniorCitizenProfile.name.count > 0 ? true : false
                
            case let vehicleProfile as ProfileTypeVehicle: vehicle.isSelected = vehicleProfile.name.count > 0 ? true : false
            case let otherProfile as ProfileTypeOther: other.isSelected = otherProfile.name.count > 0 ? true : false
            default: print("")
            }
        })
        
        
        return [[pet, kid, seniorCitizen, vehicle, other, addDevice]]
    } else {
        return []
    }
}


enum DashboardListUserOption: Int {
    case profile = 0
    case geofence
    case changePassword
    case alertSettings
}

enum DashboardTrackListOptions: Int {
    case pet
    case kid
    case seniorCitizen
    case vehicle
    case other
    case addDevice
}
