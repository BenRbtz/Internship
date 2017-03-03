//
//  ViewController.swift
//  securePortal
//
//  Created by Ben Roberts on 17/06/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import UIKit
import CoreData
import Charts
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class MainVC: UIViewController, TimeFramePageVCDelegate {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var graphDateRangeButton: UIButton!
    @IBOutlet weak var currencyTypeButton: UIButton!
    @IBOutlet weak var totalTransactionsLabel: UILabel!
    
    // Contains a type of transactions
    var totalTransactions = [Double]()
    var refundTransactions = [Double]()
    var authTransactions = [Double]()
    var declineTransactions = [Double]()
    
    var timeFrameMonths = GraphDates() // For x axis dates and data points
    
    let calender = Calendar.current
    let predManager = PredicateManager() // For execution of pre-built predicates
    
    var graphChildView:GraphPageVC? //  For passing graph data to child view
    var graphDateRangeSelected = timeFrames.Past6Days // For keeping track which date range was selected on graph
    
    var timeFrameChildView: TimeFramePageVC? // For sets delegate and passing values to parent view
    var currencyTypeSelected = CurrencyType.GBP // For keeping track which timeFrameView is being displayed
    
    var numberDecimalFormatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberDecimalFormatter.numberStyle = NumberFormatter.Style.decimal
        
        navLogo()
        hamburgerBar()
        setTotalTransactionCount()
        
        graphChildView = self.childViewControllers[0] as? GraphPageVC
        timeFrameChildView = self.childViewControllers[1] as? TimeFramePageVC
        timeFrameChildView?.timeFrameDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage(),
            for: .any,
            barMetrics: .default)
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Sets the center of the navigation bar to the secure trading logo
    func navLogo(){
        let image = UIImage(named: "st_logo-white-trans-big-notag") // gets image
        let imageView = UIImageView(frame:CGRect(x: 0, y: 0, width: 25, height: 35)) // set view size
        imageView.contentMode = .scaleAspectFit // scale aspect fit for view
        imageView.image = image // inserts image into view
        self.navigationItem.titleView = imageView // inserts into navigation bar
    }
    
    /**
        Enables the use of the hamburgerBar.
        Enables tap-gesture to hide bar.
     */
    func hamburgerBar() {
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer()) // adds tap-gesture to hide bar
        }
    }
    
    /// Sets the total transactions from the CSV to a label
    func setTotalTransactionCount() {
        var startOfTodayDate = Date() // Today
        var todayDate = Date()
        
        startOfTodayDate = calender.startOfDay(for: startOfTodayDate)
        
        // set to tomorrow
        startOfTodayDate = (calender as NSCalendar).date(byAdding: .day, value: +1, to: startOfTodayDate, options: [])!
        todayDate = (calender as NSCalendar).date(byAdding: .day, value: +1, to: todayDate, options: [])!
        
        let dateSevenYearsAgo = (calender as NSCalendar).date(byAdding: .year, value: -6, to: startOfTodayDate, options: [])! // Years
        
        // Sets seven years ago to the first of January
        var components = (calender as NSCalendar).components([.year, .month, .day], from: dateSevenYearsAgo)
        components.day = 1
        components.month = 1
        let total = calender.date(from: components)!
        let transcation = predManager.executePredicateCounter(
            predManager.graphBreakdownSearch("",settledStatus: "", currencyType: "" , fromDate: total, toDate: todayDate))
        
        totalTransactionsLabel.text = "All Time Transactions: \(numberDecimalFormatter.string(from: transcation)!)"
    }
    
    /**
        Displays an action sheet with dates.
        These date will change the graph data.
        - parameters:
             - sender: graphDateRangeButton
    */
    @IBAction func changeGraph(_ sender: AnyObject) {
        let actionAlert = UIAlertController(title: nil, message: "Select Date Range" , preferredStyle: .actionSheet)

        actionAlert.addAction(addChangeGraphAction(timeFrames.Past6Days))
        actionAlert.addAction(addChangeGraphAction(timeFrames.Past12Days))
        actionAlert.addAction(addChangeGraphAction(timeFrames.Past30Days))
        actionAlert.addAction(addChangeGraphAction(timeFrames.Past60Days))
        
        actionAlert.addAction(UIAlertAction(title:"Cancel", style: .cancel,handler: nil))
        actionAlert.popoverPresentationController?.sourceView = sender as! UIButton
        actionAlert.popoverPresentationController?.sourceRect = sender.bounds
        
        self.present(actionAlert, animated: true, completion: nil)
        actionAlert.view.tintColor = HouseStyleManager.color.cerise.getColor()
    }
    
    /**
        Returns an actionsheet action.
        This action will change displayed graph data for the bar and line vcs.
        - parameters:
            - timeFrameType: A single timeFrame type
     */
    func addChangeGraphAction(_ timeFrameType: timeFrames) -> UIAlertAction {
        let changeGraphAction = UIAlertAction(title:timeFrameType.rawValue, style: .default, handler: { (action: UIAlertAction!) in
            if self.graphDateRangeSelected != timeFrameType {
                self.graphDateRangeButton.setTitle(timeFrameType.rawValue, for: UIControlState())
                self.changeGraphTimeFrame(timeFrameType)
                self.graphChildView!.updateBarGraph()
                self.graphChildView!.updateLineGraph()
                self.graphDateRangeSelected = timeFrameType
            }
        })
        return changeGraphAction
    }
    
    /**
         Displays an action sheet with currency types.
         These types will change the displayed view.
         - parameters:
             - sender: currencyTypeButton.
     */
    @IBAction func changeTimeFrameCurrency(_ sender: AnyObject) {
        let actionAlert = UIAlertController(title: nil, message: "Select Currency Type" , preferredStyle: .actionSheet)
        
        actionAlert.addAction(addCurrencyAction(.GBP))
        actionAlert.addAction(addCurrencyAction(.EURO))
        actionAlert.addAction(addCurrencyAction(.USD))
        actionAlert.addAction(UIAlertAction(title:"Cancel", style: .cancel,handler: nil))
        
        actionAlert.popoverPresentationController?.sourceView = sender as! UIButton
        actionAlert.popoverPresentationController?.sourceRect = sender.bounds
        
        self.present(actionAlert, animated: true, completion: nil)
        actionAlert.view.tintColor = HouseStyleManager.color.cerise.getColor()
    }
    
    /**

         This action will change displayed page view for the timeframeVC.
         - parameters:
             - timeFrameType: CurrencyType enum containing a single currency type
         - returns:
             - Actionsheet action.
    */
    func addCurrencyAction(_ currencyType: CurrencyType) -> UIAlertAction {
        let currencyAction = UIAlertAction(title: currencyType.rawValue, style: .default, handler: { (action: UIAlertAction!) in
            if self.currencyTypeSelected != currencyType {
                self.currencyTypeSelected = currencyType
                
                if self.timeFrameChildView?.currentPageIndex < currencyType.getIndex() {
                    self.timeFrameChildView?.jumpRight(currencyType.getIndex())
                } else {
                    self.timeFrameChildView?.jumpLeft(currencyType.getIndex())
                }
                
                self.currencyTypeButton.setTitle(currencyType.rawValue, for: UIControlState())
            }
        })
        return currencyAction
    }
    
    /// Changes the currencyButton text
    func changeCurrencyButtonText(_ currencyType: CurrencyType) {
        currencyTypeSelected = currencyType
        currencyTypeButton.setTitle(currencyType.rawValue, for: UIControlState())
    }
    
    /**
        Handles the different graph time frames selected and produces a new set of graph data.
        Updates both graph.
    */
    func changeGraphTimeFrame(_ timeFrameSelected: timeFrames) {
        
        switch timeFrameSelected {
        case .Past6Days:
            graphData(timeFrames.Past6Days, settledStatus: "")
        case .Past12Days:
            graphData(timeFrames.Past12Days, settledStatus: "")
        case .Past30Days:
            graphData(timeFrames.Past30Days, settledStatus: "")
        case .Past60Days:
            graphData(timeFrames.Past60Days, settledStatus: "")
        case .Past24Hours,.Total:
            break
        }
        
        graphChildView!.timeFrameMonths = timeFrameMonths
        graphChildView!.totalTransactions = totalTransactions
        graphChildView!.refundTransactions = refundTransactions
        graphChildView!.authTransactions = authTransactions
        graphChildView!.declineTransactions = declineTransactions
    }
    
    /**
         Fetches the graph data from core data.
         The data is split into three arrays for the three different graphs types.
         Calls `setChart` to set the data within the graph.
         - parameters:
             - graphBarDateRange: The date range the graph data is within.
             - settledStatus: Settled status of the bar data.
     */
    func graphData(_ graphBarDateRange: timeFrames, settledStatus: String) {
        var fromDate = Date(), toDate = Date()
        var months = [(start: Date,end: Date)]()
        var fetchRequest = NSFetchRequest()
        
        // sets the time to 00:00
        fromDate = calender.startOfDay(for: fromDate)
        toDate = calender.startOfDay(for: toDate)
        
        // set to tomorrow
        fromDate = (calender as NSCalendar).date(byAdding: .day, value: +1, to: fromDate, options: [])!
        toDate = (calender as NSCalendar).date(byAdding: .day, value: +1, to: toDate, options: [])!
        for _ in 1...6 {
            //Goes back 30 days from previous date
            switch graphBarDateRange {
            case .Total:
                break
            case .Past24Hours:
                timeFrameMonths.isHourFormat()
                fromDate = (calender as NSCalendar).date(byAdding: .hour, value: -4, to: fromDate, options: [])!
            case .Past6Days:
                timeFrameMonths.isDayFormat()
                fromDate = (calender as NSCalendar).date(byAdding: .day, value: -1, to: fromDate, options: [])!
            case .Past12Days:
                timeFrameMonths.isDayFormat()
                fromDate = (calender as NSCalendar).date(byAdding: .day, value: -2, to: fromDate, options: [])!
            case .Past30Days:
                timeFrameMonths.isDayFormat()
                fromDate = (calender as NSCalendar).date(byAdding: .day, value: -5, to: fromDate, options: [])!
            case .Past60Days:
                timeFrameMonths.isDayFormat()
                fromDate = (calender as NSCalendar).date(byAdding: .day, value: -10, to: fromDate, options: [])!
            }
            
            months.append((fromDate, toDate)) // Marks each month
            
            // Total, refund and auth transtions for each month
            fetchRequest = predManager.predicateCountBuild(RequestType.All.rawValue, settledStatus: settledStatus, currencyType: "", timeFrom: fromDate, timeTo: toDate)
            totalTransactions.append(Double(predManager.executePredicateCounter(fetchRequest)))
            
            fetchRequest = predManager.predicateCountBuild(RequestType.Refund.rawValue, settledStatus: settledStatus, currencyType: "", timeFrom: fromDate, timeTo: toDate)
            refundTransactions.append(Double(predManager.executePredicateCounter(fetchRequest)))
            
            fetchRequest = predManager.predicateCountBuild(RequestType.Auth.rawValue, settledStatus: settledStatus, currencyType: "", timeFrom: fromDate, timeTo: toDate)
            authTransactions.append(Double(predManager.executePredicateCounter(fetchRequest)))
            
            fetchRequest = predManager.predicateCountBuild(RequestType.Decline.rawValue, settledStatus: settledStatus, currencyType: "", timeFrom: fromDate, timeTo: toDate)
            declineTransactions.append(Double(predManager.executePredicateCounter(fetchRequest)))
            
            toDate = fromDate //sets previous date as current
        }
        
        // Displaying the data from oldest to youngest (achieved through reverse)
        timeFrameMonths.dateNS = months.reversed()
        totalTransactions = totalTransactions.reversed()
        refundTransactions = refundTransactions.reversed()
        authTransactions = authTransactions.reversed()
        declineTransactions = declineTransactions.reversed()
    }
    
    /**
        Prepares:
        - PageViewContainer
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pageViewContainerSegue" {
            let containerViewController = segue.destination as? GraphPageVC
            
            graphData(timeFrames.Past6Days, settledStatus: "")
            
            // Passing values to next view
            containerViewController!.timeFrameMonths = timeFrameMonths
            containerViewController!.totalTransactions = totalTransactions
            containerViewController!.refundTransactions = refundTransactions
            containerViewController!.authTransactions = authTransactions
            containerViewController!.declineTransactions = declineTransactions
        }
    }
}
