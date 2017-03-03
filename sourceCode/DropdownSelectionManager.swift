//
//  SharedManager.swift
//  securePortal
//
//  Created by Ben Roberts on 13/07/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import Foundation

class DropdownSelectionManager {
    
    var filterCellDescriptors: NSMutableArray!
    var sortCellDescriptors: NSMutableArray!
    
    static let sharedInstance = DropdownSelectionManager()  // Global/singleton varaible
    
    init() {
        print("[DropdownSelectionManager] Initialised")
        
        // Retrieves SortCellDescriptor from SortCellDescriptor.plist
        if let path = NSBundle.mainBundle().pathForResource("SortCellDescriptor", ofType: "plist") {
            sortCellDescriptors = NSMutableArray(contentsOfFile: path)
            
            if sortCellDescriptors.count != 0 {
                print("[DropdownSelectionManager] Loaded SortCellDescriptor")
            } else {
                print("[DropdownSelectionManager] Failed To Load SortCellDescriptor")
            }
        }
        
        // Retrieves FilterCellDescriptor from FilterCellDescriptor.plist
        if let path = NSBundle.mainBundle().pathForResource("FilterCellDescriptor", ofType: "plist") {
            filterCellDescriptors = NSMutableArray(contentsOfFile: path)
            
            if filterCellDescriptors.count != 0 {
                print("[DropdownSelectionManager] Loaded FilterCellDescriptor")
            } else {
                print("[DropdownSelectionManager] Failed To Load FilterCellDescriptor")
            }
        }
    }
}