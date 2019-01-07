//
//  GetDataPacketsService.swift
//  Trackzia
//
//  Created by Rohan Bhale on 01/01/19.
//  Copyright © 2019 Private. All rights reserved.
//

import ApiManager

/*
 http://13.233.18.64:1166/api/DeviceData/GetData?IMEI=865067027076895&time_stamp=20180926154511
 [{
 "IMEI": 865067027076895,
 "Time_stamp": 20180926101511,
 "Lat": 16.058798,
 "Lng": 73.471153,
 "Panic": 0,
 "Battery": 82.8571,
 "Speed": 0.89,
 "Charging": false,
 "Accuracy": 2.5
 }]
 */
class GetDataPacketsService: CommunicationEndPoint {
    var urlPath: String {
        return "http://13.233.18.64:1166/api/DeviceData/GetData"
    }
    
    var httpMethod = HTTPMethod.post
    
    var hearders: HTTPHeaders = [:]
    
    var parameters: Parameters? {
        return ["IMEI": String(imei),
                "time_stamp": timeStamp]
    }
    
    var operationId: Int = 0
    
    var listener: CommunicationResultListener
    
    let imei: IMEI
    let timeStamp: String
    
    init(imei: IMEI, timeStamp: String, listener: CommunicationResultListener) {
        self.imei = imei
        self.timeStamp = timeStamp
        self.listener = listener
    }
    
    func parseResponse(withOperationId operationId: Int, andStatusCode: Int, data: Data) throws -> CommunicationOperationResult {
        if let dataString = String(data: data, encoding: .utf8) {
            print(dataString)
        }
        
        do {
            let decoder = JSONDecoder()
            let packets = try decoder.decode([GetDataPacketsServiceResponse].self, from: data)
            let wrapper = GetDataPacketsServiceResponseWrapper(imei: imei, packets: packets)
            return wrapper
        } catch let jsonParsingError {
            fatalError(jsonParsingError.localizedDescription)
        }
    }
}

struct GetDataPacketsServiceResponseWrapper: CommunicationOperationResult {
    let imei: IMEI
    let packets: [GetDataPacketsServiceResponse]
}

struct GetDataPacketsServiceResponse: CommunicationOperationResult, Codable {
    let imei: String
    let timeStamp: Double
    let lat: Double
    let long: Double
    let panic: Int
    let battery: Float
    let speed: Double
    let charging: Bool
    let accuracy: Double
    
    enum CodingKeys: String, CodingKey {
        case imei = "IMEI"
        case timeStamp = "Time_stamp"
        case lat = "Lat"
        case long = "Lng"
        case panic = "Panic"
        case battery = "Battery"
        case speed = "Speed"
        case charging = "Charging"
        case accuracy = "Accuracy"
    }
}
