//
//  TrackziaStack.swift
//  Trackzia
//
//  Created by Rohan Bhale on 26/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import CoreData

enum TrackziaContainerError: String {
    case loadStoreFailed = "Failed to load Trackzia store"
}

let trackziaDataModelFileName = "Trackzia"

func createTrackziaContainer(completion: @escaping (NSPersistentContainer) -> Void) {
    let container = NSPersistentContainer(name: trackziaDataModelFileName)
    container.loadPersistentStores { (_, error) in
        guard error == nil  else { fatalError(TrackziaContainerError.loadStoreFailed.rawValue) }
        DispatchQueue.main.async { completion(container) }
    }
}
