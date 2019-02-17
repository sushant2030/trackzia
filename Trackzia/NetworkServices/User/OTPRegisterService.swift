//
//  OTPRegisterService.swift
//  Trackzia
//
//  Created by Sushant Alone on 17/02/19.
//  Copyright © 2019 Private. All rights reserved.
//

import Foundation
import ApiManager

class OTPRegisterService: CommunicationEndPoint {
    var urlPath: String {
        return "http://13.233.18.64:1166/api/OTP/Register"
    }
    
    var httpMethod: HTTPMethod {
        return .post
    }
    
    var hearders: HTTPHeaders = [:]
    
    var parameters: Parameters? {
        return ["AccName":accName,"Mobile":mobile]
    }
    
    var operationId: Int = 1
    
    var listener: CommunicationResultListener
    
    let accName:String
    let mobile:String
   
    
    
    init (withAccName accName :String, mobile:String,listener: CommunicationResultListener) {
        self.accName = accName
        self.mobile = mobile
        self.listener = listener
    }
    
    func parseResponse(withOperationId operationId: Int, andStatusCode: Int, data: Data) throws -> CommunicationOperationResult {
        do {
            let decoder = JSONDecoder()
            let registerResult = try decoder.decode(OTPRegisterModel.self, from: data)
            return registerResult
        } catch let jsonParsingError {
            fatalError(jsonParsingError.localizedDescription)
        }
    }
    
    
}


struct OTPRegisterModel : Decodable, CommunicationOperationResult{
    
    let message: String
    let success: Bool
    
    private enum CodingKeys: String, CodingKey {
        case message = "Message"
        case success = "Success"
    }
}

