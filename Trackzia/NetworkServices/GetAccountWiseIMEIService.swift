//
//  GetAccountWiseIMEIService.swift
//  Trackzia
//
//  Created by Rohan Bhale on 14/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import ApiManager

class GetAccountWiseIMEIService: CommunicationEndPoint {
    var urlPath: String {
        return "http://13.233.18.64:1166/api/Account/GetIMEIList"
    }
    
    var httpMethod = HTTPMethod.post
    
    var hearders: HTTPHeaders = [:]
    
    var parameters: Parameters? {
        return ["AccountId":accountId]
    }
    
    var operationId: Int = 0
    
    var listener: CommunicationResultListener
    
    let accountId: String
    
    
    init(accountId: String, listener: CommunicationResultListener) {
        self.accountId = accountId
        self.listener = listener
    }
    
    func parseResponse(withOperationId operationId: Int, andStatusCode: Int, data: Data) throws -> CommunicationOperationResult {
        if let dataString = String(data: data, encoding: .utf8) {
            print(dataString)
        }
        // EG: Success
        //{"Message":"IMEI List","Success":true,"Data":{"IMEI1":"896574231025467","IMEI2":"85236417"}}
        // EG: Success no imei with this account
//        {
//            "Message": "IMEI Not Exists with this Account",
//            "Success": false,
//            "Data": null
//        }
        do {
            let decoder = JSONDecoder()
            let getAccountWiseIMEIServiceResult = try decoder.decode(GetAccountWiseIMEIServiceResult.self, from: data)
            return getAccountWiseIMEIServiceResult
        } catch let jsonParsingError {
            fatalError(jsonParsingError.localizedDescription)
        }
    }
    
    
}

struct GetAccountWiseIMEIServiceResult: CommunicationOperationResult, Codable {
    let message: String
    let success: Bool
    let data: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case message = "Message"
        case success = "Success"
        case data = "Data"
    }
}
