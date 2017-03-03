//
//  ResultsVC.swift
//  securePortal
//
//  Created by Ben Roberts on 05/07/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import Foundation
import CoreData

class ResultsVC: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var searchTable: UITableView!
    @IBOutlet weak var totalTransactionsLabel: UILabel!
    
    let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
    var fetchedResultsController = NSFetchedResultsController()
    var fetchRequest = NSFetchRequest()
    
    var viewTitle = "" // view name

    var transactionToSend: MenuItem? // used to pass transaction selected to detailed view
    
    let dateFormatter = DateFormatter()
    let numberDecimalFormatter = NumberFormatter() // decimal style strings formatter
    let numberCurrencyFormatter = NumberFormatter() // currenct style string formatter
    
    // Keeps track of sort ascending and descending
    var sortOrderTransRef = false,  sortOrderTimestamp = false, sortOrderAccount = false, sortOrderRequest = false, sortOrderAmount = false, sortOrderSettledStatus = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewTitle != ""{
            self.title = viewTitle
        }
       
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage(),
            for: .any,
            barMetrics: .default)
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        searchTable.dataSource = self
        searchTable.delegate = self
        
        fetchedResultsController.delegate = self
        // date and time format
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = .short
        
        //Number Format commas
        numberDecimalFormatter.numberStyle = NumberFormatter.Style.currency
        numberDecimalFormatter.minimumFractionDigits = 2
        numberCurrencyFormatter.numberStyle = NumberFormatter.Style.decimal
        
        // Configure Fetched Results Controller
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                            managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        updateResultsController()
        
        totalTransactionsLabel.text = "Transactions: \(numberCurrencyFormatter.string( from: fetchedResultsController.fetchedObjects!.count )!)"
    }
    
    /// Number of rows to a section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currSection = fetchedResultsController.sections?[section] {
            return currSection.numberOfObjects
        }
        return 0
    }

    override func viewWillAppear(_ animated: Bool) {
        //If it isn't an iPad
        if UIDevice.current.userInterfaceIdiom != .pad {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")// set landscape
        }
    }

    /**
        Enables buttons to change the sort of the result set controller
        - parameters:  
            - sender: all column headers
    */
    @IBAction func changeTableSort(_ sender: AnyObject) {
        switch sender.titleLabel!!.text! {
        case "Trans Ref.":
            sortOrderTransRef = !sortOrderTransRef
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "transRef", ascending:sortOrderTransRef)]
        case "Timestamp":
            sortOrderTimestamp = !sortOrderTimestamp
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "amountTimestamp", ascending:sortOrderTimestamp)]
        case "Acc":
            sortOrderAccount = !sortOrderAccount
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "accountType", ascending:sortOrderAccount)]
        case "Req":
            sortOrderRequest = !sortOrderRequest
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "requestType", ascending:sortOrderRequest)]
        case "Amount":
            sortOrderAmount = !sortOrderAmount
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "amount", ascending:sortOrderAmount)]
        case "Status":
            sortOrderSettledStatus = !sortOrderSettledStatus
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "settledStatus", ascending:sortOrderSettledStatus)]
        default:
            print("Error during pressing column names")
        }
        updateResultsController()
        searchTable.reloadData()
    }
    
    /// Updates the fetch result controller
    func updateResultsController() {
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController.performFetch() // performs fetch request to the resultscontroller
        } catch {
            print("An error occurred with result fetch")
        }
    }
    
    /// Opens a view with the respective data of that cell transaction.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        transactionToSend = (fetchedResultsController.object(at: indexPath) as! MenuItem) // stores selected cell transaction into varaible
        resultBreakdownPresent()// presents view
    }
    
    /// Adjusts the popover when the orientation is changed.
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if self.presentedViewController != nil {
            self.presentedViewController!.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY,width: 0.0,height: 0.0) // places the popover in the center of the screen
        }
    }
    
    /// Present a view/popover of the detailedtransaction view.
    func resultBreakdownPresent() {
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "detailedView") as! DetailedTransactionVC
        popoverContent.transaction = transactionToSend! // assigns the transaction in the view with the selected cell transaction data
        
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover = nav.popoverPresentationController
        
        popover!.delegate = self
        popover!.sourceView = self.view // sets within which view
        popover!.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY,width: 0.0,height: 0.0) // places the popover in the center of the screen
        popover!.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0) // removes popover anchor
        
        popoverContent.preferredContentSize = CGSize(width: 400,height: 440) // prefered popover height
        
        self.present(nav, animated: true, completion: nil)
    }
    
    /// Sets the cell labels with the fetch request data for each transaction.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "transCells") as! TransactionCell
        
        let transaction = fetchedResultsController.object(at: indexPath) as! MenuItem

        numberDecimalFormatter.currencyCode = String(transaction.currency!)
        
        cell.transRefLabel.text = String(transaction.transRef!)
        
        cell.amountLabel.text = numberDecimalFormatter.string(from: (transaction.amount?.integerValue)!)
        cell.accTypeLabel.text = String(transaction.accountType!)
        cell.reqTypeLabel.text = String(transaction.requestType!)
        cell.amountTimeStampLabel.text = dateFormatter.string(from: transaction.amountTimestamp!)
        cell.settledStatusLabel.text = String(transaction.settledStatus!)
        return cell
    }

}
