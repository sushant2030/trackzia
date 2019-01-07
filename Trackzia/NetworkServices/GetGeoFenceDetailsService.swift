//
//  GetGeoFenceDetails.swift
//  Trackzia
//
//  Created by Rohan Bhale on 30/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import ApiManager

class GetGeoFenceDetailsService: CommunicationEndPoint {
    var urlPath: String {
        return "http://13.233.18.64:1166/api/Geofence/GetDetails"
    }
    
    var httpMethod = HTTPMethod.post
    
    var hearders: HTTPHeaders = [:]
    
    var parameters: Parameters? {
        return ["IMEI": String(imei)]
    }
    
    var operationId: Int = 0
    
    var listener: CommunicationResultListener
    
    let imei: IMEI
    
    init(imei: IMEI, listener: CommunicationResultListener) {
        self.imei = imei
        self.listener = listener
    }
    
    func parseResponse(withOperationId operationId: Int, andStatusCode: Int, data: Data) throws -> CommunicationOperationResult {
        if let dataString = String(data: data, encoding: .utf8) {
            print(dataString)
        }
        
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(GetGeoFenceDetailsServiceResult.self, from: data)
            let wrapper = GetGeoFenceDetailsServiceResultWrapper(imei: imei, result: result)
            return wrapper
        } catch let jsonParsingError {
            fatalError(jsonParsingError.localizedDescription)
        }
    }
}

struct GetGeoFenceDetailsServiceResultWrapper: CommunicationOperationResult {
    let imei: IMEI
    let result: GetGeoFenceDetailsServiceResult
}

struct GetGeoFenceDetailsServiceResult: CommunicationOperationResult, Codable {
    let message: String
    let success: Bool
    let data: [GeoFenceData]
    
    private enum CodingKeys: String, CodingKey {
        case message =  "Message"
        case success = "Success"
        case data = "DataList"
    }
    
    struct GeoFenceData: Codable {
        let type: String
        let name: String
        let lat: String
        let long: String
        let radius: String
        let startTime: String?
        let endTime: String?
        let geoEndTime: String?
        
        private enum CodingKeys: String, CodingKey {
            case type = "GeofenceType"
            case name = "GeoName"
            case lat = "Lat"
            case long = "Lng"
            case radius = "Radius"
            case startTime = "StartTime"
            case endTime = "EndTime"
            case geoEndTime = "GeoEndTime"
        }
    }
}


/*
 {
 "Message": "Geofence Data",
 "Success": true,
 "DataList": [
 {
 "GeofenceType": "GeoHome",
 "GeoName": "Mandir",
 "Lat": "26.914977940978698",
 "Lng": "75.806634016335025",
 "Radius": "5000",
 "StartTime": "12:0",
 "EndTime": "6:0"
 },
 {
 "GeofenceType": "GeoSchool",
 "GeoName": "0",
 "Lat": "0",
 "Lng": "0",
 "Radius": "0",
 "StartTime": "0",
 "EndTime": "0"
 },
 {
 "GeofenceType": "GeoPlayGroud",
 "GeoName": "0",
 "Lat": "0",
 "Lng": "0",
 "Radius": "0",
 "StartTime": "0",
 "EndTime": "0"
 },
 {
 "GeofenceType": "GeoOther",
 "GeoName": "0",
 "Lat": "0",
 "Lng": "0",
 "Radius": "0",
 "StartTime": "0",
 "EndTime": "0"
 },
 {
 "GeofenceType": "GeoLock",
 "GeoName": "0",
 "Lat": "0",
 "Lng": "0",
 "Radius": "0",
 "GeoEndTime": "0"
 }
 ]
 }
*/
