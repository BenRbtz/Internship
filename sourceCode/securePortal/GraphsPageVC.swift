  //
//  GraphsPageViewController.swift
//  securePortal
//
//  Created by Ben Roberts on 26/07/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import UIKit

class GraphPageVC: UIPageViewController {
    enum graphType: String {case Bar = "Bar", Line = "Line"}
    
    // Contains a type of transactions
    var totalTransactions = [Double]()
    var refundTransactions = [Double]()
    var authTransactions = [Double]()
    var declineTransactions = [Double]()
    
    var timeFrameMonths = GraphDates() // For x axis dates and data points
    var bar:BarGraphVC?
    var line:LineGraphVC?
    /// Sets the page view order
    fileprivate(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.graphViewController(.Bar), self.graphViewController(.Line)]
    }()

    /**
        Gets an instance of a view
        - parameter:
            - graph: Type of graph within view
    */
    fileprivate func graphViewController(_ graph: graphType) -> UIViewController {
        switch graph {
        case .Bar:
            let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(graph.rawValue)GraphViewController") as! BarGraphVC
            view.timeFrameMonths = timeFrameMonths
            view.totalTransactions = totalTransactions
            view.refundTransactions = refundTransactions
            view.authTransactions = authTransactions
            view.declineTransactions = declineTransactions
            return view
            
        case .Line:
            let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(graph.rawValue)GraphViewController") as! LineGraphVC
            view.timeFrameMonths = timeFrameMonths
            view.refundTransactions = refundTransactions
            view.authTransactions = authTransactions
            view.declineTransactions = declineTransactions
            return view
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        stylePageControl()
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        bar = orderedViewControllers[0] as? BarGraphVC
        line = orderedViewControllers[1] as? LineGraphVC
    }
    
    /// Updates bar graphs with new graphData.
    func updateBarGraph() {
        
        if let bar = orderedViewControllers[0] as? BarGraphVC {
            
            bar.timeFrameMonths = timeFrameMonths
            bar.totalTransactions = totalTransactions
            bar.refundTransactions = refundTransactions
            bar.authTransactions = authTransactions
            bar.declineTransactions = declineTransactions
            
            bar.setChart(timeFrameMonths.dateString, total: totalTransactions, refund: refundTransactions, auth: authTransactions, decline: declineTransactions)
        }
    }
    
    /// Updates line graphs with new graphData.
    func updateLineGraph(){
        if let line = orderedViewControllers[1] as? LineGraphVC {
        
            line.timeFrameMonths = timeFrameMonths
            line.refundTransactions = refundTransactions
            line.authTransactions = authTransactions
            line.declineTransactions = declineTransactions
            
            if line.isViewLoaded == true {
                line.setChart(timeFrameMonths.dateString, refund: refundTransactions, auth: authTransactions, decline: declineTransactions)
            }
        }
    }

    /// Sets the style of the pagecontrol
    fileprivate func stylePageControl() {
        let pageControl = UIPageControl.appearance(whenContainedInInstancesOf: [type(of: self)])

        pageControl.currentPageIndicatorTintColor = UIColor(red: 231.0/255.0, green: 27.0/255.0, blue: 90.0/255.0, alpha: 1.0)
        pageControl.pageIndicatorTintColor = UIColor(red: 231.0/255.0, green: 27.0/255.0, blue: 90.0/255.0, alpha: 0.25)
        pageControl.isUserInteractionEnabled = false

    }
}

// MARK: UIPageViewControllerDataSource

extension GraphPageVC: UIPageViewControllerDataSource {
    
    /// Slide right to left view to display
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        
        let previousIndex = viewControllerIndex - 1
        
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
}
