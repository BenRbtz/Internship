//
//  BackTableVCTest.swift
//  securePortal
//
//  Created by Ben Roberts on 09/08/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import UIKit
import XCTest
@testable import securePortal

class BackTableVCTest: XCTestCase {
    class ViewControllerMock: BackTableVC {
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
    
    func testPopUpAlert() {
        let controller = ViewControllerMock()
        
        XCTAssertNil(controller.viewControllerToPresent , "Before view loads should be nil")
        
        controller.popUpAlert()
        
        if let alert = controller.viewControllerToPresent as? UIAlertController {
            XCTAssertEqual("Log Out", alert.title!)
            XCTAssertEqual("Are you sure you want to logout?", alert.message!)
        } else {
            XCTFail("UIAlertController failed to be presented")
        }
    }
}
