//
//  SearchVC.swift
//  securePortal
//
//  Created by Ben Roberts on 22/06/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import Foundation
import CoreData

class SearchVC: UIViewController,UISearchBarDelegate, UIGestureRecognizerDelegate{
    /**
        This enum contains the different errors that can occur
        - EmptyFields: Both dates and trans ref fields are empty
        - EmptyField:One date as been provided while the other hasn't
        - WrongOrderWithTransRef: Dates has been provided in the wrong order with a trans ref
        - WrongOrder: Dates have been provided in the wrong order
    */
    enum popAlertTypes {case EmptyFields, EmptyField, WrongOrderWithTransRef, WrongOrder}
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet weak var filterSortSeg: UISegmentedControl!
    @IBOutlet weak var filterTableContainer: UIView!
    @IBOutlet weak var sortTableContainer: UIView!
    @IBOutlet weak var searchOptionsView: UIView!
    @IBOutlet weak var searchOptionSeg: UISegmentedControl!
    
    var filterCellDescriptor: NSMutableArray! // cell descriptor for filter table
    var sortCellDescriptor: NSMutableArray! // cell descriptor for sort table
    
    var predManager = PredicateManager()
    let dateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DropdownSelectionManager.sharedInstance // Initlaises gloabl/singleton
        
        // Makes segmented control square
        filterSortSeg.layer.borderColor = HouseStyleManager.color.Cerise.getColor().CGColor
        filterSortSeg.layer.cornerRadius = 0.0;
        filterSortSeg.layer.borderWidth = 1.5;
        
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage(),
            forBarPosition: .Any,
            barMetrics: .Default)
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        hamburgerBar()
        dismissKeyboardGesture()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let searchfield =  searchField.valueForKey("searchField") as? UITextField
        
        searchfield?.textColor = HouseStyleManager.color.White.getColor()
        searchField.delegate = self
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
    
    /// When searchbar is begin edited
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchOptionsView.hidden = false
        filterSortSeg.hidden = true
    }
    
    /// When searchbar is stopped begining edited
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchOptionsView.hidden = true
        filterSortSeg.hidden = false
    }
    
    /// Enables tap-gesture to dismiss keyboard upon tapping the view.
    func dismissKeyboardGesture() {
        let tapper = UITapGestureRecognizer(target: view, action:#selector(UIView.endEditing))
        tapper.cancelsTouchesInView = false
        tapper.delegate = self
        view.addGestureRecognizer(tapper)
        view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())

        searchOptionsView.removeGestureRecognizer(tapper)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isEqual(searchOptionSeg){
            return false
        }
        return true
    }
    
    /**
        Displays and hide respective dropdown menus
        - parameters:
            - sender: filterSortSeg
    */
    @IBAction func changeSearch(sender: AnyObject) {
        // Makes filter dropdowns visbile
        if filterSortSeg.selectedSegmentIndex == 0{
            filterTableContainer.hidden = false
            sortTableContainer.hidden = true
        // Makes sort dropdowns visible
        } else {
            filterTableContainer.hidden = true
            sortTableContainer.hidden = false
        }
    }
    
    /**
        Preform a search upon pressing
         - parameters:
             - sender: keyboard search button
    */
    func searchBarSearchButtonClicked( searchBar: UISearchBar){
        doSearch()
    }
    
    /**
         Preform a search upon pressing
         - parameters:
             - sender: searchButton
     */
    @IBAction func search(sender: AnyObject) {
        doSearch()
    }
    
    /**
        Sets the search criteria and
        segue to the result view
    */
    func doSearch() {
        filterCellDescriptor = DropdownSelectionManager.sharedInstance.filterCellDescriptors // Sets the global/singlton varaible for filters
        let fromDate = filterCellDescriptor[filterCellName.FromDate.getCell().cellSection][filterCellName.FromDate.getCell().cellRow]["secondaryTitle"] as! String
        let toDate = filterCellDescriptor[filterCellName.ToDate.getCell().cellSection][filterCellName.ToDate.getCell().cellRow]["secondaryTitle"] as! String

        // If search field and dates are empty
        if searchField.text?.isEmpty == true && fromDate == "" && toDate  == "" {
            showAlert(.EmptyFields) // show alert
        // If search field is empty and one date selection field is empty
        } else if searchField.text?.isEmpty == true && ((fromDate != "" && toDate == "") || (fromDate == "" && toDate != "")) {
            showAlert(.EmptyField)
        // If search field is not empty and one date selection field is empty
        } else if searchField.text?.isEmpty == false && ((fromDate != "" && toDate == "") || (fromDate == "" && toDate != "")) {
            showAlert(.EmptyField)
        // if search field is empty and one toDate is less than the fromDate
        } else if searchField.text?.isEmpty == true && ( dateFormatter.dateFromString(fromDate)!.compare(dateFormatter.dateFromString(toDate)!) == .OrderedDescending )  {
            showAlert(.WrongOrder)
        // if search field is not empty and one toDate is less than the fromDate
        } else if searchField.text?.isEmpty == false && fromDate != "" && toDate  != "" && ( dateFormatter.dateFromString(fromDate)!.compare(dateFormatter.dateFromString(toDate)!) == .OrderedDescending )  {
            showAlert(.WrongOrderWithTransRef)
        // if search criteria is ok
        } else {
            sortCellDescriptor = DropdownSelectionManager.sharedInstance.sortCellDescriptors // Sets the global/singlton varaible for sort
            self.performSegueWithIdentifier("searchResults", sender: self) // performs segue to results view
        }
    }
    
    /**
        Calls an alert controller based on the enum provided which will be displayed in the view.
 
        - parameters:
            - alertEnum: Represents the error that should be displayed.
    */
    func showAlert(alertEnum: popAlertTypes) {
        let alertController: UIAlertController
        switch (alertEnum){
        case .EmptyFields:
            alertController = UIAlertController(title: "Error", message:
                "Please enter dates or transaction reference.", preferredStyle: UIAlertControllerStyle.Alert)
        case .EmptyField:
            alertController = UIAlertController(title: "Error", message:
                "Please enter both dates.", preferredStyle: UIAlertControllerStyle.Alert)
        case .WrongOrderWithTransRef:
            alertController = UIAlertController(title: "Error", message:
                "FromDate must be greater than ToDate.", preferredStyle: UIAlertControllerStyle.Alert)
        case .WrongOrder:
            alertController = UIAlertController(title: "Error", message:
                "FromDate must be greater than ToDate.", preferredStyle: UIAlertControllerStyle.Alert)
        }
        
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil)) //adding a button the the alert
        self.presentViewController(alertController, animated: true, completion: nil) // displays the alert
        alertController.view.tintColor = HouseStyleManager.color.Cerise.getColor() // sets button text colour
    }
    
    
    /// Assigns a fetch request to a variable within the results view before the segue.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "searchResults" {
            let DestViewController: ResultsVC = segue.destinationViewController as! ResultsVC
            var searchType = ""
            //sets fetch request
            switch searchOptionSeg.selectedSegmentIndex {
            case 0:
                searchType = "transRef"
            case 1:
                searchType = "amount"
            case 2:
                searchType = "settledAmount"
            default:
                print("Error in segmented control")
            }
            DestViewController.fetchRequest = predManager.searchPredicate(searchField.text!, filterCellDescriptor: filterCellDescriptor, sortCellDescriptor: sortCellDescriptor, searchType: searchType)
        }
    }
}