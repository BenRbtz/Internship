//
//  predicateManager.swift
//  securePortal
//
//  Created by Ben Roberts on 14/07/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import Foundation
import CoreData

class PredicateManager {
    let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
    
    let fetchRequest = NSFetchRequest(entityName: "MenuItem")
    var transaction:[MenuItem] = []
    
    let dateFormatter = DateFormatter()

    enum sortListType: String {
        case  Date = "amountTimestamp", Account = "accountType", Currency = "currency",
        Payment = "paymentType", Request = "requestType",  SettledStatus = "settledStatus"
        static let allValues = [Date, Account, Currency, Payment, Request, SettledStatus]
    }
    
    /**
        Predciate request for search view
        - parameters:
            - transNo : Transaction number for a transaction.
            - isSearchFieldEmpty : Whether the searchField is empty or not.
            - filterCellDescriptor: filter cell desciptor to alter.
            - sortCellDescriptor: sort cell desciptor to alter.
    */
    func searchPredicate(_ textfieldNum: String, filterCellDescriptor: NSMutableArray, sortCellDescriptor: NSMutableArray, searchType: String) -> NSFetchRequest<AnyObject> {
        var predicateCollection: [NSPredicate] = []
        let  predicate1: NSPredicate?
        let  predicate2: NSPredicate?
        
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let fromDate = filterCellDescriptor[filterCellName.fromDate.getCell().cellSection][filterCellName.fromDate.getCell().cellRow]["secondaryTitle"] as! String
        let toDate = filterCellDescriptor[filterCellName.toDate.getCell().cellSection][filterCellName.toDate.getCell().cellRow]["secondaryTitle"] as! String
        
        // If search field isnt empty but date range is present
        if textfieldNum != ""  && fromDate != "" && toDate != "" {
            predicate1 = NSPredicate(format: "\(searchType) CONTAINS[cd] %@", textfieldNum)
            predicate2 = NSPredicate(format: "amountTimestamp >= %@ && amountTimestamp <= %@", dateFormatter.date(from: fromDate)!, dateFormatter.date(from: toDate)!)
            predicateCollection = [predicate1!, predicate2!]
        }
            // if search field is not empty
        else if textfieldNum != "" {
            predicate1 = NSPredicate(format: "\(searchType) CONTAINS[cd] %@", textfieldNum)
            predicateCollection = [predicate1!]
        }
            // if date range to present
        else if fromDate != "" && toDate != "" {
            predicate1 = NSPredicate(format: "amountTimestamp >= %@ && amountTimestamp <= %@", dateFormatter.date(from: fromDate)!, dateFormatter.date(from: toDate)!)
            predicateCollection = [predicate1!]
            
            // Error in the use of the method
        } else {
            print("Error, something went from in the search. Check line 112.")
            predicateCollection = []
        }
        // Adds filters
        predicateCollection =  predicateCollection + addFilters(filterCellDescriptor)
        fetchRequest.predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicateCollection)
        
        // Add Sort
        fetchRequest.sortDescriptors =  addSorts(sortCellDescriptor)
        
