//
//  TimeFramePageViewController.swift
//  securePortal
//
//  Created by Ben Roberts on 31/08/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import UIKit

protocol TimeFramePageVCDelegate {
    func changeCurrencyButtonText(_ currencyType: CurrencyType)
}

class TimeFramePageVC: UIPageViewController {
    var timeFrameDelegate: TimeFramePageVCDelegate? // Unables passing to parent view
    var currentPageIndex = 0 // current view controller displayed index
    
    /// Sets the page view order.
    fileprivate(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.timeFramePageViewController(.GBP),
                self.timeFramePageViewController(.EURO),
                self.timeFramePageViewController(.USD)]
    }()
    
    /// Gets an instance of a view
    fileprivate func timeFramePageViewController(_ CurrencyTimeFrameView: CurrencyType) -> UIViewController {
        let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TimeFrameViewController") as! TimeFrameVC
        switch CurrencyTimeFrameView {
        case .GBP:
            view.currencyType = .GBP
        case .EURO:
            view.currencyType = .EURO
        case .USD:
            view.currencyType = .USD
        }
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
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
        pageControl.isUserInteractionEnabled = false
        
    }

    /// Move to view controller with right transition animation.
    func jumpRight(_ currencyTypeIndex: Int) {
        currentPageIndex = currencyTypeIndex
        setViewControllers([orderedViewControllers[currencyTypeIndex]], direction: .forward, animated: true, completion: nil)
    }
    
    /// Move to view controller with left transition animation.
    func jumpLeft(_ currencyTypeIndex: Int) {
        currentPageIndex = currencyTypeIndex
        setViewControllers([orderedViewControllers[currencyTypeIndex]], direction: .reverse, animated: true, completion: nil)
    }
}

// MARK: UIPageViewControllerDataSource

extension TimeFramePageVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

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
    
    /// Sets the parent header button with the current view currency type.
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],transitionCompleted completed: Bool){
        guard completed else { return }
        
        let currentViewController = pageViewController.viewControllers![0] as! TimeFrameVC
        timeFrameDelegate?.changeCurrencyButtonText(currentViewController.currencyType)
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
