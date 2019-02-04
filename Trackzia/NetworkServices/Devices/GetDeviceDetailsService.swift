//
//  GetDeviceDetailsService.swift
//  Trackzia
//
//  Created by Rohan Bhale on 02/01/19.
//  Copyright © 2019 Private. All rights reserved.
//

import ApiManager

class GetDeviceDetailsService: CommunicationEndPoint {
    var urlPath: String {
        return "\(baseURLAbsoluteString)/api/Device/GetDetails"
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
//        {
//            "Message": "Device GetDetails Successfully",
//            "Success": true,
//            "Data": {
//                "IMEI": "896574231025467",
//                "ExpiryDate": "2019-12-08T09:54:54",
//                "SimOperator": "00",
//                "SimNumber": "0",
//                "ActivationDate": "2018-12-08T09:54:54"
//            }
//        }
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(GetDeviceDetailsServiceResult.self, from: data)
            let wrapper = GetDeviceDetailsServiceResultWrapper(imei: imeiNumber, result: result)
            return wrapper
        } catch let jsonParsingError {
            fatalError(jsonParsingError.localizedDescription)
        }
    }
}

struct GetDeviceDetailsServiceResultWrapper: CommunicationOperationResult {
    let imei: IMEI
    let result: GetDeviceDetailsServiceResult
}

struct GetDeviceDetailsServiceResult: CommunicationOperationResult, Codable {
    let message: String
    let success: Bool
    let data: GetDeviceDetailsServiceResultData
    
    enum CodingKeys: String, CodingKey {
        case message = "Message"
        case success = "Success"
        case data = "Data"
    }
    
    
    struct GetDeviceDetailsServiceResultData: Codable {
        let imei: String
        let expiryDate: String
        let simOperator: String
        let simNumber: String
        let activationDate: String
        
        enum CodingKeys: String, CodingKey {
            case imei = "IMEI"
            case expiryDate = "ExpiryDate"
            case simOperator = "SimOperator"
            case simNumber = "SimNumber"
            case activationDate = "ActivationDate"
        }
    }
}
