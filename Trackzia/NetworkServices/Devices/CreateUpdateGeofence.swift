//
//  CreateUpdateGeofence.swift
//  Trackzia
//
//  Created by Rohan Bhale on 03/02/19.
//  Copyright © 2019 Private. All rights reserved.
//

import Foundation
import ApiManager
import CoreLocation
//http://13.233.18.64:1166/api/Geofence/CreateUpdate

class CreateUpdateGeofence: CommunicationEndPoint {
    var urlPath: String {
        return "\(baseURLAbsoluteString)/api/Geofence/CreateUpdate"
    }
    
    var httpMethod = HTTPMethod.post
    
    var hearders: HTTPHeaders = [:]
    
    var parameters: Parameters? {
        return createUpdateModel.parameters()
    }
    
    var operationId: Int = 0
    
    var listener: CommunicationResultListener
    
    var createUpdateModel: GeoFenceCreateUpdateModel
    
    init(createUpdateModel: GeoFenceCreateUpdateModel, listener: CommunicationResultListener) {
        self.listener = listener
        self.createUpdateModel = createUpdateModel
    }
    
    func parseResponse(withOperationId operationId: Int, andStatusCode: Int, data: Data) throws -> CommunicationOperationResult {
        if let dataString = String(data: data, encoding: .utf8) {
            print(dataString)
        }
        
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(CreateUpdateGeofenceResponse.self, from: data)
            let wrapper = CreateUpdateGeofenceResponseWrapper(createUpdateModel: createUpdateModel, response: response)
            return wrapper
        } catch let jsonParsingError {
            fatalError(jsonParsingError.localizedDescription)
        }
    }
}

struct GeoFenceCreateUpdateModel {
    let imei: IMEI
    let name: String
    let startTime: String
    let endTime: String
    let lat: CLLocationDegrees
    let long: CLLocationDegrees
    let radius: Int
    let type: String
    let geoEndTime: String
    
    init(imei: IMEI, name: String, startTime: String, endTime: String, lat: CLLocationDegrees, long: CLLocationDegrees, radius: Int, type: String, geoEndTime: String) {
        self.imei = imei
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.lat = lat
        self.long = long
        self.radius = radius
        self.type = type
        self.geoEndTime = geoEndTime
    }
    
    init(geoLockWithName name: String, imei: IMEI, lat: CLLocationDegrees, long: CLLocationDegrees, radius: Int, geoEndTime: String) {
        self.init(imei: imei, name: name, startTime: "00", endTime: "", lat: lat, long: long, radius: radius, type: "GeoLock", geoEndTime: geoEndTime)
    }
    
    init(geoFenceWithName name: String, imei: IMEI, lat: CLLocationDegrees, long: CLLocationDegrees, radius: Int, startTime: String, endTime: String, type: String) {
        self.init(imei: imei, name: name, startTime: startTime, endTime: endTime, lat: lat, long: long, radius: radius, type: type, geoEndTime: "")
    }
    
    func parameters() ->Parameters {
        var params: Parameters = ["IMEI": imei,"Name": name, "Lat": lat, "Lng": long, "Radius": radius, "GeofenceType": type]
        if type == "GeoLock" {
            params["StartTime"] = startTime
            let components = geoEndTime.split(separator: ":")
            let minutes = Int(components[0])! * 60 + Int(components[1])!
            params["GeoEndTime"] = String(minutes)
        } else {
            params["StartTime"] = startTime
            params["EndTime"] = endTime
        }
        return params
    }
}

struct CreateUpdateGeofenceResponseWrapper: CommunicationOperationResult {
    let createUpdateModel: GeoFenceCreateUpdateModel
    let response: CreateUpdateGeofenceResponse
}

struct CreateUpdateGeofenceResponse: CommunicationOperationResult, Codable {
    let message: String
    let success: Bool
    let data: String?
    
    private enum CodingKeys: String, CodingKey {
        case message =  "Message"
        case success = "Success"
        case data = "Data"
    }
}


/*
 {
 "Message": "Geofence Created/Updated Successfully",
 "Success": true,
 "Data": null
 }
 */
