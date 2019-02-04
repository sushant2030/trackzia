//
//  API.swift
//  Trackzia
//
//  Created by Rohan Bhale on 03/02/19.
//  Copyright © 2019 Private. All rights reserved.
//

import Foundation
import ApiManager

enum API {
    static let scheme = "http"
    static let host = "13.233.18.64"
    static let port = 1166
}

extension CommunicationEndPoint {
    var baseURLAbsoluteString: String {
        var components = URLComponents()
        components.scheme = API.scheme
        components.host = API.host
        components.port = API.port
        return components.url!.absoluteString
    }
}
