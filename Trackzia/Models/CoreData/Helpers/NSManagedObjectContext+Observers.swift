//
//  NSManagedObjectContext+Observers.swift
//  Trackzia
//
//  Created by Rohan Bhale on 10/01/19.
//  Copyright © 2019 Private. All rights reserved.
//

import CoreData

struct ObjectsDidChangeNotification {
    fileprivate let notification: Notification
    
    var deletedObjects: Set<NSManagedObject> {
        return objects(forKey: NSDeletedObjectsKey)
    }
    
    var invalidatedObjects: Set<NSManagedObject> {
        return objects(forKey: NSInvalidatedObjectsKey)
    }
    
    var updatedObjects: Set<NSManagedObject> {
        return objects(forKey: NSUpdatedObjectsKey)
    }
    
    var invalidatedAllObjects: Bool {
        return notification.userInfo?[NSInvalidatedAllObjectsKey] != nil
    }
    
    fileprivate func objects(forKey key: String) -> Set<NSManagedObject> {
        return notification.userInfo?[key] as? Set<NSManagedObject> ?? Set()
    }
}

extension NSManagedObjectContext {
    func addObjectsDidChangeNotificationObserver(_ handler: @escaping (ObjectsDidChangeNotification) -> ()) -> NSObjectProtocol {
        let nc = NotificationCenter.default
        return nc.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: self, queue: nil, using: { (note) in
            let wrappedNote = ObjectsDidChangeNotification(notification: note)
            handler(wrappedNote)
        })
    }
}
