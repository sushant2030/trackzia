//
//  NSManagedObjectContext+Extensions.swift
//  Trackzia
//
//  Created by Rohan Bhale on 27/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    func insertObject<A: NSManagedObject>() -> A where A: Managed {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else { fatalError("Wromg object type") }
        return obj
    }
    
    func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }
    
    func performChanges(block: @escaping () -> ()) {
        perform {
            block()
            let success = self.saveOrRollback()
            print(success)
        }
    }
}
