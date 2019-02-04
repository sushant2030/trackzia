//
//  SetAlertSettingValueService.swift
//  Trackzia
//
//  Created by Rohan Bhale on 16/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import ApiManager

class SetAlertSettingValueService: CommunicationEndPoint {
    var urlPath: String {
        return "\(baseURLAbsoluteString)/api/AlertSetting/Onoff?IMEI=1234&AlertName=Panic&Onoff=false"
    }
    
    var httpMethod = HTTPMethod.post
    
    var hearders: HTTPHeaders = [:]
    
    var parameters: Parameters? {
        return ["IMEI": String(imeiNumber),
                "AlertName":alertName,
                "Onoff": onOffValue]
    }
    
    var operationId: Int = 0
    
    var listener: CommunicationResultListener
    
    let imeiNumber: IMEI
    let alertName: String
    let onOffValue: String
    
    
    init(imeiNumber: IMEI, alertName: String, onOffValue: String, listener: CommunicationResultListener) {
        self.imeiNumber = imeiNumber
        self.alertName = alertName
        self.onOffValue = onOffValue
        self.listener = listener
    }
    
    func parseResponse(withOperationId operationId: Int, andStatusCode: Int, data: Data) throws -> CommunicationOperationResult {
        if let dataString = String(data: data, encoding: .utf8) {
            print(dataString)
        }
        // EG: Success
//        {
//            "Message": "Panic Alert Updated Successfully",
//            "Success": true,
//            "Data": null
//        }
        // EG: Failure by wrong password
        //{"Message":"Password Wrong","Success":false,"Data":null}
        // EG: Failure by nonexisting account
        //{"Message":"Account Not Exists","Success":false,"Data":null}
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(SetAlertSettingValueServiceResult.self, from: data)
            let resultWrapper = SetAlertSettingValueServiceResultWrapper(imeiNumber: imeiNumber, alertName: alertName, onOffValue: onOffValue, result: result)
            return resultWrapper
        } catch let jsonParsingError {
            fatalError(jsonParsingError.localizedDescription)
        }
    }
}

struct SetAlertSettingValueServiceResultWrapper: CommunicationOperationResult {
    let imeiNumber: IMEI
    let alertName: String
    let onOffValue: String
    let result: SetAlertSettingValueServiceResult
}

struct SetAlertSettingValueServiceResult: CommunicationOperationResult, Codable {
    let message: String
    let success: Bool
    
    enum CodingKeys: String, CodingKey {
        case message = "Message"
        case success = "Success"
    }
}
