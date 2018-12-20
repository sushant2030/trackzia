//
//  CountryOptionItem.swift
//  Trackzia
//
//  Created by Rohan Bhale on 18/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit

enum Country {
    case india
    case america
    case africa
}

struct CountryOptionItem: RBOptionItem {
    var text: String
    var font = UIFont.systemFont(ofSize: 13)
    var isSelected: Bool
    var country: Country
}

func countryOptionItems() -> [[CountryOptionItem]] {
    let descriptor = UIFontDescriptor(name: "Helvetica Neue", size: 19.0)
    let font = UIFont(descriptor: descriptor, size: 19.0)
    let india = CountryOptionItem(text: "India", font: font, isSelected: false, country: .india)
    let america = CountryOptionItem(text: "America", font: font, isSelected: false, country: .america)
    let africa = CountryOptionItem(text: "Africa", font: font, isSelected: false, country: .africa)
    return [[india, america, africa]]
}

enum State {
    case maharashtra
    case karnataka
    case madhyaPradesh
}

struct StateOptionItem: RBOptionItem {
    var text: String
    var font = UIFont.systemFont(ofSize: 13)
    var isSelected: Bool
    var state: State
}

func stateOptionItems() -> [[StateOptionItem]] {
    let descriptor = UIFontDescriptor(name: "Helvetica Neue", size: 19.0)
    let font = UIFont(descriptor: descriptor, size: 19.0)
    
    let maharashtra = StateOptionItem(text: "Maharashtra", font: font, isSelected: false, state: .maharashtra)
    let karnataka = StateOptionItem(text: "Karnataka", font: font, isSelected: false, state: .karnataka)
    let madhyaPradesh = StateOptionItem(text: "MadhyaPradesh", font: font, isSelected: false, state: .madhyaPradesh)
    return [[maharashtra, karnataka, madhyaPradesh]]
}

enum City {
    case solapur
    case pune
    case mumbai
    case kolhapur
}

struct CityOptionItem: RBOptionItem {
    var text: String
    var font = UIFont.systemFont(ofSize: 13)
    var isSelected: Bool
    var city: City
}

func cityOptionItems() -> [[CityOptionItem]] {
    let descriptor = UIFontDescriptor(name: "Helvetica Neue", size: 19.0)
    let font = UIFont(descriptor: descriptor, size: 19.0)
    
    let solapur = CityOptionItem(text: "Solapur", font: font, isSelected: false, city: .solapur)
    let pune = CityOptionItem(text: "Pune", font: font, isSelected: false, city: .pune)
    let mumbai = CityOptionItem(text: "Mumbai", font: font, isSelected: false, city: .mumbai)
    let kolhapur = CityOptionItem(text: "Kolhapur", font: font, isSelected: false, city: .kolhapur)
    
    return [[solapur, pune, mumbai, kolhapur]]
}
