//
//  LoginService.swift
//  Trackzia
//
//  Created by Rohan Bhale on 11/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import ApiManager

class LoginService: CommunicationEndPoint {
    var urlPath: String {
        return "\(baseURLAbsoluteString)/api/Login/Authenticate"
    }
    
    var httpMethod = HTTPMethod.post
    
    var hearders: HTTPHeaders = [:]
    
    var parameters: Parameters? {
        return ["Mobile":mobileNumber, "Password":password]
    }
    
    var operationId: Int = 0
    
    var listener: CommunicationResultListener
    
    let mobileNumber: String
    let password: String
    
    init(mobileNumber: String, password: String, listener: CommunicationResultListener) {
        self.mobileNumber = mobileNumber
        self.password = password
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

struct LoginServiceResult: CommunicationOperationResult, Codable {
    let message: String
    let success: Bool
    let data:LoginAccountData?
    
    private enum CodingKeys: String, CodingKey {
        case message = "Message"
        case success = "Success"
        case data = "Data"
    }
    
    struct LoginAccountData: Codable {
        let accountID: String
        
        private enum CodingKeys: String, CodingKey {
            case accountID = "AccountID"
        }
    }
}

