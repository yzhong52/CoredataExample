//
//  CoreDataExampleTests.swift
//  CoreDataExampleTests
//
//  Created by Yuchen Zhong on 2016-03-05.
//  Copyright © 2016 Yuchen Zhong. All rights reserved.
//

import XCTest
@testable import CoreDataExample

import CoreData

class CoreDataExampleTests: XCTestCase {
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.yuchen.CoreDataExample" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    func testMigration() {
        // 
        // Generate test data
        //
        let oldModelUrl = NSBundle.mainBundle().URLForResource("CoreDataExample.momd/CoreDataExample",
            withExtension: "mom")!
        let oldManagedObjectModel = NSManagedObjectModel.init(contentsOfURL: oldModelUrl)
        XCTAssertNotNil(oldManagedObjectModel)

        let coordinator = NSPersistentStoreCoordinator.init(managedObjectModel: oldManagedObjectModel!)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        try! coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator

        let person = NSEntityDescription.insertNewObjectForEntityForName("Person",
            inManagedObjectContext: managedObjectContext)
        person.setValue("John", forKey: "firstname")
        person.setValue("Smith", forKey: "lastname")
        person.setValue(0, forKey: "type")
        
        let person2 = NSEntityDescription.insertNewObjectForEntityForName("Person",
            inManagedObjectContext: managedObjectContext)
        person2.setValue("Lily", forKey: "firstname")
        person2.setValue("Brown", forKey: "lastname")
        person2.setValue(1, forKey: "type")
        try! managedObjectContext.save()
        
        //
        // Migration
        //
        let newModelUrl = NSBundle.mainBundle().URLForResource("CoreDataExample.momd/CoreDataExample 1.1",
            withExtension: "mom")!
        let newManagedObjectModel = NSManagedObjectModel.init(contentsOfURL: newModelUrl)
        XCTAssertNotNil(newManagedObjectModel)
        
        let mappingModel = NSMappingModel.init(fromBundles: nil, forSourceModel: oldManagedObjectModel,
            destinationModel: newManagedObjectModel)
        XCTAssertNotNil(mappingModel)

        let migrationManager = NSMigrationManager.init(sourceModel: oldManagedObjectModel!,
            destinationModel: newManagedObjectModel!)
        
        let newUrl = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData1.1.sqlite")

        try! migrationManager.migrateStoreFromURL(url,
            type: NSSQLiteStoreType,
            options: nil,
            withMappingModel: mappingModel,
            toDestinationURL: newUrl,
            destinationType: NSSQLiteStoreType,
            destinationOptions: nil)
        
        //
        // Validation
        //
        let newOoordinator = NSPersistentStoreCoordinator.init(managedObjectModel: newManagedObjectModel!)
        try! newOoordinator.addPersistentStoreWithType(NSSQLiteStoreType,
            configuration: nil, URL: newUrl, options: nil)

        let newManagedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        newManagedObjectContext.persistentStoreCoordinator = newOoordinator
        
        let studentRequest = NSFetchRequest.init(entityName: "Student")
        XCTAssertEqual(try! newManagedObjectContext.executeFetchRequest(studentRequest).count, 1)
        let personRequest = NSFetchRequest.init(entityName: "Person")
        XCTAssertEqual(try! newManagedObjectContext.executeFetchRequest(personRequest).count, 2)
        let teacherRequest = NSFetchRequest.init(entityName: "Teacher")
        XCTAssertEqual(try! newManagedObjectContext.executeFetchRequest(teacherRequest).count, 1)

    }
}
