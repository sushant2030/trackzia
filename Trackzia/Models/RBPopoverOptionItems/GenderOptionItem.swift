//
//  Gender.swift
//  Trackzia
//
//  Created by Rohan Bhale on 18/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit

enum Gender {
    case male
    case female
    case other
}

struct GenderOptionItem: RBOptionItem {
    var text: String
    var font = UIFont.systemFont(ofSize: 13)
    var isSelected: Bool
    var gender: Gender
}

func genderOptionItems() -> [[GenderOptionItem]] {
    let descriptor = UIFontDescriptor(name: "Helvetica Neue", size: 19.0)
    let font = UIFont(descriptor: descriptor, size: 19.0)
    let male = GenderOptionItem(text: "Male", font: font, isSelected: false, gender: .male)
    let female = GenderOptionItem(text: "Female", font: font, isSelected: false, gender: .female)
    let other = GenderOptionItem(text: "Other", font: font, isSelected: false, gender: .other)
    return [[male, female, other]]
}
