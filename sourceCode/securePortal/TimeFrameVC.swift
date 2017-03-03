//
//  TimeFrameVC.swift
//  securePortal
//
//  Created by Ben Roberts on 31/08/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import UIKit
import CoreData

class TimeFrameVC: UIViewController {
    @IBOutlet weak var totalTransactionsLabel: UILabel!
    @IBOutlet weak var totalRefundsLabel: UILabel!
    @IBOutlet weak var totalAuthorisedLabel: UILabel!
    @IBOutlet weak var todayTransactionsLabel: UILabel!
    @IBOutlet weak var todayRefundsLabel: UILabel!
    @IBOutlet weak var todayAuthorisedLabel: UILabel!
    @IBOutlet weak var weekTransactionsLabel: UILabel!
    @IBOutlet weak var weekRefundsLabel: UILabel!
    @IBOutlet weak var weekAuthorisedLabel: UILabel!
    @IBOutlet weak var monthTransactionsLabel: UILabel!
    @IBOutlet weak var monthRefundsLabel: UILabel!
    @IBOutlet weak var monthAuthorisedLabel: UILabel!
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var todayView: UIView!
    @IBOutlet weak var weekView: UIView!
    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var settledStatusSeg: UISegmentedControl!
    
    // Keeping track of the different transaction settled status split into time frames
    var totalTransactionAuths: [NSDecimalNumber] = [0,0,0,0],
        past24HoursTransactionAuths: [NSDecimalNumber] = [0,0,0,0],
        past6DaysTransactionAuths: [NSDecimalNumber] = [0,0,0,0],
        past30DaysTransactionAuths: [NSDecimalNumber] = [0,0,0,0]
    var totalTransactionRefunds: [NSDecimalNumber] = [0,0,0,0],
        past24HoursTransactionRefunds: [NSDecimalNumber] = [0,0,0,0],
        past6DaysTransactionRefunds: [NSDecimalNumber] = [0,0,0,0],
        past30DaysTransactionRefunds: [NSDecimalNumber] = [0,0,0,0]
    var totalTransactionCount = [0,0,0,0],
        past24HoursTransactionCount = [0,0,0,0],
        past6DaysTransactionCount = [0,0,0,0],
        past30DaysTransactionCount = [0,0,0,0]
    
    let calender = NSCalendar.currentCalendar()
    let predManager = PredicateManager()
    
    let numberCurrencyFormatter = NSNumberFormatter() // Contains Currency style format
    let numberDecimalFormatter = NSNumberFormatter() //contains decimal style format
    
    // Contains a type of transactions
    var totalTransactions = [Double]()
    var refundTransactions = [Double]()
    var authTransactions = [Double]()
    var declineTransactions = [Double]()
    
    var timeFrameMonths = GraphDates() // For x axis dates and data points
    
    var currencyType = CurrencyType.GBP // contains currency type for this view
    var timeFrameButtonPressed = timeFrames.Total // keeps track of timeFrame button pressed
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalView.layer.borderWidth = 1
        totalView.layer.borderColor = HouseStyleManager.color.Cerise.getColor().CGColor
        todayView.layer.borderWidth = 1
        todayView.layer.borderColor = HouseStyleManager.color.Cerise.getColor().CGColor
        weekView.layer.borderWidth = 1
        weekView.layer.borderColor = HouseStyleManager.color.Cerise.getColor().CGColor
        monthView.layer.borderWidth = 1
        monthView.layer.borderColor = HouseStyleManager.color.Cerise.getColor().CGColor
        
        numberCurrencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        numberDecimalFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        
        transactionsTimeFrame()
        setTimeFrameLabels(0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
        Changes the labels to the respective settled Status
        - parameters:
            - sender: settledStatusSeg
     */
    @IBAction func changeDisplayedCounts(sender: AnyObject) {
        setTimeFrameLabels(sender.selectedSegmentIndex)
    }
    
    /**
         After one of these headers are pressed an action sheet will appear.
         
         The actions sheet consists of options to open either a table or graph.
         - parameters:
             - sender: (Total, Past 24 Hours, Past 6 Days, Past 30) Days buttons.
     */
    @IBAction func displayAsGraphTable(sender: AnyObject) {
        let buttonTitle = sender.titleLabel!!.text!
        
        // Checks which header was pressed e.g. Total, Past 24 Hours etc. and assigns number
        let buttonAsEnum = timeFrames(rawValue: buttonTitle)!
        timeFrameButtonPressed = buttonAsEnum
        
        let actionAlert = UIAlertController(title: nil, message: "Select Display Type" , preferredStyle: .ActionSheet)
        actionAlert.addAction(addDisplayAsGraphTableAction("Open Graph", segueID: "OpenGraphSegue"))
        actionAlert.addAction(addDisplayAsGraphTableAction("Open Table", segueID: "OpenTableSegue"))
        actionAlert.addAction(UIAlertAction(title:"Cancel", style: .Cancel,handler: nil))
        
        actionAlert.popoverPresentationController?.sourceView = sender as! UIButton
        actionAlert.popoverPresentationController?.sourceRect = sender.bounds
        
        self.presentViewController(actionAlert, animated: true, completion: nil)
        actionAlert.view.tintColor = HouseStyleManager.color.Cerise.getColor()
    }
    
    /**
         - parameters:
             - title: A string for the action display name.
             - segueId: A string containing segue identifier.
         - returns: Alert action to segue to a view
    */
    func addDisplayAsGraphTableAction(title:String, segueID: String) -> UIAlertAction {
        let displayAsGraphTableAction = UIAlertAction(title: title, style: .Default, handler: { (action: UIAlertAction!) in
            self.performSegueWithIdentifier(segueID, sender: nil)
        })
        
        return displayAsGraphTableAction
    }
    
    /**
         - parameters:
             - settledStatus: A string containing the value the settledStatus should be equal to.
             - viewTitle: A string containing the transactions that should be displayed.
         - returns: viewTitle and settledStatus based on the segment selected.
     */
    func settledStatusForNextView(inout settledStatus: String,inout viewTitle: String ) {
        switch settledStatusSeg.selectedSegmentIndex {
        case 0:
            // Settled
            settledStatus = "settledStatus == 100"
            viewTitle = "Settled Transactions"
        case 1:
            //Pending
            settledStatus = "settledStatus IN { 0, 1, 10 }"
            viewTitle = "Pending Transactions"
        case 2:
            // Suspended
            settledStatus = "settledStatus == 2"
            viewTitle = "Suspended Transactions"
        case 3:
            //ErrorCode Decline
            settledStatus = "errorCode == 70000"
            viewTitle = "Declined Transactions"
            
        default:
            print("Error in segmented control")
        }
    }
    
    /**
         Sets each label within the view.
         The set values for each label is from predicates.
         These predicates are used to fetch all, auth and refund transaction counts
         for total, today, week and month timeframes.
     */
    func transactionsTimeFrame() {
        // Prepares the date variables
        var startOfTodayDate = NSDate() // Today
        var todayDate = NSDate()
        
        startOfTodayDate = calender.startOfDayForDate(startOfTodayDate)
        
        // set to tomorrow
        startOfTodayDate = calender.dateByAddingUnit(.Day, value: +1, toDate: startOfTodayDate, options: [])!
        todayDate = calender.dateByAddingUnit(.Day, value: +1, toDate: todayDate, options: [])!
        
        // Date: Seven, Thirty days ago and seven years ago
        let dateSevenDaysAgo = calender.dateByAddingUnit(.Day, value: -6, toDate: startOfTodayDate, options: [])! // Week
        let dateThirtyDaysAgo = calender.dateByAddingUnit(.Day, value: -30, toDate: startOfTodayDate, options: [])! //Month
        var dateSevenYearsAgo = calender.dateByAddingUnit(.Year, value: -6, toDate: startOfTodayDate, options: [])! // Years
        
        // Sets seven years ago to the first of January
        let components = calender.components([.Year, .Month, .Day], fromDate: dateSevenYearsAgo)
        components.day = 1
        components.month = 1
        dateSevenYearsAgo = calender.dateFromComponents(components)!
        
        requestTranscationTimeFrame(startOfTodayDate,
                                    todayDate: todayDate, dateSevenDaysAgo: dateSevenDaysAgo, dateThirtyDaysAgo: dateThirtyDaysAgo, dateSevenYearsAgo: dateSevenYearsAgo)
    }
    
    /**
         Checks a transaction array's transactions request type.
         - parameters:
             - transaction: An array containing all transactions
         - returns: Tuple containing an array of auth, refund and a count.
     */
    func requestTypeCheck(transactions: [MenuItem]) -> (auth: [NSDecimalNumber], refund: [NSDecimalNumber], count: [Int]){
        var auth: [NSDecimalNumber] = [0.0,0.0,0.0,0.0]
        var refund: [NSDecimalNumber] = [0.0,0.0,0.0,0.0]
        var count = [0,0,0,0]
        for transaction in transactions {
                // Gets count of each transaction based on settledStatus'
                let settledStatusCount = settledStatusCheck(Int(transaction.settledStatus!), errorCode: Int(transaction.errorCode!))
                count[0] += settledStatusCount[0]
                count[1] += settledStatusCount[1]
                count[2] += settledStatusCount[2]
                count[3] += settledStatusCount[3]
            
                // Gets currency and returns into each transaction based on settledstatus
                let settledStatusCurrency = settledStatusCheck(Int(transaction.settledStatus!), errorCode: Int(transaction.errorCode!),
                                                               currencyAmount: NSDecimalNumber( string: String(transaction.amount!)))
                switch RequestType(rawValue: String(transaction.requestType!))! {
                case .Auth:
                    auth[0] = settledStatusCurrency[0].decimalNumberByAdding(auth[0]) // Auth Settled
                    auth[1] = settledStatusCurrency[1].decimalNumberByAdding(auth[1]) // Auth Pending
                    auth[2] = settledStatusCurrency[2].decimalNumberByAdding(auth[2]) // Auth Suspended
                    auth[3] = settledStatusCurrency[3].decimalNumberByAdding(auth[3]) // Auth Declined
                case .Refund:
                    refund[0] = settledStatusCurrency[0].decimalNumberByAdding(refund[0])
                    refund[1] = settledStatusCurrency[1].decimalNumberByAdding(refund[1])
                    refund[2] = settledStatusCurrency[2].decimalNumberByAdding(refund[2])
                    refund[3] = settledStatusCurrency[3].decimalNumberByAdding(refund[3])
                case .All, .Decline:
                    break
                }
        }
        return (auth: auth, refund: refund, count: count)
    }
    
    /**
         Checks settledStatus/errorCode.
         - parameters:
             - settledStatus: SettledStatus.
             - errorCode: Error code.
     */
    func settledStatusCheck(settledStatus: Int, errorCode: Int, currencyAmount: NSDecimalNumber) -> [NSDecimalNumber] {
        var array: [NSDecimalNumber] = [0.0,0.0,0.0,0.0]
        switch SettledStatusTypes(rawValue: settledStatus )!  {
        case .Settled:
            array[0] = currencyAmount.decimalNumberByAdding(array[0])
        case .Pending, .Manual, .Settling:
            array[1] = currencyAmount.decimalNumberByAdding(array[1])
        case .Suspended:
            array[2] = currencyAmount.decimalNumberByAdding(array[2])
        case .Cancelled:
            break
        }
        
        if errorCode == 70000 {
            //Declined
            array[3] = currencyAmount.decimalNumberByAdding(array[3])
        }
        return array
    }
    
    /**
         Checks settledStatus/errorCode.
         - parameters:
             - settledStatus: Int containing settledStatus
             - errorCode: Int containing errorCode
     */
    func settledStatusCheck(settledStatus: Int, errorCode: Int) -> [Int] {
        var array = [0,0,0,0]
        switch SettledStatusTypes(rawValue: settledStatus )!  {
        case .Settled:
            array[0] += 1
        case .Pending, .Manual, .Settling:
            array[1] += 1
        case .Suspended:
            array[2] += 1
        case .Cancelled:
            break
        }
        
        if errorCode == 70000 {
            //Declined
            array[3] += 1
        }
        return array
    }
    
    /**
         Preforms the predicate requests to sort the transactions by requestTypes
         - parameters:
             - startOfTodayDate: Todays date with time starting at 00:00.
             - todayDate: Todays date and time.
             - dateSevenDaysAgo: Seven days ago to today.
             - dateThirtyDaysAgo: thiry days ago to today
             - sevenYearsAgo: Seven years ago to today.
     */
    func requestTranscationTimeFrame(startOfTodayDate: NSDate, todayDate: NSDate, dateSevenDaysAgo: NSDate, dateThirtyDaysAgo: NSDate, dateSevenYearsAgo: NSDate) {
        // Total Transactions
        var transcation = predManager.executePredicateRequest(predManager.graphBreakdownSearch("",settledStatus: "",
            currencyType: currencyType.rawValue , fromDate: dateSevenYearsAgo, toDate: todayDate))
        var temp = requestTypeCheck(transcation)
        totalTransactionAuths = temp.auth
        totalTransactionRefunds = temp.refund
        totalTransactionCount = temp.count
        
        // Past 24 Hour Transactions
        transcation = predManager.executePredicateRequest(predManager.graphBreakdownSearch("",settledStatus: "",
            currencyType: currencyType.rawValue, fromDate: startOfTodayDate, toDate: todayDate))
        temp = requestTypeCheck(transcation)
        past24HoursTransactionAuths = temp.auth
        past24HoursTransactionRefunds = temp.refund
        past24HoursTransactionCount = temp.count
        
        // Past 6 Days Transactions
        transcation = predManager.executePredicateRequest(predManager.graphBreakdownSearch("",settledStatus: "",
            currencyType: currencyType.rawValue, fromDate: dateSevenDaysAgo, toDate: todayDate))
        temp = requestTypeCheck(transcation)
        past6DaysTransactionAuths = temp.auth
        past6DaysTransactionRefunds = temp.refund
        past6DaysTransactionCount = temp.count
        
        // Past 30 Day Transactions
        transcation = predManager.executePredicateRequest(predManager.graphBreakdownSearch("",settledStatus: "",
            currencyType: currencyType.rawValue, fromDate: dateThirtyDaysAgo, toDate: todayDate))
        temp = requestTypeCheck(transcation)
        past30DaysTransactionAuths = temp.auth
        past30DaysTransactionRefunds = temp.refund
        past30DaysTransactionCount = temp.count
    }
    /**
        Sets the labels for the time frame counts based on settled Status segment selected
        - parameters: 
            - segmentIndex: index of the segmented control.
    */
    func setTimeFrameLabels( segmentIndex: Int ) {
        var segAuth: [NSDecimalNumber] = [0,0,0,0], segRefund: [NSDecimalNumber] = [0,0,0,0]
        var segCount = [0,0,0,0]
        
        switch segmentIndex {
        case 0:
            // Settled
            setSegVaraible(&segCount, segAuth: &segAuth, segRefund: &segRefund, segmentIndex: segmentIndex)
        case 1:
            // Pending
            setSegVaraible(&segCount, segAuth: &segAuth, segRefund: &segRefund, segmentIndex: segmentIndex)
        case 2:
            //Suspended
            setSegVaraible(&segCount, segAuth: &segAuth, segRefund: &segRefund, segmentIndex: segmentIndex)
        case 3:
            // Declined
            setSegVaraible(&segCount, segAuth: &segAuth, segRefund: &segRefund, segmentIndex: segmentIndex)
        default:
            print("Error in setting label")
        }
        numberCurrencyFormatter.currencyCode = currencyType.rawValue
        
        // Set Labels
        totalTransactionsLabel.text = numberDecimalFormatter.stringFromNumber(segCount[0])
        totalRefundsLabel.text = numberCurrencyFormatter.stringFromNumber(segRefund[0])
        totalAuthorisedLabel.text = numberCurrencyFormatter.stringFromNumber(segAuth[0])
        
        todayTransactionsLabel.text = numberDecimalFormatter.stringFromNumber(segCount[1])
        todayRefundsLabel.text = numberCurrencyFormatter.stringFromNumber(segRefund[1])
        todayAuthorisedLabel.text = numberCurrencyFormatter.stringFromNumber(segAuth[1])
        
        weekTransactionsLabel.text = numberDecimalFormatter.stringFromNumber(segCount[2])
        weekRefundsLabel.text = numberCurrencyFormatter.stringFromNumber(segRefund[2])
        weekAuthorisedLabel.text = numberCurrencyFormatter.stringFromNumber(segAuth[2])
        
        monthTransactionsLabel.text = numberDecimalFormatter.stringFromNumber(segCount[3])
        monthRefundsLabel.text = numberCurrencyFormatter.stringFromNumber(segRefund[3])
        monthAuthorisedLabel.text = numberCurrencyFormatter.stringFromNumber(segAuth[3])
    }
    
    /**
         Sets the segment timeframe variables
         - parameters:
             - segCount: The segment's transaction count.
             - segAuth: The segment's auths.
             - segRefund: The segment's refunds.
             - segmentIndex: index of the segmented control.
     */
    func setSegVaraible(inout segCount: [Int],inout segAuth: [NSDecimalNumber], inout segRefund: [NSDecimalNumber], segmentIndex: Int) {
        // Total
        segCount[0] = totalTransactionCount[segmentIndex]
        segAuth[0] = totalTransactionAuths[segmentIndex]
        segRefund[0] = totalTransactionRefunds[segmentIndex]
        
        // Past 24 Hours
        segCount[1] = past24HoursTransactionCount[segmentIndex]
        segAuth[1] = past24HoursTransactionAuths[segmentIndex]
        segRefund[1] = past24HoursTransactionRefunds[segmentIndex]
        
        // Past 6 Days
        segCount[2] = past6DaysTransactionCount[segmentIndex]
        segAuth[2] = past6DaysTransactionAuths[segmentIndex]
        segRefund[2] = past6DaysTransactionRefunds[segmentIndex]
        
        // Past 30 Days
        segCount[3] = past30DaysTransactionCount[segmentIndex]
        segAuth[3] = past30DaysTransactionAuths[segmentIndex]
        segRefund[3] = past30DaysTransactionRefunds[segmentIndex]
    }
    
    /**
         Fetches the graph data from core data.
         The data is split into three arrays for the three different graphs types.
         Calls `setChart` to set the data within the graph.
         - parameters:
             - graphBarDateRange: data range for the graph.
             - settledStatus: settled status for the graph.
             - currencyType: currency type for the graph.
     */
    func graphData(graphBarDateRange: timeFrames, settledStatus: String, currencyType: CurrencyType) {
        var fromDate = NSDate(), toDate = NSDate()
        var months = [(start: NSDate,end: NSDate)]()
        var fetchRequest = NSFetchRequest()
        
        // sets the time to 00:00
        fromDate = calender.startOfDayForDate(fromDate)
        toDate = calender.startOfDayForDate(toDate)
        
        // set to tomorrow
        fromDate = calender.dateByAddingUnit(.Day, value: +1, toDate: fromDate, options: [])!
        toDate = calender.dateByAddingUnit(.Day, value: +1, toDate: toDate, options: [])!
        for _ in 1...6 {
            //Goes back 30 days from previous date
            switch graphBarDateRange {
            case .Total:
                timeFrameMonths.isYearFormat()
                fromDate = calender.dateByAddingUnit(.Year, value: -1, toDate: fromDate, options: [])!
            case .Past24Hours:
                timeFrameMonths.isHourFormat()
                fromDate = calender.dateByAddingUnit(.Hour, value: -4, toDate: fromDate, options: [])!
            case .Past6Days:
                timeFrameMonths.isDayFormat()
                fromDate = calender.dateByAddingUnit(.Day, value: -1, toDate: fromDate, options: [])!
            case .Past12Days:
                timeFrameMonths.isDayFormat()
                fromDate = calender.dateByAddingUnit(.Day, value: -2, toDate: fromDate, options: [])!
            case .Past30Days:
                timeFrameMonths.isDayFormat()
                fromDate = calender.dateByAddingUnit(.Day, value: -5, toDate: fromDate, options: [])!
            case .Past60Days:
                timeFrameMonths.isDayFormat()
                fromDate = calender.dateByAddingUnit(.Day, value: -10, toDate: fromDate, options: [])!
            }
            
            months.append((fromDate, toDate)) // Marks each month
            
            // Total, refund and auth transtions for each month
            fetchRequest = predManager.predicateCountBuild(RequestType.All.rawValue, settledStatus: settledStatus, currencyType: currencyType.rawValue, timeFrom: fromDate, timeTo: toDate)
            totalTransactions.append(Double(predManager.executePredicateCounter(fetchRequest)))
            
            fetchRequest = predManager.predicateCountBuild(RequestType.Refund.rawValue, settledStatus: settledStatus, currencyType: currencyType.rawValue, timeFrom: fromDate, timeTo: toDate)
            refundTransactions.append(Double(predManager.executePredicateCounter(fetchRequest)))
            
            fetchRequest = predManager.predicateCountBuild(RequestType.Auth.rawValue, settledStatus: settledStatus, currencyType: currencyType.rawValue, timeFrom: fromDate, timeTo: toDate)
            authTransactions.append(Double(predManager.executePredicateCounter(fetchRequest)))
            
            fetchRequest = predManager.predicateCountBuild(RequestType.Decline.rawValue, settledStatus: settledStatus, currencyType: currencyType.rawValue, timeFrom: fromDate, timeTo: toDate)
            declineTransactions.append(Double(predManager.executePredicateCounter(fetchRequest)))
            
            toDate = fromDate //sets previous date as current
        }
        
        // Displaying the data from oldest to youngest (achieved through reverse)
        timeFrameMonths.dateNS = months.reverse()
        totalTransactions = totalTransactions.reverse()
        refundTransactions = refundTransactions.reverse()
        authTransactions = authTransactions.reverse()
        declineTransactions = declineTransactions.reverse()
    }

    /**
         This methods prepares:
         - Opening Table View
         - Opening Graph View
         - PageViewContainer
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "OpenGraphSegue" {
            let DestViewController = segue.destinationViewController as! OpenGraphView
            var settledStatus = ""
            var viewTitle = ""
            
            settledStatusForNextView(&settledStatus, viewTitle: &viewTitle) // View predicate and title set
            
            switch timeFrameButtonPressed {
            case .Total:
                //Total Section Header selected
                graphData(.Total, settledStatus: settledStatus, currencyType: currencyType)
            case .Past24Hours:
                // Past 24 hours Section Header selected
                graphData(.Past24Hours, settledStatus: settledStatus, currencyType: currencyType)
            case .Past6Days:
                // Past 6 Days Section Header selected
                graphData(.Past6Days, settledStatus: settledStatus, currencyType: currencyType)
            case .Past30Days:
                // Past 30 Days Section Header selected
                graphData(.Past30Days, settledStatus: settledStatus, currencyType: currencyType)
            case .Past12Days,.Past60Days:
                break
            }
            
            // Passed to the next view
            DestViewController.viewTitle = viewTitle
            DestViewController.settledStatus = settledStatus
            DestViewController.timeFrameMonths = timeFrameMonths
            DestViewController.totalTransactions = totalTransactions
            DestViewController.refundTransactions = refundTransactions
            DestViewController.authTransactions = authTransactions
            DestViewController.declineTransactions = declineTransactions
            DestViewController.currencyType = currencyType.rawValue
            
        } else if segue.identifier == "OpenTableSegue" {
            let DestViewController: ResultsVC = segue.destinationViewController as! ResultsVC
            var settledStatus = ""
            var viewTitle = ""
            
            settledStatusForNextView(&settledStatus, viewTitle: &viewTitle) // View predicate and title set
            
            var dateFrom = NSDate()
            var dateTo = NSDate()
            
            // sets the time to 00:00
            dateFrom = calender.startOfDayForDate(dateFrom)
            dateTo = calender.startOfDayForDate(dateTo)
            
            // set to tomorrow
            dateFrom = calender.dateByAddingUnit(.Day, value: +1, toDate: dateFrom, options: [])!
            dateTo = calender.dateByAddingUnit(.Day, value: +1, toDate: dateTo, options: [])!
            
            switch timeFrameButtonPressed {
            case .Total:
                // Total Header Selected
                dateFrom = calender.dateByAddingUnit(.Year, value: -6, toDate: dateFrom, options: [])!
            case .Past24Hours:
                // Past 24 hours Header Selected
                dateFrom = calender.dateByAddingUnit(.Day, value: -1, toDate: dateFrom, options: [])!
            case .Past6Days:
                // Past 6 Days Header Selected
                dateFrom = calender.dateByAddingUnit(.Day, value: -6, toDate: dateFrom, options: [])!
            case .Past30Days:
                // Past 30 Days Header Selected
                dateFrom = calender.dateByAddingUnit(.Day, value: -30, toDate: dateFrom, options: [])!
            case .Past12Days,.Past60Days:
                break
            }
            
            // Passing values to next view
            DestViewController.viewTitle = viewTitle
            DestViewController.fetchRequest = predManager.graphBreakdownSearch(RequestType.All.rawValue,settledStatus: settledStatus,currencyType: currencyType.rawValue,fromDate: dateFrom, toDate: dateTo)
            DestViewController.fetchRequest.sortDescriptors = [NSSortDescriptor(key: "transRef", ascending:true)]
            
        } 
    }
}