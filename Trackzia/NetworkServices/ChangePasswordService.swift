//
//  ChangePasswordService.swift
//  Trackzia
//
//  Created by Sushant Alone on 13/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import Foundation
import ApiManager

class ChangePasswordService : CommunicationEndPoint {
    var urlPath: String{
        return "\(baseURLAbsoluteString)/api/Account/ResetPassword"
    }
    
    var httpMethod: HTTPMethod {
        return .post
    }
    
    var hearders: HTTPHeaders {
        return [:]
    }
    
    var parameters: Parameters? {
        return ["Mobile":self.mobile,"Password":self.newPassword,"OldPassword":self.oldPassword]
    }
    
    var operationId: Int {
        return 5
    }
    
    var listener: CommunicationResultListener
    var mobile:String
    var oldPassword:String
    var newPassword:String
    
    func parseResponse(withOperationId operationId: Int, andStatusCode: Int, data: Data) throws -> CommunicationOperationResult {
        do {
            let decoder = JSONDecoder()
            let confirmPassword = try decoder.decode(ConfirmPassword.self, from: data)
            return confirmPassword
        } catch let jsonParsingError {
            fatalError(jsonParsingError.localizedDescription)
        }
    }
    
    init(withMobileNumber mobile:String, withOldPassword oldPassword:String, andNewPassword newPassword:String, andListner listener:CommunicationResultListener) {
        self.mobile = mobile
        self.oldPassword = oldPassword
        self.newPassword = newPassword
        self.listener = listener
    }    
}

struct ConfirmPassword: CommunicationOperationResult, Codable {
    var message: String
    var success: Bool
    
    private enum CodingKeys: String, CodingKey {
        case message = "Message"
        case success = "Success"
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(message, forKey: .message)
        try container.encode(success, forKey: .success)
    }
    
}
