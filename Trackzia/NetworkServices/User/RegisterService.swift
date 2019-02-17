//
//  RegisterService.swift
//  Trackzia
//
//  Created by Sushant Alone on 16/02/19.
//  Copyright © 2019 Private. All rights reserved.
//

import Foundation
import ApiManager

class RegisterService: CommunicationEndPoint {
    var urlPath: String {
        return "http://13.233.18.64:1166/api/Account/Register"
    }
    
    var httpMethod: HTTPMethod {
        return .post
    }
    
    var hearders: HTTPHeaders = [:]
    
    var parameters: Parameters? {
        return ["AccName":accName,"Mobile":mobile,"Password":password,"DOB":dob,"EmailId":emailId,"Gender":gender,"Country":country,"StateName":stateName,"City":city]
    }
    
    var operationId: Int = 1
    
    var listener: CommunicationResultListener
    
    let accName:String
    let mobile:String
    let password:String
    let dob:String
    let emailId: String
    let gender:String
    let country:String
    let stateName:String
    let city:String
    
    
    init (withAccName accName :String, mobile:String, password:String, dob:String, emailId:String, gender:String, country:String, stateName:String, city:String ,listener: CommunicationResultListener) {
        self.accName = accName
        self.mobile = mobile
        self.password = password
        self.dob = dob
        self.emailId = emailId
        self.gender = gender
        self.country = country
        self.stateName = stateName
        self.city = city
        self.listener = listener
    }
    
    func parseResponse(withOperationId operationId: Int, andStatusCode: Int, data: Data) throws -> CommunicationOperationResult {
        do {
            let decoder = JSONDecoder()
            let registerResult = try decoder.decode(RegisterModel.self, from: data)
            return registerResult
        } catch let jsonParsingError {
            fatalError(jsonParsingError.localizedDescription)
        }
    }
    
    
}


struct RegisterModel : Decodable, CommunicationOperationResult{

    let message: String
    let success: Bool
    let accId:String
    
    private enum CodingKeys: String, CodingKey {
        case message = "Message"
        case success = "Success"
        case accId = "AccId"
    }
    

    
}
