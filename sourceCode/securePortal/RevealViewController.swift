//
//  RevealViewController.swift
//  securePortal
//
//  Created by Ben Roberts on 22/06/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//


import UIKit

class RevealViewController: SWRevealViewController, SWRevealViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self

        self.rearViewRevealOverdraw = 0
        self.rearViewRevealDisplacement = 0
        
        self.panGestureRecognizer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
