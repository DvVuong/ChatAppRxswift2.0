//
//  DataManager.swift
//  ChatAppDemo
//
//  Created by mr.root on 12/11/22.
//

import Foundation
import CoreData
open class DataManager: NSObject {
    static var shareInstance = DataManager()
    
    override init() {}
    
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    func getUser() -> [User] {
        var users: [User] = []
        let userFetch: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        do {
            let result = try context.fetch(userFetch)
            for item in result {
//                let user = UserRespone(name: item.name ?? ""
//                                       , email: item.email ?? ""
//                                       , password: item.password ?? ""
//                                       , avatar: item.avatar ?? ""
//                                       , id: item.id ?? "")
//                users.append(user)
            }
            return users
        }
        catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        return []
    }
    func saveUser(_ user: User) {
        let userdata = UserEntity(context: context)
        userdata.email = user.email
        userdata.password = user.password
        saveContext()
    }
    
    
    
    // MARK: - Core Data Saving support
        func saveContext () {
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
    // MARK: - Core Data stack
        private lazy var persistentContainer: NSPersistentContainer = {
            /*
             The persistent container for the application. This implementation
             creates and returns a container, having loaded the store for the
             application to it. This property is optional since there are legitimate
             error conditions that could cause the creation of the store to fail.
            */
            let container = NSPersistentContainer(name: "UserDataBase")
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
            return container
        }()
}
