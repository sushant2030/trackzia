//
//  GetDeviceDataService.swift
//  Trackzia
//
//  Created by Sushant Alone on 15/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import Foundation
import ApiManager

class GetDeviceDataService : CommunicationEndPoint {
    var urlPath: String {
        return "http://13.233.18.64:1166/api/DeviceData/GetData"
    }
    
    var httpMethod: HTTPMethod {
        return .post
    }
    
    var hearders: HTTPHeaders {
        return [:]
    }
    
    var parameters: Parameters? {
        return ["IMEI":"865067023309142","time_stamp":"0"]
    }
    
    var operationId: Int {
        return 9
    }
    
    var name:String!
    var description:String!
    
    
    var listener: CommunicationResultListener
    
    func parseResponse(withOperationId operationId: Int, andStatusCode: Int, data: Data) throws -> CommunicationOperationResult {
        do {
            let decoder = JSONDecoder()
            let otherProfile = try decoder.decode(DeviceDataModel.self, from: data)
            return otherProfile
        } catch let jsonParsingError {
            fatalError(jsonParsingError.localizedDescription)
        }
    }
    
    init(withName name:String, description:String, listener:CommunicationResultListener) {
        self.name = name
        self.description = description
        self.listener = listener
    }
}


struct DeviceDataModel : Codable,CommunicationOperationResult {
    let imei:Int
    let timeStamp:Int
    let lat:Float
    let lng:Float
    let panic:Int
    let battery:Int
    let speed:Float
    let charging : Bool
    let accuracy : Float
    
    
    private enum CodingKeys: String, CodingKey {
        case imei = "IMEI"
        case timeStamp = "Time_stamp"
        case lat = "Lat"
        case lng = "Lng"
        case panic = "Panic"
        case battery = "Battery"
        case speed = "Speed"
        case charging = "Charging"
        case accuracy = "Accuracy"
        
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(imei, forKey: .imei)
        try container.encode(timeStamp, forKey: .timeStamp)
        try container.encode(lat, forKey: .lat)
        try container.encode(lng, forKey: .lng)
        try container.encode(panic, forKey: .panic)
        try container.encode(battery, forKey: .battery)
        try container.encode(speed, forKey: .speed)
        try container.encode(charging, forKey: .charging)
        try container.encode(accuracy, forKey: .accuracy)
        
    }
}
