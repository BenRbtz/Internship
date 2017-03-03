//
//  MainVCTest.swift
//  securePortal
//
//  Created by Ben Roberts on 07/09/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import Foundation


import UIKit
import XCTest
@testable import securePortal

class MainVCTest: XCTestCase {
    class ViewControllerMock: MainVC {
        var viewControllerToPresent: UIViewController?
        var segueIdentifier: NSString?
        
        override func performSegueWithIdentifier(identifier: String?, sender: AnyObject?) {
            segueIdentifier = identifier
        }
        
        override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
            self.viewControllerToPresent = viewControllerToPresent
        }
    }
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testChangeGraphTimeFrame() {
        
        class ViewControllerMock: MainVC {
            var changedTimeFrameTo: timeFrames?
            var setSettledStatus:String?
            
            override private func graphData(graphBarDateRange: timeFrames, settledStatus: String) {
                changedTimeFrameTo = graphBarDateRange
                setSettledStatus = settledStatus
            }
        }
        
        let controller = ViewControllerMock()
        
        XCTAssertNil(controller.changedTimeFrameTo , "Before view loads should be nil")
        XCTAssertNil(controller.setSettledStatus , "Before view loads should be nil")
        
        controller.graphChildView = GraphPageVC()
        
        controller.changeGraphTimeFrame(.Total)
        XCTAssertNil(controller.changedTimeFrameTo, "Should be equal to nil.")
        
        controller.changeGraphTimeFrame(.Past24Hours)
        XCTAssertNil(controller.changedTimeFrameTo, "Should be equal to nil.")
        
        controller.changeGraphTimeFrame(.Past6Days)
        XCTAssertEqual(controller.changedTimeFrameTo, timeFrames.Past6Days, "Both should be equal to Past 6 Days enum.")
        
        controller.changeGraphTimeFrame(.Past12Days)
        XCTAssertEqual(controller.changedTimeFrameTo, timeFrames.Past12Days, "Both should be equal to Past 12 Days enum.")
        
        controller.changeGraphTimeFrame(.Past30Days)
        XCTAssertEqual(controller.changedTimeFrameTo, timeFrames.Past30Days, "Both should be equal to Past 30 Days enum.")
        
        controller.changeGraphTimeFrame(.Past60Days)
        XCTAssertEqual(controller.changedTimeFrameTo, timeFrames.Past60Days, "Both should be equal to Past 60 Days enum.")
    }

    func testChangeCurrencyButtonText(currencyType: CurrencyType) {
//        class ViewControllerMock: MainVC {
//            var changedTimeFrameTo: timeFrames?
//            var setSettledStatus:String?
//            
//            override private func graphData(graphBarDateRange: timeFrames, settledStatus: String) {
//                changedTimeFrameTo = graphBarDateRange
//                setSettledStatus = settledStatus
//            }
//        }
//        let controller = ViewControllerMock()
//        
//        controller.currencyTypeButton = UIButton()
//        controller.changeCurrencyButtonText(.GBP)
//        
//        XCTAssertEqual(controller.currencyTypeSelected,CurrencyType.GBP, " should be GBP")
//        XCTAssertEqual(controller.currencyTypeButton.titleLabel,CurrencyType.GBP.rawValue, " should be GBP")
    }
}