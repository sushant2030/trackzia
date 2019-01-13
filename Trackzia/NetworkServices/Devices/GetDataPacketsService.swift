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
 http://13.233.18.64:1166/api/DeviceData/GetData?IMEI=896574231025467&time_stamp=20190106154511
 http://13.233.18.64:1166/api/DeviceData/GetData?IMEI=865067024571799&time_stamp=20190102150000&zone=+330
 
 http://13.233.18.64:1166/api/DeviceData/GetData?IMEI=861001005322520&time_stamp=20190106154500&zone=+330
 
 // Akanknsha accnt device imei 896574231025467 used below :
 http://13.233.18.64:1166/api/DeviceData/GetData?IMEI=896574231025467&time_stamp=20190106154500&zone=+330
 
 // Shridhar shared device imei 865067027077604 used below:
 http://13.233.18.64:1166/api/DeviceData/GetData?IMEI=865067027077604&time_stamp=20190106154500&zone=+330
 
 
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
                "time_stamp": timeStamp,
                "zone": "+\(DataPacketDateFormatter.dateFormatter.timeZone.secondsFromGMT())"/*"+330"*/]
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
            let response = try decoder.decode(GetDataPacketsServiceResponse.self, from: data)
            let wrapper = GetDataPacketsServiceResponseWrapper(imei: imei, response: response)
            return wrapper
        } catch let jsonParsingError {
            fatalError(jsonParsingError.localizedDescription)
        }
    }
}

struct GetDataPacketsServiceResponseWrapper: CommunicationOperationResult {
    let imei: IMEI
    let response: GetDataPacketsServiceResponse
}

struct GetDataPacketsServiceResponse: CommunicationOperationResult, Codable {
    let deviceDataViewinfo: [DeviceDataViewInfoPacket]
    let deviceDataRestExploreRuninfo: DeviceDataRestExploreRuninfo
    
    enum CodingKeys: String, CodingKey {
        case deviceDataViewinfo = "DeviceDataViewinfo"
        case deviceDataRestExploreRuninfo = "DeviceDataRestExploreRuninfo"
    }
}

struct DeviceDataViewInfoPacket: Codable {
    let imei: String
    let timeStamp: String
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

struct DeviceDataRestExploreRuninfo: Codable {
    let exploring: String
    let resting: String
    let running: String
    let timeStamp: String
    let lat: Double
    let long: Double
    let battery: Float
    let speed: Double
    let charging: Bool
    let complete: Bool
    let accuracy: Double
    
    enum CodingKeys: String, CodingKey {
        case exploring = "Exploring"
        case resting = "Resting"
        case running = "Running"
        case timeStamp = "Time_stamp"
        case lat = "Lat"
        case long = "Lng"
        case battery = "Battery"
        case speed = "Speed"
        case charging = "Charging"
        case complete = "Complete"
        case accuracy = "Accuracy"
    }
}


/*
 // Shridhar shared device imei 865067027077604 response
 {
     "DeviceDataViewinfo":[
         {
         "IMEI": 865067027077604,
         "Time_stamp": "2019-01-06T15:45:18",
         "Lat": 22.198765,
         "Lng": 73.19167,
         "Panic": 0,
         "Battery": 72.8571,
         "Speed": 44.26,
         "Charging": false,
         "Accuracy": 2.5
         }
     ]
 
     "DeviceDataRestExploreRuninfo": {
         "Exploring": "00:08:36",
         "Resting": "06:05:36",
         "Running": "02:00:11",
         "Time_stamp": "2019-01-06T23:59:41",
         "Lat": 22.770528,
         "Lng": 72.850683,
         "Battery": 78.5714,
         "Speed": 41.74,
         "Charging": false,
         "Complete": true,
         "Accuracy": 2.5
     }
 }
 
 */

/*
 Akanksha device imei 896574231025467
 {
     "DeviceDataViewinfo": [],
     "DeviceDataRestExploreRuninfo": {
         "Exploring": "00:00:00",
         "Resting": "00:00:00",
         "Running": "00:00:00",
         "Time_stamp": "0001-01-01T00:00:00",
         "Lat": 0,
         "Lng": 0,
         "Battery": 0,
         "Speed": 0,
         "Charging": false,
         "Complete": false,
         "Accuracy": 0
     }
 }
 */
