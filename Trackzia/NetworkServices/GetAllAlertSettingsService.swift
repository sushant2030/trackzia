//
//  GetAllAlertSettingsService.swift
//  Trackzia
//
//  Created by Rohan Bhale on 16/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import ApiManager

class GetAllAlertSettingsService: CommunicationEndPoint {
    var urlPath: String {
        return "http://13.233.18.64:1166/api/AlertSetting/GetDetails?IMEI=1234"
    }
    
    var httpMethod = HTTPMethod.post
    
    var hearders: HTTPHeaders = [:]
    
    var parameters: Parameters? {
        return ["IMEI":String(imeiNumber)]
    }
    
    var operationId: Int = 0
    
    var listener: CommunicationResultListener
    
    let imeiNumber: IMEI
    
    
    init(imeiNumber: IMEI, listener: CommunicationResultListener) {
        self.imeiNumber = imeiNumber
        self.listener = listener
    }
    
    func parseResponse(withOperationId operationId: Int, andStatusCode: Int, data: Data) throws -> CommunicationOperationResult {
        if let dataString = String(data: data, encoding: .utf8) {
            print(dataString)
        }
        // EG: Success
        // {
//        "Message": "Alert Data",
//        "Success": true,
//        "Data": {
//            "Battery": "True",
//            "GeoInOut": "True",
//            "Panic": "False"
//        }
//    }
        // EG: Failure by wrong password
        //{"Message":"Password Wrong","Success":false,"Data":null}
        // EG: Failure by nonexisting account
        //{"Message":"Account Not Exists","Success":false,"Data":null}
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(GetAllAlertSettingsServiceResult.self, from: data)
            let resultWrapper = GetAllAlertSettingsServiceResultWrapper(imeiNumber: imeiNumber, result: result)
            return resultWrapper
        } catch let jsonParsingError {
            fatalError(jsonParsingError.localizedDescription)
        }
    }
}

struct GetAllAlertSettingsServiceResultWrapper: CommunicationOperationResult {
    let imeiNumber: IMEI
    let result: GetAllAlertSettingsServiceResult
}

struct GetAllAlertSettingsServiceResult:  CommunicationOperationResult, Codable {
    let message: String
    let success: Bool
    let data: AlertSettingsData?
    
    var battery: Bool { return data?.battery == "True" }
    var geoInOut: Bool { return data?.geoInOut == "True" }
    var panic: Bool { return data?.panic == "True" }
    
    enum CodingKeys: String, CodingKey {
        case message = "Message"
        case success = "Success"
        case data = "Data"
    }
    
    struct AlertSettingsData: Codable {
        let battery: String
        let geoInOut: String
        let panic: String
        
        enum CodingKeys: String, CodingKey {
            case battery = "Battery"
            case geoInOut = "GeoInOut"
            case panic = "Panic"
        }
    }
}
