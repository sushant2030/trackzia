//
//  VehicleTypeOptionItems.swift
//  Trackzia
//
//  Created by Rohan Bhale on 18/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit

enum VehicleType {
    case twoWheeler
    case threeWheeler
    case fourWheeler
}

struct VehicleTypeOptionItem: RBOptionItem {
    var text: String
    var font = UIFont.systemFont(ofSize: 13)
    var isSelected: Bool
    var type: VehicleType
}

func vehicleTypeOptionItems() -> [[VehicleTypeOptionItem]] {
    let descriptor = UIFontDescriptor(name: "Helvetica Neue", size: 19.0)
    let font = UIFont(descriptor: descriptor, size: 19.0)
    let twoWheeler = VehicleTypeOptionItem(text: "2 Wheeler", font: font, isSelected: false, type: .twoWheeler)
    let threeWheeler = VehicleTypeOptionItem(text: "3 Wheeler", font: font, isSelected: false, type: .threeWheeler)
    let fourWheeler = VehicleTypeOptionItem(text: "4 Wheeler", font: font, isSelected: false, type: .fourWheeler)
    return [[twoWheeler, threeWheeler, fourWheeler]]
}
