//
//  GetAccountDetailsService.swift
//  Trackzia
//
//  Created by Rohan Bhale on 12/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import ApiManager

class GetAccountDetailsService: CommunicationEndPoint {
    var urlPath: String {
        return "http://13.233.18.64:1166/api/Account/GetDetails"
    }
    
    var httpMethod = HTTPMethod.post
    
    var hearders: HTTPHeaders = [:]
    
    var parameters: Parameters? {
        return ["Mobile":mobileNumber]
    }
    
    var operationId: Int = 0
    
    var listener: CommunicationResultListener
    
    let mobileNumber: String
   
    
    init(mobileNumber: String, listener: CommunicationResultListener) {
        self.mobileNumber = mobileNumber
        self.listener = listener
    }
    
    func parseResponse(withOperationId operationId: Int, andStatusCode: Int, data: Data) throws -> CommunicationOperationResult {
        if let dataString = String(data: data, encoding: .utf8) {
            print(dataString)
        }
        // EG: Success
        //{"Message":"Login Successfully","Success":true,"Data":{"AccountID":"Acc20181208095428me1HjI"}}
        // EG: Failure by wrong password
        //{"Message":"Password Wrong","Success":false,"Data":null}
        // EG: Failure by nonexisting account
        //{"Message":"Account Not Exists","Success":false,"Data":null}
        do {
            let decoder = JSONDecoder()
            let loginServiceResult = try decoder.decode(LoginServiceResult.self, from: data)
            return loginServiceResult
        } catch let jsonParsingError {
            fatalError(jsonParsingError.localizedDescription)
        }
    }
    
    
}

//class LoginServiceResult: CommunicationOperationResult, Codable {
//    let message: String
//    let success: Bool
//    let data:LoginAccountData?
//
//    private enum CodingKeys: String, CodingKey {
//        case message = "Message"
//        case success = "Success"
//        case data = "Data"
//    }
//
//    class LoginAccountData: Codable {
//        var accountID: String
//
//        private enum CodingKeys: String, CodingKey {
//            case accountID = "AccountID"
//        }
//    }
//}