        return fetchRequest
    }
    
    /**
        Adds all the filters to the predicate.
        - parameters:
            - cellDescriptor : The cellDescriptor that will be altered.
    */
    func addFilters(_ cellDescriptor: NSMutableArray) -> [NSPredicate] {
        var filterCollection: [NSPredicate] = []
        filterCollection.append(filterPredicateBuild("requestType", attributeType: (cellDescriptor[filterCellName.requestType.getCell().cellSection][0]["value"] as? [String])!))
        filterCollection.append(filterPredicateBuild("paymentType", attributeType: (cellDescriptor[filterCellName.paymentType.getCell().cellSection][0]["value"] as? [String])!))
        filterCollection.append(filterPredicateBuild("currency", attributeType: (cellDescriptor[filterCellName.currencyType.getCell().cellSection][0]["value"] as? [String])!))
        filterCollection.append(filterPredicateBuild("accountType", attributeType: (cellDescriptor[filterCellName.accountType.getCell().cellSection][0]["value"] as? [String])!))
        filterCollection.append(filterPredicateBuild("errorCode", attributeType: (cellDescriptor[filterCellName.errorCode.getCell().cellSection][0]["value"] as? [String])!))
        filterCollection.append(filterPredicateBuild("settledStatus", attributeType: (cellDescriptor[filterCellName.settledStatus.getCell().cellSection][0]["value"] as? [String])!))
        return filterCollection
    }
    
    /**
        Checks if a cell has been selected.
        - parameters:
            - cellDescriptor : The cell descriptor of the dropdowns.
    */
    func addSorts(_ cellDescriptor: NSMutableArray) -> [NSSortDescriptor] {
        var sortCollection: [NSSortDescriptor] = []
        
        // All cells
        for i in 0..<sortListType.allValues.count {
            // If cell is selected
            if cellDescriptor[0][i]["isSelected"] as! Bool == true{
                // sends cell primary label name
                sortCollection.append(addSort(cellDescriptor[0][i]["value"] as! String))
            }
        }
        return sortCollection
    }

    /**
        Adds a sort to the predicate.
        - parameters:
            - selectedSort : The cell that was selected's label name.
    */
    func addSort(_ selectedSort: String ) -> NSSortDescriptor {
        // Check which label was selected and adds the filter to the array
        switch sortListType.init(rawValue: selectedSort)! {
        case .Date:
            return NSSortDescriptor(key: sortListType.Date.rawValue, ascending:false)
        case .Account:
            return NSSortDescriptor(key: sortListType.Account.rawValue, ascending:true)
        case .Currency:
            return NSSortDescriptor(key: sortListType.Currency.rawValue, ascending:true)
        case .Payment:
            return NSSortDescriptor(key: sortListType.Payment.rawValue, ascending:true)
        case .Request:
            return NSSortDescriptor(key: sortListType.Request.rawValue, ascending:true)
        case .SettledStatus:
            return NSSortDescriptor(key: sortListType.SettledStatus.rawValue, ascending:true)
        }
    }
    
    /**
        Builds a predicate for all the selected children of an attribute.
        These selected children are the transactions that should be displayed
        - parameters:
            - attribute : The attribute type e.g. requestType.
            - array : All the selected children of the attribute
    */
    func filterPredicateBuild(_ attribute: String, attributeType: [String]) -> NSPredicate{
        var valueType = ""

        var str: String = "\(attribute) IN {"
        // e.g requestType IN { 'AUTH', 'REFUND' }
        for i in 0 ..< attributeType.count {
            if attribute == "errorCode" || attribute == "settledStatus"{
                // Int
                valueType = "\(attributeType[i])"
            } else {
                // String
                valueType = "'\(attributeType[i])'"
            }
            
            if i == attributeType.count-1 {
                str += "\(valueType) "
            } else {
                str += " \(valueType), "
            }
        }
        str += "}"
        return NSPredicate(format: str, argumentArray: attributeType)
    }
    
    /**
        Predicate request for the graph.
        Searchs based on either just date range or date range and request type.
        - parameters:
            - requestType : The request type that the transaction has to be.
            - fromDate : The from date the transaction has to be within.
            - toDate : The to date the transaction has to be within.
    */
    func graphBreakdownSearch(_ requestType: String, settledStatus: String, currencyType: String, fromDate: Date, toDate: Date) -> NSFetchRequest<AnyObject>{
        var  predicate: NSPredicate?
        if requestType == "DECLINE"{
            predicate = NSPredicate(format: "errorCode == 70000 && (amountTimestamp >= %@ && amountTimestamp <= %@)", fromDate, toDate)
        } else if requestType != ""{
            predicate = NSPredicate(format: "requestType == %@ && (amountTimestamp >= %@ && amountTimestamp <= %@)", requestType, fromDate, toDate)
        } else{
            predicate = NSPredicate(format: "amountTimestamp >= %@ && amountTimestamp <= %@", fromDate, toDate)
        }
        if settledStatus != "" {
            let predicate2 = NSPredicate(format: settledStatus)
            predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate!, predicate2])
        }
        if currencyType != "" {
            let predicate3 = NSPredicate(format: "currency = %@", currencyType)
            predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate!, predicate3])
        }
        fetchRequest.predicate = predicate
        return fetchRequest
    }
    
    /**
        Builds a predicate which queries the core data for a date range and a request Type.
 
        Passes the predicate to executePredicateCounter.
        - parameters:
            - requestType : The request type that the transaction has to be.
            - timeFrom : The from date the transaction has to be within.
            - timeTo : The to date the transaction has to be within.
            - total : Whether the predicate searches within a date range or date range and request type.
    */
    func predicateCountBuild(_ requestType: String,settledStatus: String,currencyType: String, timeFrom: Date,timeTo: Date) -> NSFetchRequest<AnyObject> {
        var predicate = NSPredicate(format: "amountTimestamp >= %@ && amountTimestamp <= %@", timeFrom, timeTo)
        if currencyType != "" {
            let currencyTypePredicate = NSPredicate(format: "currency = %@", currencyType)
            predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, currencyTypePredicate])
        }
        
        if settledStatus != "" {
            let settledStatusPredicate = NSPredicate(format: settledStatus)
            predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, settledStatusPredicate])
        }
        
        //If statement returns two predicates: requestType AND date range check
        if requestType != "" {
            var requestTypePredicate = NSPredicate()
            
            if requestType != "DECLINE" {
                requestTypePredicate = NSPredicate(format: "requestType == %@", requestType)
            } else {
                requestTypePredicate = NSPredicate(format: "errorCode == 70000")
            }
            
           predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, requestTypePredicate])
        }
        
        fetchRequest.predicate = predicate

        return fetchRequest
    }
    
    /**
        - parameters:
            - fetchRequest : The fetch request that needs will be altered.
        - returns : collection of transactions
    */
    func executePredicateRequest(_ fetchRequest: NSFetchRequest<AnyObject>) -> [MenuItem] {
        do {
            transaction = try managedObjectContext!.fetch(fetchRequest) as! [MenuItem] // Retrieves data which fits query
        } catch {
            print("Failed to retrieve record")
            print(error)
        }
        return transaction
    }
    
    /**
        - parameters:
            - fetchRequest : The fetch request that will be altered.
        - returns : Transaction count
    */
    func executePredicateCounter(_ fetchRequest: NSFetchRequest<AnyObject>) -> Int {
        var error: NSError? = nil
        return managedObjectContext!.countForFetchRequest(fetchRequest, error: &error )
    }
}
