//
//  ProfileTypePet.swift
//  Trackzia
//
//  Created by Rohan Bhale on 15/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import Foundation

struct ProfileTypePet {
    let name: String
    let birthDate: String
    let breed: String
    let color: String
    let gender: String
    let height: String
    let doctorInfo: String
    let neutered: String
    let type: String
    let weight: String
    let activated: String
}

func profileTypePet(dictionary: [String: String]) -> ProfileTypePet {
    let name = dictionary["PetName"] ?? ""
    let birthDate = dictionary["BirthDate"] ?? ""
    let breed = dictionary["Breed"] ?? ""
    let color = dictionary["Color"] ?? ""
    let gender = dictionary["Gender"] ?? ""
    let height = dictionary["Height"] ?? ""
    let doctorInfo = dictionary["DoctorInfo"] ?? ""
    let neutered = dictionary["Neutered"] ?? ""
    let type = dictionary["Type"] ?? ""
    let weight = dictionary["Weight"] ?? ""
    let activated = dictionary["Activated"] ?? ""
    return ProfileTypePet(name: name,
                          birthDate: birthDate,
                          breed: breed,
                          color: color,
                          gender: gender,
                          height: height,
                          doctorInfo: doctorInfo,
                          neutered: neutered,
                          type: type,
                          weight: weight,
                          activated: activated)
}
