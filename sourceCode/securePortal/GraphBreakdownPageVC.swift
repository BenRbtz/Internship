//
//  graphBreakdownPageViewController.swift
//  securePortal
//
//  Created by Ben Roberts on 17/08/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import UIKit

class GraphBreakdownPageVC: UIPageViewController {
    var dotWasPress = RequestType.Auth // dot that was selected in line chart
    var viewControllerOrder = [String]() // page view order
    var dateFrom = Date() // fromDate of the breakdown
    var dateTo = Date() //toDate of the breakdown
    
    // Contains a type of transactions
    var totalTransactions = [Double]()
    var refundTransactions = [Double]()
    var authTransactions = [Double]()
    
    var timeFrameMonths = GraphDates() // For x axis dates and data points
    
    /// Sets the page view order
    fileprivate(set) lazy var orderedViewControllers: [UIViewController] = {
        self.title = self.dotWasPress.rawValue
        switch self.dotWasPress {
        case .Auth:
            self.viewControllerOrder = [RequestType.Auth.rawValue, RequestType.Refund.rawValue, RequestType.Decline.rawValue]
            return [self.graphBreakdownViewController(.Auth),
                    self.graphBreakdownViewController(.Refund),
                    self.graphBreakdownViewController(.Decline)]
        case .Refund:
            self.viewControllerOrder = [RequestType.Refund.rawValue, RequestType.Auth.rawValue, RequestType.Decline.rawValue]
            return [self.graphBreakdownViewController(.Refund),
                    self.graphBreakdownViewController(.Auth),
                    self.graphBreakdownViewController(.Decline)]
        case .Decline:
            self.viewControllerOrder = [RequestType.Decline.rawValue, RequestType.Auth.rawValue, RequestType.Refund.rawValue]
            return [self.graphBreakdownViewController(.Decline),
                    self.graphBreakdownViewController(.Auth),
                    self.graphBreakdownViewController(.Refund)]
        case .All:
            return []
        }
    }()
    
    /// Gets an instance of a view
    fileprivate func graphBreakdownViewController(_ requestType: RequestType) -> UIViewController {
        let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "graphBreakdown") as! GraphBreakdownVC
        view.dateFrom = dateFrom
        view.dateTo = dateTo
        view.requestType = requestType
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = HouseStyleManager.color.darkGreyAdd10.getColor()
        dataSource = self
        stylePageControl()
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }

    /// Sets the style of the pagecontrol
    fileprivate func stylePageControl() {
        let pageControl = UIPageControl.appearance(whenContainedInInstancesOf: [type(of: self)])
        
        pageControl.currentPageIndicatorTintColor = UIColor(red: 231.0/255.0, green: 27.0/255.0, blue: 90.0/255.0, alpha: 1.0)
        pageControl.pageIndicatorTintColor = UIColor(red: 231.0/255.0, green: 27.0/255.0, blue: 90.0/255.0, alpha: 0.25)
        pageControl.backgroundColor = UIColor(red: 228.0/255.0, green: 228.0/255.0, blue: 228.0/255.0, alpha: 1.0)
        pageControl.isUserInteractionEnabled = false
    }
}

// MARK: UIPageViewControllerDataSource

extension GraphBreakdownPageVC: UIPageViewControllerDataSource {
    
    /// Slide right to left view to display
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
  
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        self.title = viewControllerOrder[viewControllerIndex]
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    /// Slide left to right view to display
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        self.title = viewControllerOrder[viewControllerIndex]
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    /// Sets the view count icons
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    /// Shows the current view circle
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    
    /**
         Dismisses View controller.
         - parameters:
             - sender: dismiss button on the navigation bar
     */
    @IBAction func dismissView(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}
