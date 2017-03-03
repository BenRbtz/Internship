//
//  OpenGraphView.swift
//  securePortal
//
//  Created by Ben Roberts on 16/08/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import Foundation
import UIKit

class OpenGraphView: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    
    var viewTitle = "" // For setting view title
    var settledStatus = "" // contains settled status
    var currencyType = "" // contains currency type
    
    // Contains a type of transactions
    var totalTransactions = [Double]()
    var refundTransactions = [Double]()
    var authTransactions = [Double]()
    var declineTransactions = [Double]()
    
    var timeFrameMonths = GraphDates() // For x axis dates and data points
    
    override func viewDidLoad() {
        self.title = viewTitle
    }
    
    /**
         Prepares:
         - Container with barGraph within it
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "containerViewSegue" {
            let containerViewController = segue.destination as? BarGraphVC

            // Passing Values to next view
            containerViewController!.settledStatus = settledStatus
            containerViewController!.timeFrameMonths = timeFrameMonths
            containerViewController!.totalTransactions = totalTransactions
            containerViewController!.refundTransactions = refundTransactions
            containerViewController!.authTransactions = authTransactions
            containerViewController!.declineTransactions = declineTransactions
            containerViewController!.currencyType = currencyType
        }
    }
}
