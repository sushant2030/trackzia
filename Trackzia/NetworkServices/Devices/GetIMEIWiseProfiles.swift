//
//  GetIMEIWiseProfiles.swift
//  Trackzia
//
//  Created by Rohan Bhale on 15/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import ApiManager

class GetIMEIWiseProfiles: CommunicationEndPoint {
    var urlPath: String {
        return "\(baseURLAbsoluteString)/api/Profiles/GetProfiles"
    }
    
    var httpMethod = HTTPMethod.post
    
    var hearders: HTTPHeaders = [:]
    
    var parameters: Parameters? {
        return ["IMEI": String(imeiNumber)]
    }
    
    var operationId: Int = 0
    
    var listener: CommunicationResultListener
    
    let imeiNumber: IMEI
    
    
    init(imeiNumber: IMEI, listener: CommunicationResultListener) {
        self.imeiNumber = imeiNumber
        self.listener = listener
    }
    
    func parseResponse(withOperationId operationId: Int, andStatusCode: Int, data: Data) throws -> CommunicationOperationResult {
        if let dataString = String(data: data, encoding: .utf8) {
            print(dataString)
        }
        // EG: Success
//        {"Message":"Profile Data","Success":true,"DataList":[{"ProfileType":"Kid","KidName":"","BirthDate":"","BodyType":"","Color":"","Gender":"","Height":"","School":"","SonDaughter":"","Activated":"No"},{"ProfileType":"Pet","PetName":"Puppy","BirthDate":"13-11-2018","Breed":"dog","Color":"white","Gender":"Male","Height":"1.5","DoctorInfo":"dr","Neutered":"No","Type":"dog","Weight":"25","Activated":"Yes"},{"ProfileType":"SeniorCitizen","SeniorName":"","BirthDate":"","BodyType":"","Color":"","Gender":"","Height":"","DoctorInfo":"","SonDaughter":"","Activated":"No"},{"ProfileType":"Vehicle","VehicleName":"","ChassieNo":"","Color":"","Model":"","PurchaseDate":"","Type":"","Activated":"No"},{"ProfileType":"Other","Description":"hcjdjd","ProfileName":"Other","Activated":"No"}]}
        // EG: Failure by wrong password
        //{"Message":"Password Wrong","Success":false,"Data":null}
        // EG: Failure by nonexisting account
        //{"Message":"Account Not Exists","Success":false,"Data":null}
        do {
            let decoder = JSONDecoder()
            let getIMEIWiseProfilesResult = try decoder.decode(GetIMEIWiseProfilesResult.self, from: data)
            let result = GetIMEIWiseProfilesResultWrapper(imeiNumber: imeiNumber, result: getIMEIWiseProfilesResult)
            return result
        } catch let jsonParsingError {
            fatalError(jsonParsingError.localizedDescription)
        }
    }
}

struct GetIMEIWiseProfilesResultWrapper: CommunicationOperationResult {
    let imeiNumber: IMEI
    let result: GetIMEIWiseProfilesResult
}

struct GetIMEIWiseProfilesResult:CommunicationOperationResult, Codable {
    let message: String
    let success: Bool
    let dataList: [[String: String]]
    
    enum CodingKeys: String, CodingKey {
        case message = "Message"
        case success = "Success"
        case dataList = "DataList"
    }
}
