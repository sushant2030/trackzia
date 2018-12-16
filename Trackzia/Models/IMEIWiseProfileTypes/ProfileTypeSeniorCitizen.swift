//
//  ProfileTypeSeniorCitizen.swift
//  Trackzia
//
//  Created by Rohan Bhale on 15/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import Foundation

struct ProfileTypeSeniorCitizen {
    let name: String
    let birthDate: String
    let bodyType: String
    let color: String
    let gender: String
    let height: String
    let doctorInfo: String
    let sonDaughter: String
    let activated: String
}

func profileTypeSeniorCitizen(dictionary: [String: String]) -> ProfileTypeSeniorCitizen {
    let name = dictionary["SeniorName"] ?? ""
    let birthDate = dictionary["BirthDate"] ?? ""
    let bodyType = dictionary["BodyType"] ?? ""
    let color = dictionary["Color"] ?? ""
    let gender = dictionary["Gender"] ?? ""
    let height = dictionary["Height"] ?? ""
    let doctorInfo = dictionary["DoctorInfo"] ?? ""
    let sonDaughter = dictionary["SonDaughter"] ?? ""
    let activated = dictionary["Activated"] ?? ""
    return ProfileTypeSeniorCitizen(name: name,
                          birthDate: birthDate,
                          bodyType: bodyType,
                          color: color,
                          gender: gender,
                          height: height,
                          doctorInfo: doctorInfo,
                          sonDaughter: sonDaughter,
                          activated: activated)
}
