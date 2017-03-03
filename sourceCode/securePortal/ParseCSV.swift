//
//  parseCSV.swift
//  securePortal
//
//  Created by Ben Roberts on 23/06/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import Foundation
import CoreData

class ParseCSV{
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    /// Handles the parsing of the CSV file.
    func parseCSV (_ contentsOfURL: URL, encoding: String.Encoding, error: NSErrorPointer) ->
        [(transRef:String, paymentType: String, amountTimestamp: String, currency: String, amount:String, settledAmount:String, settledTimestamp: String,
        settleStatus: String, errorCode: String, accountType: String, requestType: String)]? {
            // Load the CSV file and parse it
            let delimiter = ","
            var items:[(transRef:String, paymentType: String, amountTimestamp: String, currency: String, amount:String, settledAmount:String, settledTimestamp: String,
            settleStatus: String, errorCode: String, accountType: String, requestType: String)]?
            
            if let data = try? Data(contentsOf: contentsOfURL) {
                if let content = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    items = []
                    let lines:[String] = content.components(separatedBy: CharacterSet.newlines) as [String]
                    for line in lines {
                        var values:[String] = []
                        
                        if line != "" {
                            // For a line with double quotes
                            // we use NSScanner to perform the parsing
                            if line.range(of: "\"") != nil {
                                var textToScan:String = line
                                var value:NSString?
                                var textScanner:Scanner = Scanner(string: textToScan)
                                while textScanner.string != "" {
                                    
                                    if (textScanner.string as NSString).substring(to: 1) == "\"" {
                                        textScanner.scanLocation += 1
                                        textScanner.scanUpTo("\"", into: &value)
                                        textScanner.scanLocation += 1
                                    } else {
                                        textScanner.scanUpTo(delimiter, into: &value)
                                    }
                                    
                                    // Store the value into the values array
                                    values.append(value as! String)
                                    
                                    // Retrieve the unscanned remainder of the string
                                    if textScanner.scanLocation < textScanner.string.characters.count{
                                        textToScan = (textScanner.string as NSString).substring(from: textScanner.scanLocation + 1)
                                    } else {
                                        textToScan = ""
                                    }
                                    textScanner = Scanner(string: textToScan)
                                }
                                
                                // For a line without double quotes, we can simply separate the string
                                // by using the delimiter (e.g. comma)
                            } else  {
                                values = line.components(separatedBy: delimiter)
                            }
                            // Put the values into the tuple and add it to the items array
                            let item = (transRef: values[0], paymentType: values[1], amountTimestamp: values[2], currency: values[3], amount: values[4], settledAmount: values[5],
                                        settledTimestamp: values[6], settleStatus: values[7], errorCode: values[8], accountType: values[9], requestType: values[10]) //change these to respective columns
                            items?.append(item)
                        }
                    }
                }
            }
            items?.remove(at: 0) // removes header
            return items
    }
    
    
    /// Provides the url of the csv and assiging the parsed data into the core data.
    func preloadData () {
        // Retrieve data from the source file
        if let contentsOfURL = Bundle.main.url(forResource: "searchresults-2", withExtension: "csv") {
            
            // Remove all the menu items before preloading
            removeData()
            
            var error:NSError?
            if let items = parseCSV(contentsOfURL, encoding: String.Encoding.utf8, error: &error) {
                // Preload the menu items
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                for item in items {
                    let transaction =  NSEntityDescription.insertNewObject(forEntityName: "MenuItem", into:self.managedObjectContext) as! MenuItem

                    transaction.amountTimestamp = dateFormatter.date(from: item.amountTimestamp)
                    transaction.settledTimestamp = dateFormatter.date(from: item.amountTimestamp)
                    transaction.settledStatus = Int(item.settleStatus) as NSNumber?
                    transaction.errorCode = Int(item.errorCode) as NSNumber?
                    transaction.transRef = item.transRef as NSString?
                    transaction.accountType = item.accountType as NSString?
                    transaction.currency = item.currency as NSString?
                    transaction.paymentType = item.paymentType as NSString?
                    transaction.settledAmount = item.settledAmount as NSString?
                    transaction.amount = item.amount as NSString?
                    transaction.requestType = item.requestType as NSString?
                }
            }
        }
    }
    
    /// Removes previous preloads.
    func removeData () {
        // Remove the existing items
        let fetchRequest = NSFetchRequest(entityName: "MenuItem")
        
        do {
            let listOfItems = try self.managedObjectContext.fetch(fetchRequest) as! [MenuItem]
            for listOfItem in listOfItems {
                self.managedObjectContext.delete(listOfItem)
            }
        }
        catch let error as NSError {
            print("Failed to retrieve record: \(error.localizedDescription)")
        }
    }
}
