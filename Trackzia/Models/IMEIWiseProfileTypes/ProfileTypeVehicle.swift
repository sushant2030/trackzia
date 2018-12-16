//
//  ProfileTypeVehicle.swift
//  Trackzia
//
//  Created by Rohan Bhale on 15/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import Foundation

struct ProfileTypeVehicle {
    let name: String
    let chasisNo: String
    let color: String
    let model: String
    let purchaseDate: String
    let type: String
    let activated: String
}

func profileTypeVehicle(dictionary: [String: String]) -> ProfileTypeVehicle {
    let name = dictionary["VehicleName"] ?? ""
    let chasisNo = dictionary["ChassieNo"] ?? ""
    let color = dictionary["Color"] ?? ""
    let model = dictionary["Model"] ?? ""
    let purchaseDate = dictionary["PurchaseDate"] ?? ""
    let type = dictionary["Type"] ?? ""
    let activated = dictionary["Activated"] ?? ""
    return ProfileTypeVehicle(name: name,
                              chasisNo: chasisNo,
                              color: color,
                              model: model,
                              purchaseDate: purchaseDate,
                              type: type,
                              activated: activated)
}
