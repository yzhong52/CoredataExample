//
//  PersonToTeacherStudentPolicy.swift
//  CoreDataExample
//
//  Created by Yuchen Zhong on 2016-03-05.
//  Copyright © 2016 Yuchen Zhong. All rights reserved.
//

import CoreData

class PersonToTeacherStudentPolicy: NSEntityMigrationPolicy {
    
    override func createDestinationInstancesForSourceInstance(sInstance: NSManagedObject,
        entityMapping mapping: NSEntityMapping,
        manager: NSMigrationManager) throws
    {
        if sInstance.entity.name == "Person"
        {
            let firstname = sInstance.primitiveValueForKey("firstname") as! String
            let lastname = sInstance.primitiveValueForKey("lastname") as! String
            let type = sInstance.primitiveValueForKey("type") as! Int
            if type == 0 {
                let person2 = NSEntityDescription.insertNewObjectForEntityForName("Teacher",
                    inManagedObjectContext: manager.destinationContext)
                person2.setValue(firstname, forKey: "firstname")
                person2.setValue(lastname, forKey: "lastname")
            } else {
                let person2 = NSEntityDescription.insertNewObjectForEntityForName("Student",
                    inManagedObjectContext: manager.destinationContext)
                person2.setValue(firstname, forKey: "firstname")
                person2.setValue(lastname, forKey: "lastname")
            }
        }
    }
}
