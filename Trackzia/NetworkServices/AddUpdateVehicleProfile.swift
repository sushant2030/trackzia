//
//  AddUpdateVehicleProfile.swift
//  Trackzia
//
//  Created by Sushant Alone on 14/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import Foundation
import ApiManager


class AddUpdateVehicle : CommunicationEndPoint {
    var urlPath: String {
        return "\(baseURLAbsoluteString)/api/Profiles/UpdateVehicle"
    }
    
    var httpMethod: HTTPMethod {
        return .post
    }
    
    var hearders: HTTPHeaders {
        return [:]
    }
    
    var parameters: Parameters? {
        return ["Name":self.name,"Type":self.type,"ChassieNo":self.chassieNo,"PurchaseDate":self.purchaseDate,"Color":self.color,"Model":self.model]
    }
    
    var operationId: Int {
        return 7
    }
    
    var name:String!
    var chassieNo:String!
    var purchaseDate:String!
    var type:String!
    var color:String!
    var model:String!
    
    
    var listener: CommunicationResultListener
    
    func parseResponse(withOperationId operationId: Int, andStatusCode: Int, data: Data) throws -> CommunicationOperationResult {
        do {
            let decoder = JSONDecoder()
            let vehicleProfile = try decoder.decode(VehicleProfile.self, from: data)
            return vehicleProfile
        } catch let jsonParsingError {
            fatalError(jsonParsingError.localizedDescription)
        }
    }
    
    init(withName name:String, type:String, chassieNo:String, purchaseDate:String, color:String, model:String, listener:CommunicationResultListener) {
        self.name = name
        self.chassieNo = chassieNo
        self.purchaseDate = purchaseDate
        self.color = color
        self.type = type
        self.model = model
        self.listener = listener
    }
}


struct VehicleProfile : Codable,CommunicationOperationResult {
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
