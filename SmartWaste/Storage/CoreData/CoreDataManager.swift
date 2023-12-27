//
//  CoreDataManager.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 27.12.2023.
//

import CoreData

struct CoreDataManager {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Bucket")
        if inMemory,
           let storeDescription = container.persistentStoreDescriptions.first {
            storeDescription.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("❌ Unable to configure Core Data Store: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    static var preview: CoreDataManager = {
        let result = CoreDataManager(inMemory: true)
        let viewContext = result.container.viewContext
        
        for number in 0..<10 {
            let newItem = BucketItemEntity(context: viewContext)
            newItem.id = Int16(number)
            newItem.name = "Type #\(number)"
            newItem.count = Int16(number*2)
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("❌ Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return result
    }()
}

