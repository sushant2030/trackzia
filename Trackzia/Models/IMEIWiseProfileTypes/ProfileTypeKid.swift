//
//  ProfileTypeKid.swift
//  Trackzia
//
//  Created by Rohan Bhale on 15/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import Foundation

struct ProfileTypeKid {
    let name: String
    let birthDate: String
    let bodyType: String
    let color: String
    let gender: String
    let height: String
    let school: String
    let sonDaughter: String
    let activated: String
}

func profileTypeKid(dictionary: [String: String]) -> ProfileTypeKid {
    let name = dictionary["KidName"] ?? ""
    let birthDate = dictionary["BirthDate"] ?? ""
    let bodyType = dictionary["BodyType"] ?? ""
    let color = dictionary["Color"] ?? ""
    let gender = dictionary["Gender"] ?? ""
    let height = dictionary["Height"] ?? ""
    let school = dictionary["School"] ?? ""
    let sonDaughter = dictionary["SonDaughter"] ?? ""
    let activated = dictionary["Activated"] ?? ""
    return ProfileTypeKid(name: name,
                          birthDate: birthDate,
                          bodyType: bodyType,
                          color: color,
                          gender: gender,
                          height: height,
                          school: school,
                          sonDaughter: sonDaughter,
                          activated: activated)
}
