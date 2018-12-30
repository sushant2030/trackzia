//
//  IMEIWiseProfilesStore.swift
//  Trackzia
//
//  Created by Rohan Bhale on 29/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import CoreData

class IMEIWiseProfilesStore {
    typealias IMEINumber = String
    
    static var shared = IMEIWiseProfilesStore()
    
    private init() {}
    
    
    
    func setProfiles(in context: NSManagedObjectContext, profileDictionaries: [[String: String]], for imeiNumber: IMEI) {
        if let device = DeviceStore.shared.devices.filter({ $0.imei == imeiNumber }).first {
            context.performChanges {
                device.profiles?.forEach({ context.delete($0) })
                device.profiles = []
                
                for profileDictionary in profileDictionaries {
                    let profile = Profile.insert(into: context, profileDictionary: profileDictionary)
                    device.profiles?.insert(profile)
                    if profileDictionary["Activated"] == "Yes" {
                        let activeProfile = ActiveProfile.insert(into: context, name: profile.name, profileType: profile.profileType)
                        device.activeProfile = activeProfile
                    }
                }
            }
        }
    }
    
    func profileTypesFrom(imeiNumber: String) -> [Any] {
        let kidProfile = profileTypeKidFrom(imeiNumber: imeiNumber)
        let petProfile = profileTypePetFrom(imeiNumber: imeiNumber)
        let seniorCitizenProfile = profileTypeSeniorCitizenFrom(imeiNumber: imeiNumber)
        let vehicleProfile = profileTypeVehicleFrom(imeiNumber: imeiNumber)
        let otherProfile = profileTypeOtherFrom(imeiNumber: imeiNumber)
        return [petProfile, kidProfile, seniorCitizenProfile, vehicleProfile, otherProfile]
    }
    
    func profileTypeKidFrom(imeiNumber: String) -> ProfileTypeKid {
        guard let device = DeviceStore.shared.devices.filter({ $0.imei == imeiNumber }).first else {
            return profileTypeKid(dictionary: [:])
        }
        
        guard let profile = device.profiles?.filter({ $0.profileType == ProfileType.kid.rawValue }).first else {
            return profileTypeKid(dictionary: [:])
        }
        
        let dictionary = Profile.profileDictionary(from: profile)
        return profileTypeKid(dictionary: dictionary)
    }
    
    func profileTypePetFrom(imeiNumber: String) -> ProfileTypePet {
        guard let device = DeviceStore.shared.devices.filter({ $0.imei == imeiNumber }).first else {
            return profileTypePet(dictionary: [:])
        }
        
        guard let profile = device.profiles?.filter({ $0.profileType == ProfileType.pet.rawValue }).first else {
            return profileTypePet(dictionary: [:])
        }
        
        let dictionary = Profile.profileDictionary(from: profile)
        return profileTypePet(dictionary: dictionary)
    }
    
    func profileTypeSeniorCitizenFrom(imeiNumber: String) -> ProfileTypeSeniorCitizen {
        guard let device = DeviceStore.shared.devices.filter({ $0.imei == imeiNumber }).first else {
            return profileTypeSeniorCitizen(dictionary: [:])
        }
        
        guard let profile = device.profiles?.filter({ $0.profileType == ProfileType.seniorCitizen.rawValue }).first else {
            return profileTypeSeniorCitizen(dictionary: [:])
        }
        
        let dictionary = Profile.profileDictionary(from: profile)
        return profileTypeSeniorCitizen(dictionary: dictionary)
    }
    
    func profileTypeVehicleFrom(imeiNumber: String) -> ProfileTypeVehicle {
        guard let device = DeviceStore.shared.devices.filter({ $0.imei == imeiNumber }).first else {
            return profileTypeVehicle(dictionary: [:])
        }
        
        guard let profile = device.profiles?.filter({ $0.profileType == ProfileType.vehicle.rawValue }).first else {
            return profileTypeVehicle(dictionary: [:])
        }
        
        let dictionary = Profile.profileDictionary(from: profile)
        return profileTypeVehicle(dictionary: dictionary)
    }
    
    func profileTypeOtherFrom(imeiNumber: String) -> ProfileTypeOther {
        guard let device = DeviceStore.shared.devices.filter({ $0.imei == imeiNumber }).first else {
            return profileTypeOther(dictionary: [:])
        }
        
        guard let profile = device.profiles?.filter({ $0.profileType == ProfileType.other.rawValue }).first else {
            return profileTypeOther(dictionary: [:])
        }
        
        let dictionary = Profile.profileDictionary(from: profile)
        return profileTypeOther(dictionary: dictionary)
    }
}
