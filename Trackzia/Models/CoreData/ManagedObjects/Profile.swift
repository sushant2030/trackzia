//
//  Profile.swift
//  Trackzia
//
//  Created by Rohan Bhale on 29/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import CoreData

enum ProfileType: String {
    case pet = "Pet"
    case kid = "Kid"
    case seniorCitizen = "SeniorCitizen"
    case vehicle = "Vehicle"
    case other = "Other"
}

class Profile: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var profileType: String
    @NSManaged var sync: String?
    @NSManaged var updatedAt: Date
    @NSManaged var com1: String?
    @NSManaged var com2: String?
    @NSManaged var com3: String?
    @NSManaged var com4: String?
    @NSManaged var com5: String?
    @NSManaged var com6: String?
    @NSManaged var com7: String?
    @NSManaged var com8: String?
    @NSManaged var com9: String?
    
    @NSManaged var device: Device
    
    static func insert(into context: NSManagedObjectContext, profileDictionary: [String: String]) -> Profile {
        let profile: Profile = context.insertObject()
        let profileTypeString = profileDictionary["ProfileType"]!
        let profileType = ProfileType(rawValue: profileTypeString)!
        switch profileType {
        case .pet: buildPetProfile(profile, profileDictionary: profileDictionary)
        case .kid: buildKidProfile(profile, profileDictionary: profileDictionary)
        case .seniorCitizen: buildSeniorCitizenProfile(profile, profileDictionary: profileDictionary)
        case .vehicle: buildVehicleProfile(profile, profileDictionary: profileDictionary)
        case .other: buildOtherProfile(profile, profileDictionary: profileDictionary)
        }
        return profile
    }
    
    static func profileDictionary(from profile: Profile) -> [String: String] {
        let profileType = ProfileType(rawValue: profile.profileType)!
        switch profileType {
        case .pet: return petProfileDictionary(from: profile)
        case .kid: return kidProfileDictionary(from: profile)
        case .seniorCitizen: return seniorCitizenProfileDictionary(from: profile)
        case .vehicle: return vehicleProfileDictionary(from: profile)
        case .other: return otherProfileDictionary(from: profile)
        }
    }
    
    static func buildPetProfile(_ profile: Profile, profileDictionary: [String: String]) {
        //{"ProfileType":"Pet","PetName":"Puppy","BirthDate":"13-11-2018","Breed":"dog","Color":"white","Gender":"Male","Height":"1.5","DoctorInfo":"dr","Neutered":"No","Type":"dog","Weight":"25","Activated":"Yes"}
        profile.name = profileDictionary["PetName"]!
        profile.profileType = ProfileType.pet.rawValue
        profile.updatedAt = Date()
        profile.com1 = profileDictionary["Color"]
        profile.com2 = profileDictionary["Height"]
        profile.com3 = profileDictionary["Breed"]
        profile.com4 = profileDictionary["Neutered"]
        profile.com5 = profileDictionary["Gender"]
        profile.com6 = profileDictionary["BirthDate"]
        profile.com7 = profileDictionary["Weight"]
        profile.com8 = profileDictionary["DoctorInfo"]
        profile.com9 = profileDictionary["Type"]
    }
    
    static func petProfileDictionary(from profile: Profile) -> [String: String] {
        var profileDictionary = [String: String]()
        profileDictionary["PetName"] = profile.name
        profileDictionary["ProfileType"] = ProfileType.pet.rawValue
        profileDictionary["Color"] = profile.com1
        profileDictionary["Height"] = profile.com2
        profileDictionary["Breed"] = profile.com3
        profileDictionary["Neutered"] = profile.com4
        profileDictionary["Gender"] = profile.com5
        profileDictionary["BirthDate"] = profile.com6
        profileDictionary["Weight"] = profile.com7
        profileDictionary["DoctorInfo"] = profile.com8
        profileDictionary["Type"] = profile.com9
        return profileDictionary
    }
    
    static func buildKidProfile(_ profile: Profile, profileDictionary: [String: String]) {
//        {"ProfileType":"Kid","KidName":"","BirthDate":"","BodyType":"","Color":"","Gender":"","Height":"","School":"","SonDaughter":"","Activated":"No"}
        profile.name = profileDictionary["KidName"]!
        profile.profileType = ProfileType.kid.rawValue
        profile.updatedAt = Date()
        profile.com1 = profileDictionary["Color"]
        profile.com2 = profileDictionary["Height"]
        profile.com3 = profileDictionary["SonDaughter"]
        profile.com4 = profileDictionary["BirthDate"]
        profile.com5 = profileDictionary["Gender"]
        profile.com6 = profileDictionary["School"]
        profile.com7 = profileDictionary["BodyType"]
    }
    
    static func kidProfileDictionary(from profile: Profile) -> [String: String] {
        var profileDictionary = [String: String]()
        profileDictionary["KidName"] = profile.name
        profileDictionary["ProfileType"] = ProfileType.kid.rawValue
        profileDictionary["Color"] = profile.com1
        profileDictionary["Height"] = profile.com2
        profileDictionary["SonDaughter"] = profile.com3
        profileDictionary["BirthDate"] = profile.com4
        profileDictionary["Gender"] = profile.com5
        profileDictionary["School"] = profile.com6
        profileDictionary["BodyType"] = profile.com7
        return profileDictionary
    }
    
    static func buildSeniorCitizenProfile(_ profile: Profile, profileDictionary: [String: String]) {
//        {"ProfileType":"SeniorCitizen","SeniorName":"","BirthDate":"","BodyType":"","Color":"","Gender":"","Height":"","DoctorInfo":"","SonDaughter":"","Activated":"No"}
        profile.name = profileDictionary["SeniorName"]!
        profile.profileType = ProfileType.seniorCitizen.rawValue
        profile.updatedAt = Date()
        profile.com1 = profileDictionary["Color"]
        profile.com2 = profileDictionary["Height"]
        profile.com3 = profileDictionary["SonDaughter"]
        profile.com4 = profileDictionary["BirthDate"]
        profile.com5 = profileDictionary["Gender"]
        profile.com6 = profileDictionary["BodyType"]
        profile.com7 = profileDictionary["DoctorInfo"]
    }
    
    static func seniorCitizenProfileDictionary(from profile: Profile) -> [String: String] {
        var profileDictionary = [String: String]()
        profileDictionary["SeniorName"] = profile.name
        profileDictionary["ProfileType"] = ProfileType.seniorCitizen.rawValue
        profileDictionary["Color"] = profile.com1
        profileDictionary["Height"] = profile.com2
        profileDictionary["SonDaughter"] = profile.com3
        profileDictionary["BirthDate"] = profile.com4
        profileDictionary["Gender"] = profile.com5
        profileDictionary["BodyType"] = profile.com6
        profileDictionary["DoctorInfo"] = profile.com7
        return profileDictionary
    }
    
    static func buildVehicleProfile(_ profile: Profile, profileDictionary: [String: String]) {
//        {"ProfileType":"Vehicle","VehicleName":"","ChassieNo":"","Color":"","Model":"","PurchaseDate":"","Type":"","Activated":"No"}
        profile.name = profileDictionary["VehicleName"]!
        profile.profileType = ProfileType.vehicle.rawValue
        profile.updatedAt = Date()
        profile.com1 = profileDictionary["Type"]
        profile.com2 = profileDictionary["ChassieNo"]
        profile.com3 = profileDictionary["PurchaseDate"]
        profile.com4 = profileDictionary["Color"]
        profile.com5 = profileDictionary["Model"]
    }
    
    static func vehicleProfileDictionary(from profile: Profile) -> [String: String] {
        var profileDictionary = [String: String]()
        profileDictionary["VehicleName"] = profile.name
        profileDictionary["ProfileType"] = ProfileType.vehicle.rawValue
        profileDictionary["Type"] = profile.com1
        profileDictionary["ChassieNo"] = profile.com2
        profileDictionary["PurchaseDate"] = profile.com3
        profileDictionary["Color"] = profile.com4
        profileDictionary["Model"] = profile.com5
        return profileDictionary
    }
    
    static func buildOtherProfile(_ profile: Profile, profileDictionary: [String: String]) {
//        {"ProfileType":"Other","Description":"hcjdjd","ProfileName":"Other","Activated":"No"}
        profile.name = profileDictionary["ProfileName"]!
        profile.profileType = ProfileType.other.rawValue
        profile.updatedAt = Date()
        profile.com1 = profileDictionary["Description"]
    }
    
    static func otherProfileDictionary(from profile: Profile) -> [String: String] {
        var profileDictionary = [String: String]()
        profileDictionary["ProfileName"] = profile.name
        profileDictionary["ProfileType"] = ProfileType.other.rawValue
        profileDictionary["Description"] = profile.com1
        return profileDictionary
    }
}

extension Profile: Managed {
    
}
