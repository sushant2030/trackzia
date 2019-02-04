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
        return "\(baseURLAbsoluteString)/api/Account/GetDetails"
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
        //{"Message":"Account GetDetails Successfully","Success":true,"Data":{"EmailId":"akanksha.makos@gmail.com","City":"Solapur","Gender":"Female","Country":"India","AccName":"Akanksha Analkar","Mobile":"9422680548","DOB":"26-4-1997","StateName":"Maharashtra"}}
        // EG: Failure by unregistered mobile number
        //{"Message":"Account Not Exists","Success":false,"Data":null}
        do {
            let decoder = JSONDecoder()
            let accountDetailServiceResult = try decoder.decode(GetAccountDetailsServiceResult.self, from: data)
            return accountDetailServiceResult
        } catch let jsonParsingError {
            fatalError(jsonParsingError.localizedDescription)
        }
    }
    
    
}

struct GetAccountDetailsServiceResult: CommunicationOperationResult, Codable {
    let message: String
    let success: Bool
    let data: AccountDetailsData?
    
    private enum CodingKeys: String, CodingKey {
        case message = "Message"
        case success = "Success"
        case data = "Data"
    }
    
    struct AccountDetailsData: Codable {
        let emailId: String?
        let city: String?
        let gender: String?
        let country: String?
        let accName: String?
        let mobile: String
        let dob: String?
        let stateName: String?
        
        private enum CodingKeys: String, CodingKey {
            case emailId = "EmailId"
            case city = "City"
            case gender = "Gender"
            case country = "Country"
            case accName = "AccName"
            case mobile = "Mobile"
            case dob = "DOB"
            case stateName = "StateName"
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

