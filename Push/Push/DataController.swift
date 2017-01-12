//
//  DataController.swift
//  Push
//
//  Created by Jordan Zucker on 1/9/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import CoreData
import PubNub

fileprivate let UserIDKey = "UserIDKey"

class DataController: NSObject {
    
    static let sharedController = DataController()
    
    var currentUserObjectID: NSManagedObjectID! {
        didSet {
            Network.sharedNetwork.setUp()
        }
    }
    
    func currentUser(in context: NSManagedObjectContext) -> User {
        var finalUser: User? = nil
        context.performAndWait {
            guard let object = context.object(with: self.currentUserObjectID) as? User else {
                fatalError("What went wrong with context: \(context) and objectID: \(self.currentUserObjectID)")
            }
            finalUser = object
        }
        return finalUser!
    }
    
//    func user(in context: NSManagedObjectContext) -> User {
//        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
//        var finalResult: User? = nil
//        context.performAndWait {
//            do {
//                let results = try fetchRequest.execute()
//                finalResult = results.first! // should only ever be one user, crash otherwise
//            } catch {
//                fatalError(error.localizedDescription)
//            }
//        }
//        return finalResult!
//    }
//    
//    func currentUser(in context: NSManagedObjectContext) -> User {
//        <#function body#>
//    }
    
//    func user(in context: NSManagedObjectContext) -> User? {
//        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
//        var finalResult: User? = nil
//        context.performAndWait {
//            do {
//                let results = try fetchRequest.execute()
//                finalResult = results.first // should only ever be one user, crash otherwise
//            } catch {
//                fatalError(error.localizedDescription)
//            }
//        }
//        return finalResult
//    }
    
//    var currentUser: User!
    
//    func currentUser(in context: NSManagedObjectContext) -> User {
//        var finalResult: User? = nil
//        context.performAndWait {
//            guard let result = context.object(with: currentUser.objectID) else {
//                return
//            }
//        }
//    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Push")
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
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
