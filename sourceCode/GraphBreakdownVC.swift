//
//  graphBreakdownVC.swift
//  securePortal
//
//  Created by Ben Roberts on 26/07/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import UIKit

class GraphBreakdownVC: UIViewController {
    @IBOutlet weak var typeSeg: UISegmentedControl!
    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var paymentView: UIView!
    @IBOutlet weak var currencyView: UIView!
    @IBOutlet weak var ecomLabel: UILabel!
    @IBOutlet weak var cardstoreLabel: UILabel!
    @IBOutlet weak var cftLabel: UILabel!
    @IBOutlet weak var motoLabel: UILabel!
    @IBOutlet weak var recurLabel: UILabel!
    @IBOutlet weak var transactionTotalLabel: UILabel!
    @IBOutlet weak var euroLabel: UILabel!
    @IBOutlet weak var gbpLabel: UILabel!
    @IBOutlet weak var usdLabel: UILabel!
    @IBOutlet weak var amexLabel: UILabel!
    @IBOutlet weak var mastercardLabel: UILabel!
    @IBOutlet weak var mastercarddebitLabel: UILabel!
    @IBOutlet weak var visaLabel: UILabel!
    @IBOutlet weak var paypalLabel: UILabel!
    
    let predManager = PredicateManager() // collection of predicates
    var transactions:[MenuItem] = []
    var requestType = RequestType.All // Sets the default request type as all
    
    var dateFrom = NSDate() // Contains dateFrom
    var dateTo = NSDate() // Contains dateTo
    let numberDecimalFormatter = NSNumberFormatter() // Used for setting string number formats
    
