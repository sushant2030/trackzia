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
        return "http://13.233.18.64:1166/api/Login/Authenticate"
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
        
        return ComOperationResult()
    }
    
    
}

class ComOperationResult: CommunicationOperationResult {
    
}
