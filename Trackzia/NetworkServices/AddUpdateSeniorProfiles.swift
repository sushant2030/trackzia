//
//  AddUpdateSeniorProfiles.swift
//  Trackzia
//
//  Created by Sushant Alone on 14/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import Foundation
import ApiManager

class AddUpdateSeniorProfiles : CommunicationEndPoint {
    var urlPath: String {
        return "\(baseURLAbsoluteString)/api/Profiles/UpdateSeniorCitizen"
    }
    
    var httpMethod: HTTPMethod {
        return .post
    }
    
    var hearders: HTTPHeaders {
        return [:]
    }
    
    var parameters: Parameters? {
        return ["Name":self.name,"Type":self.type,"SonDaughter":self.sonDaughter,"BirthDate":self.birthDate,"Gender":self.gender,"Height":self.height,"Color":self.color,"DoctorInfo":self.doctorInfo]
    }
    
    var operationId: Int {
        return 6
    }
    
    var name:String!
    var sonDaughter:String!
    var birthDate:String!
    var gender:String!
    var type:String!
    var height:String!
    var color:String!
    var doctorInfo:String!
    
    
    var listener: CommunicationResultListener
    
    func parseResponse(withOperationId operationId: Int, andStatusCode: Int, data: Data) throws -> CommunicationOperationResult {
        do {
            let decoder = JSONDecoder()
            let seniorProfile = try decoder.decode(SeniorProfiles.self, from: data)
            return seniorProfile
        } catch let jsonParsingError {
            fatalError(jsonParsingError.localizedDescription)
        }
    }
    
    init(withName name:String, sonDaughter:String, birthDate:String, gender:String, type:String, height:String, color:String, doctorInfo:String, listener:CommunicationResultListener) {
        self.name = name
        self.sonDaughter = sonDaughter
        self.birthDate = birthDate
        self.gender = gender
        self.type = type
        self.height = height
        self.color = color
        self.doctorInfo = doctorInfo
        self.listener = listener
    }
}


struct SeniorProfiles : Codable,CommunicationOperationResult {
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