    var dotWasPress = RequestType.All
    var currencyType = "" // contains currency type
    var settledStatus = "" // contains settled status
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = HouseStyleManager.color.DarkGreyAdd10.getColor()
        numberDecimalFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        customiseView()
        requestTypesBreakdown()
        
    }
    
    /// Changes the appearance of the segemented control.
    func customiseView() {
        
        // Sets the navigation title
        if requestType == .All{
            self.title = "ALL"
        } else {
            self.title = requestType.rawValue
        }
        
        // Makes the segemented control square
        typeSeg.layer.borderColor = HouseStyleManager.color.Cerise.getColor().CGColor
        typeSeg.layer.cornerRadius = 0.0;
        typeSeg.layer.borderWidth = 1.5;
    }
    
    /**
        Makes fetch request for a specific requestType selected
        from the main view controller.
        Fetch request is then broken down into account, currency and payment.
    */
    func requestTypesBreakdown() {
        // fetch request
        transactions = predManager.executePredicateRequest(
            predManager.graphBreakdownSearch(requestType.rawValue,settledStatus: settledStatus, currencyType:  currencyType, fromDate: dateFrom, toDate: dateTo))

        // sets transaction count total into total label
        transactionTotalLabel.text = numberDecimalFormatter.stringFromNumber(transactions.count)!
        
        // gets count of each type attribute
        accountBreakdown()
        currencyBreakdown()
        paymentBreakdown()
    }
    
    /// Gets count of all account types
    func accountBreakdown() {
        var ecom = 0, cft = 0, cardstore = 0, moto = 0, recur = 0
        
        for transaction in transactions {

            if let transactionAccountType = AccountType(rawValue: String(transaction.accountType!)) {
                
                switch transactionAccountType {
                case .ECOM:
                    ecom += 1
                case .CFT:
                    cft += 1
                case .CARDSTORE:
                    cardstore += 1
                case .MOTO:
                    moto += 1
                case .RECUR:
                    recur += 1
                }
                
            } else {
                print("accountBreakdown(): Unknown account type.")
            }
        }
        updateAccountLabels(numberDecimalFormatter.stringFromNumber(ecom)!, cft: numberDecimalFormatter.stringFromNumber(cft)!,
                            cardstore: numberDecimalFormatter.stringFromNumber(cardstore)!, moto: numberDecimalFormatter.stringFromNumber(moto)!,
                            recur: numberDecimalFormatter.stringFromNumber(recur)!)
    }
    
    /// Gets count of all currency types
    func currencyBreakdown() {
        var euro = 0, gbp = 0, usd = 0
        
        for transaction in transactions {
            if let transactionCurrencyType = CurrencyType(rawValue: String(transaction.currency!)) {
                switch transactionCurrencyType {
                case .EURO:
                    euro += 1
                case .GBP:
                    gbp += 1
                case .USD:
                    usd += 1
                }
            } else {
                print("CurrencyBreakdown(): Unknown currency type.")
            }
        }
        updateCurrencyLabels(numberDecimalFormatter.stringFromNumber(euro)!, gbp: numberDecimalFormatter.stringFromNumber(gbp)!,
                             usd: numberDecimalFormatter.stringFromNumber(usd)!)
    }
    
    /// Gets count of all payment types
    func paymentBreakdown() {
        var amex = 0, mastercard = 0, mastercarddebit = 0, visa = 0, paypal = 0
        for transaction in transactions {
            if let transactionPaymentType = PaymentType(rawValue: String(transaction.paymentType!)) {
                switch transactionPaymentType {
                case .AMEX:
                    amex += 1
                case .MASTERCARD:
                    mastercard += 1
                case .MASTERCARDDEBIT:
                    mastercarddebit += 1
                case .VISA:
                    visa += 1
                case .PAYPAL:
                    paypal += 1
                }
            } else {
                print("paymentBreakdown(): Unknown payment type.")
            }
        }
            
        updatePaymentLabels(numberDecimalFormatter.stringFromNumber(amex)!, mastercard: numberDecimalFormatter.stringFromNumber(mastercard)!,
                            mastercarddebit: numberDecimalFormatter.stringFromNumber(mastercarddebit)!, visa: numberDecimalFormatter.stringFromNumber(visa)!,
                            paypal: numberDecimalFormatter.stringFromNumber(paypal)!)
    }
    
    /**
        Updates account type labels
        - parameters:
            - ecom: String containing a count of account type ecom.
            - cft: String containing a count of account type cft.
            - cardstore: String containing a count of account type cardstore.
            - moto: String containing a count of account type moto.
            - recur: String containing a count of account type recur.
    */
    func updateAccountLabels(ecom: String, cft:String, cardstore:String, moto:String, recur: String) {
        ecomLabel.text = ecom
        cftLabel.text = cft
        cardstoreLabel.text = cardstore
        motoLabel.text = moto
        recurLabel.text = recur
    }
    
    /**
        Updates currency type labels
        - parameters:
            - euro: String containing a count of account type euro.
            - gbp: String containing a count of account type gbp.
            - usd: String containing a count of account type usd.
     */
    func updateCurrencyLabels(euro: String, gbp:String, usd:String) {
        euroLabel.text = euro
        gbpLabel.text = gbp
        usdLabel.text = usd
    }
    
    /**
        Updates payment type labels
        - parameters:
            - amex: String containing a count of account type amex.
            - mastercard: String containing a count of account type mastercard.
            - mastercarddebit: String containing a count of account type mastercarddebit.
            - visa: String containing a count of account type visa.
            - paypal: String containing a count of account type paypal.
    */
    func updatePaymentLabels(amex: String, mastercard:String, mastercarddebit:String, visa:String, paypal: String) {
        amexLabel.text = amex
        mastercardLabel.text = mastercard
        mastercarddebitLabel.text = mastercarddebit
        visaLabel.text = visa
        paypalLabel.text = paypal
    }
    
    /**
        Hides views based on the segment selected.
        - parameters:
            - sender: segmented control for request types
    */
    @IBAction func changeType(sender: AnyObject) {
        //account view visible
        if typeSeg.selectedSegmentIndex == 0{
            paymentView.hidden = true
            currencyView.hidden = true
            accountView.hidden = false
        //currency view visible
        } else if typeSeg.selectedSegmentIndex == 1{
            paymentView.hidden = true
            currencyView.hidden = false
            accountView.hidden = true
        // payment view visible
        } else {
            paymentView.hidden = false
            currencyView.hidden = true
            accountView.hidden = true
        }
    }
    
    /**
        Dismisses View controller.
         - parameters:
             - sender: dismiss button on the navigation bar
    */
    @IBAction func dismissView(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
