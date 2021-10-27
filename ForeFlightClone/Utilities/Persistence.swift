//
//  Persistence.swift
//  ForeFlightClone
//
//  Created by Logan Blevins on 9/20/21.
//

import Foundation
import CoreData

final class Persistence {
    enum Backing {
        case disk
        case memory
    }
    
    init(backing: Backing = .disk) {
        self.backing = backing
    }
    
    // MARK: - Core Data stack

    func initialize(completion: @escaping () -> ()) {
        let container = NSPersistentContainer(name: "ForeFlightClone")
        
        // https://www.donnywals.com/setting-up-a-core-data-store-for-unit-tests/
        if backing == .memory {
            let description = NSPersistentStoreDescription(url: URL(fileURLWithPath: "/dev/null"))
            container.persistentStoreDescriptions = [description]
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            } else {
                self.persistentContainer = container
                completion()
            }
        })
    }
    
    func fetchedResultsController() -> NSFetchedResultsController<Airport> {
        let request = Airport.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: Airport.Keys.created.rawValue, ascending: false)]
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewCtx,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
    
    // We want to make sure sibling contexts sync updates between one another.
    
    // All reading for UI updates occur on the view context.
    private(set) lazy var viewCtx: NSManagedObjectContext = {
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        return persistentContainer.viewContext
    }()
    
    // All writing occurs on the background context.
    private(set) lazy var backgroundCtx: NSManagedObjectContext = {
        let ctx = persistentContainer.newBackgroundContext()
        ctx.automaticallyMergesChangesFromParent = true
        return ctx
    }()
    
    private var persistentContainer: NSPersistentContainer!
    
    private let backing: Backing

    // MARK: - Core Data Saving support

    // We want in-memory changes to trump store.
    // We enforce unique objects by their ident property.
    // If we search an ident from the text box, we fetch weather immediately and try to add it
    // just as if it doesn't exist already - which it might. This helps us prevent duplicate airport
    // objects and ensures that the latest fetched weather is always overwriting store weather.
    // This is a bit simpler than doing a fetch to see if the airport ident already exists.
    // Instead, just make a new airport and save it - letting Core Data do the work for us.
    func save(ctx: NSManagedObjectContext) {
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        if ctx.hasChanges {
            do {
                try ctx.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
