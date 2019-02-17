//
//  EditAccountDetailsService.swift
//  Trackzia
//
//  Created by Rohan Bhale on 17/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import ApiManager

class UpdateAccountDetailsService: CommunicationEndPoint {
    var urlPath: String {
        return "\(baseURLAbsoluteString)/api/Account/Update"
    }
    
    var httpMethod = HTTPMethod.post
    
    var hearders: HTTPHeaders = [:]
    
    var parameters: Parameters? {
        return ["AccName": userAccntData.accName,
                "City": userAccntData.city,
                "Country": userAccntData.country,
                "DOB": userAccntData.dob,
                "EmailId": userAccntData.emailId,
                "Gender": userAccntData.gender,
                "Mobile": userAccntData.mobile,
                "StateName": userAccntData.stateName]
    }
    
    var operationId: Int = 0
    
    var listener: CommunicationResultListener
    
    let userAccntData: UserAccountData
    
    init(userAccntData: UserAccountData, listener: CommunicationResultListener) {
        self.userAccntData = userAccntData
        self.listener = listener
    }
    
    func parseResponse(withOperationId operationId: Int, andStatusCode: Int, data: Data) throws -> CommunicationOperationResult {
        if let dataString = String(data: data, encoding: .utf8) {
            print(dataString)
        }
        // EG: Success
//        {
//            "Message": "Account Updated Successfully",
//            "Success": true,
//            "Data": null
//        }
        // EG: Failure by wrong password
        //{"Message":"Password Wrong","Success":false,"Data":null}
        // EG: Failure by nonexisting account
        //{"Message":"Account Not Exists","Success":false,"Data":null}
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(UpdateAccountDetailsServiceResult.self, from: data)
            let resultWrapper = UpdateAccountDetailsServiceResultWrapper(accntData: userAccntData, result: result)
            return resultWrapper
        } catch let jsonParsingError {
            fatalError(jsonParsingError.localizedDescription)
        }
    }
}

struct UpdateAccountDetailsServiceResultWrapper: CommunicationOperationResult {
    let accntData: UserAccountData
    let result: UpdateAccountDetailsServiceResult
}

struct UpdateAccountDetailsServiceResult: CommunicationOperationResult, Codable {
    let message: String
    let success: Bool
    let data: String?
    
    enum CodingKeys: String, CodingKey {
        case message =  "Message"
        case success = "Success"
        case data = "Data"
    }
    
}


