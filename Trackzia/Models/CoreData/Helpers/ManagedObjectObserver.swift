//
//  ManagedObjectObserver.swift
//  Trackzia
//
//  Created by Rohan Bhale on 10/01/19.
//  Copyright © 2019 Private. All rights reserved.
//

import CoreData


class ManagedObjectObserver {
    enum ChangeType {
        case delete
        case update
    }
    
    fileprivate var token: NSObjectProtocol!
    
    init?(object: NSManagedObject, changeHandler: @escaping (ChangeType) -> Void) {
        guard let moc = object.managedObjectContext else { return nil }
        token = moc.addObjectsDidChangeNotificationObserver({ [weak self](note) in
            guard let changeType = self?.changeType(of: object, in: note) else { return }
            changeHandler(changeType)
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(token)
    }
    
    func changeType(of object: NSManagedObject, in note: ObjectsDidChangeNotification) -> ChangeType? {
        let deleted = note.deletedObjects.union(note.invalidatedObjects)
        if note.invalidatedAllObjects || deleted.contains(object) {
            return .delete
        }
        
        if note.updatedObjects.contains(object) {
            return .update
        }
        return nil
    }
}


