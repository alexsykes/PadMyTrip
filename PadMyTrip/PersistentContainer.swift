//
//  PersistentContainer.swift
//  PadMyTrip
//
//  Created by Alex on 04/05/2020.
//  Copyright © 2020 Alex Sykes. All rights reserved.
//

import CoreData

class PersistentContainer: NSPersistentContainer {

    func saveContext(backgroundContext: NSManagedObjectContext? = nil) {
        let context = backgroundContext ?? viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch let error as NSError {
            print("Error: \(error), \(error.userInfo)")
        }
    }
}
