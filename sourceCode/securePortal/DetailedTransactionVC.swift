//
//  DetailedTransactionVC.swift
//  securePortal
//
//  Created by Ben Roberts on 19/07/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import Foundation
import CoreData

class DetailedTransactionVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    var transaction: MenuItem?
    
    @IBOutlet var tableView: UITableView!
    let numberCurrencyFormatter = NSNumberFormatter() //  Currency style format
    let dateFormatter = NSDateFormatter()
    
    // Contains Table row order
    var tableData: [String] = ["Transaction Reference","Timestamp","Amount","Account Type",
                               "Request Type","Payment Type","Error Code","Settled Status","Settled Timestamp","Settled Amount"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = String(transaction!.transRef!)
        // formats date and time
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        
        numberCurrencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        numberCurrencyFormatter.currencyCode = String(transaction!.currency!)

        tableView.alwaysBounceVertical = false
    }
    
    /**
         Dismisses View controller.
         - parameters:
             - sender: dismiss button on the navigation bar
     */
    @IBAction func dismissView(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /// Sets table view Row Count
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    /// Sets the labels for each row
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("detailedTransCell", forIndexPath: indexPath) as! DetaileTransactionCell
        cell.labelName.text = tableData[indexPath.row]
        
        switch indexPath.row {
        case 0:
            cell.labelData.text = String(transaction!.transRef!)
        case 1:
            cell.labelData.text = dateFormatter.stringFromDate(transaction!.amountTimestamp!)
        case 2:
            cell.labelData.text = numberCurrencyFormatter.stringFromNumber((transaction!.amount?.integerValue)!)
        case 3:
            cell.labelData.text = String(transaction!.accountType!)
        case 4:
            cell.labelData.text = String(transaction!.requestType!)
        case 5:
            cell.labelData.text = String(transaction!.paymentType!)
        case 6:
            cell.labelData.text = String(transaction!.errorCode!)
        case 7:
            cell.labelData.text = String(transaction!.settledStatus!)
        case 8:
            if transaction?.settledTimestamp != nil  {
                cell.labelData.text = dateFormatter.stringFromDate(transaction!.settledTimestamp!)
            } else {
                cell.labelData.text = ""
            }
        case 9:
            if transaction?.settledAmount != nil  {
                cell.labelData.text = numberCurrencyFormatter.stringFromNumber((transaction!.settledAmount?.integerValue)!)
            } else {
                cell.labelData.text = ""
            }
        default:
            print("Error in Cell")
        }
        return cell
    }
    
    // Converts SettledStatus code into Textual status
    func settledStatusValidate(setteldStatus: SettledStatusTypes) -> String {
        
        switch setteldStatus {
        case .Pending:
            return "Pending"
        case .Manual:
            return "Manual"
        case .Suspended:
            return "Suspended"
        case .Cancelled:
            return "Cancelled"
        case .Settling:
            return "Settling"
        case .Settled:
            return "Settled"
        }
    }
    
    /// Enables a row to display a menu
    func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let _ = tableView.cellForRowAtIndexPath(indexPath) as? DetaileTransactionCell {
            return true
        }
        return false
    }
    
    /// Enables the copy action
    func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return action == #selector(copy(_:))
    }
    
    /// Sets the copy action 
    func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        if action == #selector(copy(_:)) {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! DetaileTransactionCell
            let pasteboard = UIPasteboard.generalPasteboard()
            pasteboard.string = cell.labelData.text
        }
    }
}