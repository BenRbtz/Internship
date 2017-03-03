//
//  Test.swift
//  securePortal
//
//  Created by Ben Roberts on 01/08/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import UIKit
import CoreData

class Operation: Foundation.Operation {
    
    let mainManagedObjectContext: NSManagedObjectContext
    var privateManagedObjectContext: NSManagedObjectContext!
    
    init(managedObjectContext: NSManagedObjectContext) {
        mainManagedObjectContext = managedObjectContext
        
        super.init()
    }
    
    override func main() {
        // Initialize Managed Object Context
        privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        // Configure Managed Object Context
        privateManagedObjectContext.parent = mainManagedObjectContext
        
        privateManagedObjectContext.perform {
            
        }
        // Do Some Work
        // ...
        
        if privateManagedObjectContext.hasChanges {
            do {
                try privateManagedObjectContext.save()
            } catch {
                // Error Handling
                // ...
            }
        }
    }
    
}
