//
//  barGraphVC.swift
//  securePortal
//
//  Created by Ben Roberts on 02/08/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.

import UIKit
import CoreData
import Charts
import Photos
import MessageUI

class BarGraphVC: UIViewController, ChartViewDelegate, UIPopoverPresentationControllerDelegate, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var barChartView: BarChartView!
    
    enum barType: String {case Total = "Total Transactions", Auth = "Authorises", Refund = "Refunds", Decline = "Declines"}
    
    var settledStatus = "" // contains settled status type
    var currencyType = "" // contains currency type
    
    // Contains a type of transactions
    var totalTransactions = [Double]()
    var refundTransactions = [Double]()
    var authTransactions = [Double]()
    var declineTransactions = [Double]()
    var allTransactionDataSet = BarChartDataSet()
    var authTransactionDataSet = BarChartDataSet()
    var refundTransactionDataSet = BarChartDataSet()
    var declineTransactionDataSet = BarChartDataSet()
    
    var timeFrameMonths = GraphDates() // For x axis dates and data points
    
    var highlightedDataSetIndex: Int?   // index of selected bar
    var barSelected = BarChartDataEntry() // data entry of a selected bar
    
    var requestType = RequestType.All // default as all
    let calender = NSCalendar.currentCalendar()
    let predManager = PredicateManager()  // collection of predicates
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barChartView.delegate = self
        graphStyle()
        barChartView.animate(xAxisDuration: 0, yAxisDuration: 1.0) // animated the chart bars
        setChart(timeFrameMonths.dateString, total: totalTransactions, refund: refundTransactions, auth: authTransactions, decline: declineTransactions)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
         Used when a bar is tapped.
         - parameters:
             - chartView: view the chart is in
             - entry: The bar selected
             - dataSetIndex: Index of the dataset
             - highlight: Whether bar is highlighted or not
     */
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        // if the bar has more than 0 transactions
        if entry.value > 0 {
            highlightedDataSetIndex = dataSetIndex // gets selected bar index
            barSelected = entry as! BarChartDataEntry // gets bar selected
            graphBreakPresent(requestType)
        }
    }
    
    ///  Unhighlights the selected bar when the popover is dismissed.
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        if highlightedDataSetIndex != nil {
            self.barChartView.highlightValue(xIndex: -1, dataSetIndex: highlightedDataSetIndex!)
        }
    }
    
    /// Popover adjusted upon orientation change.
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        //if popover is  presented
        if self.presentedViewController != nil {
            self.presentedViewController!.popoverPresentationController?.sourceRect = barChartView.getBarBounds( barSelected )
        }
    }
    
    /**
        Switches the displayed data within the graph and animates.
        - parameters:
            - sender: Graph segmented control object
    */
    @IBAction func graphChange(sender: AnyObject) {
        switch sender.selectedSegmentIndex {
        case 0:
            barChartView.data = BarChartData(xVals: timeFrameMonths.dateString, dataSets: [allTransactionDataSet]) // Changes graph data
            barChartView.animate(xAxisDuration: 0, yAxisDuration: 1.0) // animates the new data
            requestType = RequestType.All // sets the request type
        case 1:
            barChartView.data = BarChartData(xVals: timeFrameMonths.dateString, dataSets: [authTransactionDataSet])
            barChartView.animate(xAxisDuration: 0, yAxisDuration: 1.0)
            requestType = RequestType.Auth
        case 2:
            barChartView.data = BarChartData(xVals: timeFrameMonths.dateString, dataSets: [refundTransactionDataSet])
            barChartView.animate(xAxisDuration: 0, yAxisDuration: 1.0)
            requestType = RequestType.Refund
        case 3:
            barChartView.data = BarChartData(xVals: timeFrameMonths.dateString, dataSets: [declineTransactionDataSet])
            barChartView.animate(xAxisDuration: 0, yAxisDuration: 1.0)
            requestType = RequestType.Decline
        default:
            print("Error in graph segmented control")
        }
    }
    
    /**
        Customised the style of the graphView.
 
        The things which are customised are:
            - Legend
            - Description Text
            - Axes
     */
    func graphStyle() {
        
        // Customising Labels Format
        let numFormatter = NSNumberFormatter()
        numFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        barChartView.getAxis(ChartYAxis.AxisDependency.Left).valueFormatter = numFormatter // label format decimal 0.0
        barChartView.legend.enabled = false
        barChartView.descriptionText = "" // remove description
        barChartView.xAxis.labelPosition = .Bottom // Labels are placed at bottom
        if UIDevice.currentDevice().userInterfaceIdiom != .Pad {
            barChartView.xAxis.labelRotationAngle = -90 // rotates label
        }
        // Axes Colour
        barChartView.xAxis.labelTextColor = HouseStyleManager.color.White.getColor()
        barChartView.getAxis(ChartYAxis.AxisDependency.Left).labelTextColor = HouseStyleManager.color.White.getColor()
        
        barChartView.getAxis(ChartYAxis.AxisDependency.Right).drawLabelsEnabled = false //Disable right y-axis
        
        //Min
        barChartView.getAxis(ChartYAxis.AxisDependency.Left).axisMinValue = 0.0
        barChartView.getAxis(ChartYAxis.AxisDependency.Right).axisMinValue = 0.0
        
        //disabled zooming and scaling
        barChartView.pinchZoomEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.scaleXEnabled = false
        barChartView.scaleYEnabled = false
    }
    
    /**
     Sets the fetched coredata and insert data into bar dataset.
     Sets colour of each dataset and labels.
     Displays chartset.
     - parameters:
         - months: Months to put on the x-axis
         - Total: Transaction count of all request types
         - refund: Transcation count of request type refund
         - auth: Transcation count of request type authorised
         - decline: Transcation count of request type decline
     */
    func setChart(months: [String],total: [Double], refund: [Double], auth: [Double], decline : [Double]) {
        allTransactionDataSet = getBarDataSet(barType.Total.rawValue, months: months, transaction: total, barColour: HouseStyleManager.color.Cerise.getColor())
        authTransactionDataSet = getBarDataSet(barType.Auth.rawValue, months: months, transaction: auth, barColour: HouseStyleManager.color.CeriseMinus30.getColor())
        refundTransactionDataSet = getBarDataSet(barType.Refund.rawValue, months: months, transaction: refund, barColour: HouseStyleManager.color.CeriseMinus90.getColor())
        declineTransactionDataSet = getBarDataSet(barType.Decline.rawValue, months: months, transaction: decline, barColour: HouseStyleManager.color.CeriseMinus120.getColor())
        
        let dataSets: [ChartDataSet] = [allTransactionDataSet] //combining lines together
        
        let chartData = BarChartData(xVals: months, dataSets: dataSets) // making datapoints and datasets relates on axes
        barChartView.data = chartData //placing chartData into chart view
    }
    
    /**
        Returns a bar dataset
         - parameters:
             - barLabel: label for the bar
             - months: Data points 
             - transaction: Value of each point 
             - barColour: Colour of bar
     */
    func getBarDataSet(barLabel: String, months: [String], transaction: [Double], barColour: UIColor) -> BarChartDataSet {
        var dataEntries: [ChartDataEntry] = []
        
        // Adding Data For Each Line (Auth/Refund/Decline)
        for i in 0..<months.count {
            dataEntries.append(BarChartDataEntry(value: transaction[i], xIndex: i))
        }
        
        // Adding Data To Each Bar
        let transactionDataSet = BarChartDataSet(yVals: dataEntries, label: barLabel)
        
        //Customzing Each Dataset line
        transactionDataSet.colors = [barColour]
        transactionDataSet.valueTextColor = HouseStyleManager.color.White.getColor()
        transactionDataSet.drawValuesEnabled = false
        
        return transactionDataSet
    }
    
    /**
         Creates and displays an instance of the graphBreakdown view controller.
         Sets varaibles within the graphBreakdown view controller.
         
         - parameters:
             - segSelected: Represents the current graph displayed e.g. All, Auth Refund.
     */
    func graphBreakPresent(barType: RequestType) {
        let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("graphBreakdown") as! GraphBreakdownVC
        
        //setting variables within view
        popoverContent.requestType = barType
        popoverContent.dateFrom = timeFrameMonths.dateNS[barSelected.xIndex].start
        popoverContent.dateTo = timeFrameMonths.dateNS[barSelected.xIndex].end
        popoverContent.settledStatus = settledStatus
        popoverContent.currencyType = currencyType
        
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover = nav.popoverPresentationController
        
        popoverContent.preferredContentSize = CGSizeMake(300,250) // prefered popover height
        
        popover!.delegate = self
        // displays popover next to the selected bar
        popover!.sourceView = barChartView
        popover!.sourceRect = barChartView.getBarBounds( barSelected )
        
        self.presentViewController(nav, animated: true, completion: nil) // displays view
    }
    
    /**
         Fetches graph as image and inserts into email
     */
    func fetchesGraphAsImage() {
        barChartView.saveToCameraRoll()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
        
        if let lastAsset: PHAsset = fetchResult.lastObject as? PHAsset {
            let manager = PHImageManager.defaultManager()
            let imageRequestOptions = PHImageRequestOptions()
            
            manager.requestImageDataForAsset(lastAsset, options: imageRequestOptions) {
                (let imageData: NSData?, let dataUTI: String?,
                let orientation: UIImageOrientation,
                let info: [NSObject : AnyObject]?) -> Void in
                
                if let imageDataUnwrapped = imageData {
                    self.sendEmailWithGraph(imageDataUnwrapped)
                }
            }
        }
    }
    
    /**
        Displays an email view with the currenct bar graph image
     */
    func sendEmailWithGraph(imageData: NSData){
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([])
            mail.addAttachmentData(imageData, mimeType: "image/jpeg", fileName: "Graph")
            mail.setSubject("")
            mail.setMessageBody("", isHTML: false)
            mail.navigationBar.tintColor = HouseStyleManager.color.Cerise.getColor()
            self.presentViewController(mail, animated: true, completion: nil)
        } else {
            print("Cannot send mail")
            self.popUpAlert()
        }
    }
    
    /**
         Opens email with graph.
         - parameters:
             - sender: save icon.
     */
    @IBAction func saveGraph(sender: AnyObject) {
        let actionAlert = UIAlertController(title: nil, message: "Save Graph" , preferredStyle: .ActionSheet)
        
        let save = UIAlertAction(title:"Save To Camera Roll", style: .Default, handler: { (action: UIAlertAction!) in
            self.barChartView.saveToCameraRoll()
        })
        let email = UIAlertAction(title:"Send In Email", style: .Default, handler: { (action: UIAlertAction!) in
            self.fetchesGraphAsImage()
        })
        actionAlert.addAction(save)
        actionAlert.addAction(email)
        actionAlert.addAction(UIAlertAction(title:"Cancel", style: .Cancel,handler: nil))
        
        actionAlert.popoverPresentationController?.sourceView = sender as! UIButton
        actionAlert.popoverPresentationController?.sourceRect = sender.bounds
        
        self.presentViewController(actionAlert, animated: true, completion: nil)
        actionAlert.view.tintColor = HouseStyleManager.color.Cerise.getColor()
    }
    /// Displays an alert controller for when a email cannot be sent.
    func popUpAlert() {
        let alertController = UIAlertController(title: "Could Not Send Email", message: "Please check e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
        alertController.view.tintColor = HouseStyleManager.color.Cerise.getColor()
    }
    
    /// Generates all the different mail statuses to be displayed.
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError?) {
        switch result {
        case MFMailComposeResultCancelled:
            print("Mail cancelled")
        case MFMailComposeResultSaved:
            print("Mail saved")
        case MFMailComposeResultSent:
            print("Mail sent")
        case MFMailComposeResultFailed:
            popUpAlert()
            print("Mail sent failure: \(error?.localizedDescription)")
        default:
            break
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
