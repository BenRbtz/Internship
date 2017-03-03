//
//  MenuItem.swift
//  securePortal
//
//  Created by Ben Roberts on 23/06/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import Foundation
import CoreData

class MenuItem: NSManagedObject {
    @NSManaged var transRef:NSString?
    
    @NSManaged var amount:NSString?
    @NSManaged var amountTimestamp:NSDate?
    
    @NSManaged var accountType:NSString?
    @NSManaged var currency:NSString?
    @NSManaged var requestType:NSString?
    @NSManaged var paymentType:NSString?
    
    @NSManaged var settledAmount:NSString?
    @NSManaged var settledTimestamp:NSDate?
    @NSManaged var settledStatus: NSNumber?
    
    @NSManaged var errorCode: NSNumber?
}