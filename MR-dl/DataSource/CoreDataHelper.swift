//
//  CoreDataHelper.swift
//  MR-dl
//
//  Created by Chen Zerui on 25/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import CoreData

class CoreDataHelper {
    
    static let shared = CoreDataHelper()
    
    let persistentContainer: NSPersistentContainer
    lazy var mainMOC: NSManagedObjectContext = {
       return persistentContainer.viewContext
    }()
    
    init() {
        persistentContainer = NSPersistentContainer(name: "MR_dl")
        persistentContainer.loadPersistentStores { (_, error) in
            assert(error == nil, "Error initializing CoreData stack : \(error!)")
        }
    }
    
    func tryToSave() {
        mainMOC.perform {
            do {
                try self.mainMOC.save()
            }
            catch {
                print("Error saving CoreData main context!")
            }
        }
    }
        
    func deleteObject(_ object: NSManagedObject) {
        mainMOC.performAndWait {
            self.mainMOC.delete(object)
        }
    }
    
    func fetchAllSeries()throws -> [MRSerie] {
        return try mainMOC.fetch(MRSerie.fetchRequest())
    }
    
}

extension NSManagedObjectContext {
    
    static var main: NSManagedObjectContext {
        return CoreDataHelper.shared.mainMOC
    }
    
}
