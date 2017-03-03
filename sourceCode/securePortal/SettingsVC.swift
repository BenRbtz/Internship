//
//  SettingsVC.swift
//  securePortal
//
//  Created by Ben Roberts on 22/06/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import Foundation

class SettingsVC: UIViewController {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hamburgerBar()
    }
    
    /**
        Enables the use of the hamburgerBar.
        Enables tap-gesture to hide bar.
     */
    func hamburgerBar() {
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        }
    }
}