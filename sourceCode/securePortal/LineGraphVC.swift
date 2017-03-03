//
//  lineGraphVC.swift
//  securePortal
//
//  Created by Ben Roberts on 02/08/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import UIKit
import Charts

class LineGraphVC: UIViewController, ChartViewDelegate, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var lineChartView: LineChartView!
    
    enum lineType: String {case Auth = "Authorises", Refund = "Refunds", Decline = "Declines"}
    
    // Contains a type of transactions
    var refundTransactions = [Double]()
    var authTransactions = [Double]()
    var declineTransactions = [Double]()
    
    var timeFrameMonths = GraphDates() // For x axis dates and data points
    
    let calender = Calendar.current
    let predManager = PredicateManager()  // collection of predicates

    override func viewDidLoad() {
        super.viewDidLoad()
        
        lineChartView.delegate = self
        
        graphStyle()
        setChart(timeFrameMonths.dateString, refund: refundTransactions, auth: authTransactions, decline: declineTransactions)
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
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = NumberFormatter.Style.decimal
        lineChartView.getAxis(ChartYAxis.AxisDependency.left).valueFormatter = numFormatter // label format decimal 0.0
        
        lineChartView.legend.textColor =  HouseStyleManager.color.white.getColor()
        lineChartView.legend.position = .aboveChartCenter
        
        lineChartView.descriptionText = "" // remove description
        lineChartView.xAxis.labelPosition = .bottom // Labels are placed at bottom
        
        if UIDevice.current.userInterfaceIdiom != .pad {
            lineChartView.xAxis.labelRotationAngle = -90 // rotates label
        } else {
            lineChartView.xAxis.avoidFirstLastClippingEnabled = true
            lineChartView.xAxis.labelRotationAngle = 45
        }
    
        // Axes Colour
        lineChartView.xAxis.labelTextColor = HouseStyleManager.color.white.getColor()
        lineChartView.getAxis(ChartYAxis.AxisDependency.left).labelTextColor = HouseStyleManager.color.white.getColor()
        lineChartView.getAxis(ChartYAxis.AxisDependency.right).drawLabelsEnabled = false //Disable right y-axis
        
        //Min
        lineChartView.getAxis(ChartYAxis.AxisDependency.left).axisMinValue = 0.0
        lineChartView.getAxis(ChartYAxis.AxisDependency.right).axisMinValue = 0.0
        
        //disabled zooming and scaling
        lineChartView.doubleTapToZoomEnabled = false
    }

    /**
        Used when a dot is tapped.
         - parameters:
             - chartView: view the chart is in
             - entry: The bar selected
             - dataSetIndex: Index of the dataset
             - highlight: Whether bar is highlighted or not
    */
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        // If the dot tapped belongs to the Authorises label
        if let dotType = lineType.init(rawValue: (chartView.data!.getDataSetForEntry(entry)?.label)!) {
            switch dotType {
            case .Auth:
                graphBreakPresent(RequestType.Auth, dotSelected: entry)
            case .Refund:
                graphBreakPresent(RequestType.Refund, dotSelected: entry)
            case .Decline:
                graphBreakPresent(RequestType.Decline, dotSelected: entry)
            }
        } else {
            print("chartValueSelected(): Unknown line type")
        }
    }
    
    /**
        Sets the fetched coredata and insert data into line dataset.
        Sets colour of each dataset and labels.
        Displays chartset.
        - parameters:
            - months: Months to put on the x-axis
            - refund: Transcation count of request type refund
            - auth: Transcation count of request type authorised
    */
    func setChart(_ months: [String], refund: [Double], auth: [Double], decline : [Double]) {
        let authTransactionDataSet =
            getLineDataSet(lineType.Auth.rawValue, months: months, transaction: auth, lineColour: HouseStyleManager.color.ceriseMinus30.getColor())
        let refundTransactionDataSet =
            getLineDataSet(lineType.Refund.rawValue, months: months, transaction: refund, lineColour: HouseStyleManager.color.ceriseMinus90.getColor())
        let declineTransactionDataSet =
            getLineDataSet(lineType.Decline.rawValue, months: months, transaction: decline, lineColour: HouseStyleManager.color.ceriseMinus120.getColor())
        
        let dataSets: [ChartDataSet] = [authTransactionDataSet, refundTransactionDataSet, declineTransactionDataSet] //combining lines together
        
        // datapoints and datasets relate on axes
        let chartData = LineChartData(xVals: months, dataSets: dataSets)
        
        lineChartView.data = chartData // chartData into chart view
    }
    
    /**
         - parameters:
             - lineLabel: String containing lineLabel
             - months: Data points
             - transaction: Value of each point
             - barColour: Colour of bar
         - returns: Line dataset
     */
    func getLineDataSet(_ lineLabel: String, months: [String], transaction: [Double], lineColour: UIColor) -> LineChartDataSet {
        var dataEntries: [ChartDataEntry] = []
        
        // Adding Data For Each Line (Auth/Refund/Decline)
        for i in 0..<months.count {
            dataEntries.append(ChartDataEntry(value: transaction[i], xIndex: i))
        }
        
        // Adding Data To Each Bar
        let transactionDataSet = LineChartDataSet(yVals: dataEntries, label: lineLabel)
        
        //Customzing Each Dataset line
        transactionDataSet.colors =  [lineColour]
        transactionDataSet.circleColors = [lineColour]
        transactionDataSet.valueTextColor = HouseStyleManager.color.white.getColor()
        
        transactionDataSet.lineWidth = 3.0
        
        return transactionDataSet
    }
    
    /// Popover adjusted upon orientation change.
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        //if popover is  presented
        if self.presentedViewController != nil {
            self.presentedViewController!.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY,width: 0.0,height: 0.0)
        }
    }
    
    /**
        Displays a breakdown of the dot pressed's transactions
         - parameters:
             - barType: The request type the bar is e.g. auth, refund
             - dotSelected: Data points
    */
    func graphBreakPresent(_ barType: RequestType, dotSelected: ChartDataEntry) {
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "graphBreakdownPage") as! GraphBreakdownPageVC
 
        popoverContent.dateFrom = timeFrameMonths.dateNS[dotSelected.xIndex].start
        popoverContent.dateTo = timeFrameMonths.dateNS[dotSelected.xIndex].end
        popoverContent.dotWasPress = barType
        
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popover = nav.popoverPresentationController
        
        popoverContent.preferredContentSize = CGSize(width: 300,height: 250) // prefered popover height
        
        popover!.delegate = self
        // displays popover next to the selected bar
        popover!.sourceView = lineChartView
        popover!.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY,width: 0.0,height: 0.0) // places the popover in the center of the screen
        popover!.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0) // removes popover anchor
        
        self.present(nav, animated: true, completion: nil) // displays view
    }
}
