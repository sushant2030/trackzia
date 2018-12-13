//
//  AddOtherProfileService.swift
//  Trackzia
//
//  Created by Sushant Alone on 14/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import Foundation
import ApiManager

class AddOtherProfileService : CommunicationEndPoint {
    var urlPath: String {
        return "http://13.233.18.64:1166/api/Profiles/UpdateOther"
    }
    
    var httpMethod: HTTPMethod {
        return .post
    }
    
    var hearders: HTTPHeaders {
        return [:]
    }
    
    var parameters: Parameters? {
        return ["Name":self.name,"Description":self.description]
    }
    
    var operationId: Int {
        return 8
    }
    
    var name:String!
    var description:String!

    
    var listener: CommunicationResultListener
    
    func parseResponse(withOperationId operationId: Int, andStatusCode: Int, data: Data) throws -> CommunicationOperationResult {
        do {
            let decoder = JSONDecoder()
            let otherProfile = try decoder.decode(OtherProfiles.self, from: data)
            return otherProfile
        } catch let jsonParsingError {
            fatalError(jsonParsingError.localizedDescription)
        }
    }
    
    init(withName name:String, description:String, listener:CommunicationResultListener) {
        self.name = name
        self.description = description
        self.listener = listener
    }
}


struct OtherProfiles : Codable,CommunicationOperationResult {
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
