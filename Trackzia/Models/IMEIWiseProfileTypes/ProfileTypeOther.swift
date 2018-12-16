//
//  ProfileTypeOther.swift
//  Trackzia
//
//  Created by Rohan Bhale on 15/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import Foundation

struct ProfileTypeOther {
    let name: String
    let description: String
    let activated: String
}

func profileTypeOther(dictionary: [String: String]) -> ProfileTypeOther {
    let name = dictionary["ProfileName"] ?? ""
    let description = dictionary["Description"] ?? ""
    let activated = dictionary["Activated"] ?? ""
    return ProfileTypeOther(name: name, description: description, activated: activated)
}
