//
//  BackTableVC.swift
//  securePortal
//
//  Created by Ben Roberts on 21/06/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import Foundation

class BackTableVC : UITableViewController {
    var TableArray:[String]?  // Contains Table Row Names
    var mainVC: MainVC?
    
    override func viewDidLoad() {
        TableArray = ["Home","Search", "Settings", "Contact Us", "Log Out"]
        setFrontViewController()
    }
    
    /**
        Sets the first view to be opened.
    
        At this moment the first view is: **Main View**
     */
    func setFrontViewController() {
        // First view to open
        let navController = self.revealViewController().frontViewController as? UINavigationController
        mainVC = navController!.topViewController as? MainVC
        
        self.clearsSelectionOnViewWillAppear = false // Keeps the view entry selected
        
        // Set the selection in menu table view to the front view controller. At this time it is mainVC
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView?.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
        
        highlightCell(indexPath)
    }
    
    /// Sets table size based on cell count.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableArray!.count
    }
    
    /// Sets all cell backgrounds to dark grey.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableArray![indexPath.row], forIndexPath: indexPath) as UITableViewCell
        cell.backgroundColor = HouseStyleManager.color.DarkGrey.getColor()
        return cell
    }
    
    /// Highlights a selected cell.
    override func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        highlightCell(indexPath)
    }
    
    /// Makes each cell selected segue to a respective view.
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var controller: UIViewController?
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // case 0 uses the same controller instance while rest don't i.e. view did load only loads once!
        switch indexPath.row {
        case 0:
            if mainVC == nil {
                mainVC = storyboard.instantiateViewControllerWithIdentifier("mainVC") as? MainVC // instance of view
            }
            controller = mainVC!
        case 1:
            controller = storyboard.instantiateViewControllerWithIdentifier("searchVC") as? SearchVC
        case 2:
            controller = storyboard.instantiateViewControllerWithIdentifier("settingsVC") as? SettingsVC
        case 3:
            controller = storyboard.instantiateViewControllerWithIdentifier("contactUsVC") as? ContactUsVC
        case 4:
            popUpAlert()
            tableView.deselectRowAtIndexPath(indexPath, animated: false) // removes deselect bug
        default: break
        }
        if controller != nil {
            let navController = UINavigationController(rootViewController: controller!)
            revealViewController().pushFrontViewController(navController, animated:true) // changes displayed view
        }
    }
    
    /// Calls an alert controller confirming whether the user wanted to log out.
    func popUpAlert() {
        let alertController  = UIAlertController(title: "Log Out", message:
            "Are you sure you want to logout?", preferredStyle: UIAlertControllerStyle.Alert)
        
        // Add actions
        alertController.addAction(UIAlertAction(title: "Yes", style: .Default , handler: { (action: UIAlertAction!) in
            self.performSegueWithIdentifier("loginSegue", sender: self) // segue to login view Controller
        }))
        
        alertController.addAction(UIAlertAction(title: "No", style: .Default ,handler: nil))

        
        self.presentViewController(alertController, animated: true, completion: nil) // presents alert view
        alertController.view.tintColor = HouseStyleManager.color.Cerise.getColor() // sets alert view button colour
    }
    
    /// Sets the highlighted cell in the reveal menu.
    func highlightCell(indexPath: NSIndexPath) {
        let selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)! // cell position
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = HouseStyleManager.color.DarkGreyMinus10.getColor() // sets highlight colour
        selectedCell.selectedBackgroundView = backgroundView // set highlight to cell
    }
}