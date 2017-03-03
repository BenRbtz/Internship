//
//  filterTableController.swift
//  securePortal
//
//  Created by Ben Roberts on 13/07/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import Foundation

class FilterTableVC: UITableViewController,  filterCellDelegate {
    @IBOutlet var filterTable: UITableView!
    
    var cellDescriptors: NSMutableArray! // cell descriptor for table
    var visibleRowsPerSection = [[Int]]() // rows visible per section
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        loadCellDescriptors()
    }
    
    /// Loads the cell descriptor from the gloabl varaible then displays the cells.
    func loadCellDescriptors() {
        cellDescriptors = DropdownSelectionManager.sharedInstance.filterCellDescriptors
        
        getIndicesOfVisibleRows() // gets current visible cells
        filterTable.reloadData() // reloads table
        
        // Checks all the expanded cells to see if they need a checkmark or not
        for i in filterCellName.getCellSelectionSections(){
            updateExpanded(i, cellRow: 0)
        }
    }
    
    /// Gets the cell descriptor indexpath
    func getCellDescriptorForIndexPath(_ indexPath: IndexPath) -> [String: AnyObject] {
        let indexOfVisibleRow = visibleRowsPerSection[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        let cellDescriptor = (cellDescriptors[(indexPath as NSIndexPath).section] as! NSMutableArray)[indexOfVisibleRow] as! [String: AnyObject]
        return cellDescriptor
    }
    
    /// Gets all the current cells to be visible to the user.
    func getIndicesOfVisibleRows() {
        visibleRowsPerSection.removeAll() // clears visible array
        
        for currentSectionCells in cellDescriptors {
            var visibleRows = [Int]()
            
            // adds all visible cell rows to the array
            for row in 0...((currentSectionCells as! [[String: AnyObject]]).count - 1) {
                // Checks if the cell is meant to be visible with the current section
                if currentSectionCells[row]["isVisible"] as! Bool == true {
                    visibleRows.append(row) // adds cell to array if true
                }
            }
            
            visibleRowsPerSection.append(visibleRows)
        }
    }
    
    /// Configures the table view and registers all the Nibs to be useable.
    func configureTableView() {
        filterTable.delegate = self
        filterTable.dataSource = self
        filterTable.tableFooterView = UIView(frame: CGRect.zero)
        
        filterTable.register(UINib(nibName: "NormalCell", bundle: nil), forCellReuseIdentifier: "idCellNormal")
        filterTable.register(UINib(nibName: "DatePickerCell", bundle: nil), forCellReuseIdentifier: "idCellDatePicker")
        filterTable.register(UINib(nibName: "DatePickerCell2", bundle: nil), forCellReuseIdentifier: "idCellDatePicker2")
        filterTable.register(UINib(nibName: "ValuePickerCell", bundle: nil), forCellReuseIdentifier: "idCellValuePicker")
        filterTable.register(UINib(nibName: "setCellRequest", bundle: nil), forCellReuseIdentifier: "idSetCellRequest")
        filterTable.register(UINib(nibName: "setCellPayment", bundle: nil), forCellReuseIdentifier: "idSetCellPayment")
        filterTable.register(UINib(nibName: "setCellCurrency", bundle: nil), forCellReuseIdentifier: "idSetCellCurrency")
        filterTable.register(UINib(nibName: "setCellAccount", bundle: nil), forCellReuseIdentifier: "idSetCellAccount")
        filterTable.register(UINib(nibName: "setCellErrorCode", bundle: nil), forCellReuseIdentifier: "idSetCellErrorCode")
        filterTable.register(UINib(nibName: "setCellSettledStatus", bundle: nil), forCellReuseIdentifier: "idSetCellSettledStatus")
    }
    
    /**
         Linked to all the section's 'set' buttons, which
         passes its section and parent row position to updateExpanded method.
     */
    func setRow(_ cellSection: Int, cellRow: Int) {
        updateExpanded(cellSection, cellRow: cellRow)
    }
    
    /**
        Linked to the fromDate date picker 'set' button,
        which sets the date to the parent cell's secondary label with the new date.
        It also passes to parent cell's position to the updateExpanded method.
        - parameters:
            - selectedDateString : This contains the set date from the date picker.
    */
    func dateWasSelected(_ selectedDateString: String, cellSection:  Int,cellRow:Int) {
        
        // sets secondaryTitle for date cell with date
        cellDescriptors[cellSection][cellRow].setValue(selectedDateString, forKey: "secondaryTitle")
        
        updateExpanded(cellSection, cellRow: cellRow)
    }
    
    /**
        Linked to the fromDate date picker 'clear' button,
        which clears the parent cells secondary label if there is a date present.
        It also passes to parent cell's position to the updateExpanded method.
    */
    func clearDate(_ cellSection: Int, cellRow: Int) {
        
        cellDescriptors[cellSection][cellRow].setValue("", forKey: "secondaryTitle")
        
        updateExpanded(cellSection, cellRow: cellRow)
    }
    
    /**
        Collapses the children cells once the clear/set button has been pressed.
        Updates the global variable with the updated dropdown cell selections.
        - parameters:
            - cellSection : The index number of the parent section
            - cellRow : The index number of the parent row
    */
    func updateExpanded(_ cellSection: Int, cellRow: Int) {
        cellDescriptors[cellSection][cellRow].setValue(false, forKey: "isExpanded") // closes dropdown
        updateCheckValues(cellSection, cellRow: cellRow)
        getIndicesOfVisibleRows()
        
        DropdownSelectionManager.sharedInstance.filterCellDescriptors = cellDescriptors // updates shared variable with updated table
        
        filterTable.reloadSections(IndexSet(integer: cellSection), with: UITableViewRowAnimation.fade)
        filterTable.reloadData() // reloads table
    }
    
    /**
        Updates whether a cell has a checkmark or not.
        Collapses the dropdown.
    */
    func updateCheckValues(_ cellSection: Int, cellRow: Int) {
        var selectedValues:[String] = []
        var selectedCount = 0
        //collapses dropdown
        for i in (cellRow + 1)...(cellRow + (cellDescriptors[cellSection][cellRow]["additionalRows"] as! Int)) {
            cellDescriptors[cellSection][i].setValue(false, forKey: "isVisible")
            
            // If the cell has been selected
            if cellDescriptors[cellSection][i]["isSelected"] as? Bool == true {
                selectedCount += 1
                //adds selected value to array
                selectedValues.append(cellDescriptors[cellSection][i]["value"] as! String)
            }
        }
        // if it is not a date picker cell
        if cellDescriptors[cellSection][cellRow+1]["cellIdentifier"] as! String == "idCellValuePicker" {
            if selectedCount == 0 {
                showAlert(cellDescriptors[cellSection][cellRow]["primaryTitle"] as! String)
            }
        }
        // updates value stored in value
        cellDescriptors[cellSection][cellRow].setValue(selectedValues, forKey: "value")
    }
    
    /// Display an alert view
    func showAlert(_ cellType: String) {
        let alertController = UIAlertController(title: cellType, message:
            "No results will be display as no options were selected.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil)) //adding a button the the alert
        self.present(alertController, animated: true, completion: nil) // displays the alert
        alertController.view.tintColor = HouseStyleManager.color.cerise.getColor() // sets button text colour
    }
    
    // Sets the cell size based on which type of cell it is.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentCellDescriptor = getCellDescriptorForIndexPath(indexPath)
        
        switch currentCellDescriptor["cellIdentifier"] as! String {
        case "idCellNormal":
            return 60.0
        case "idSetCell":
            return 60.0
        case "idCellDatePicker":
            return 270.0
            
        case "idCellDatePicker2":
            return 270.0
            
        default:
            return 44.0
        }
    }
    
    /// Display the visible cells.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleRowsPerSection[section].count
    }
    
    /// Gets the number of section in the table view from the cell descriptor.
    override func numberOfSections(in tableView: UITableView) -> Int {
        if cellDescriptors != nil {
            return cellDescriptors.count
        }
        else {
            return 0
        }
    }
    
    /// Customises the style of the table cells.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentCellDescriptor = getCellDescriptorForIndexPath(indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: currentCellDescriptor["cellIdentifier"] as! String, for: indexPath) as! filterCell
        cell.backgroundColor = HouseStyleManager.color.darkGrey.getColor()
        
        // If standard cell
        if currentCellDescriptor["cellIdentifier"] as! String == "idCellNormal" {
            if let primaryTitle = currentCellDescriptor["primaryTitle"] {
                cell.textLabel?.text = primaryTitle as? String // set colour pink
            }
            
            if let secondaryTitle = currentCellDescriptor["secondaryTitle"] {
                cell.detailTextLabel?.text = secondaryTitle as? String //set colour grey
            }
        }// if a value picker cell
        else if currentCellDescriptor["cellIdentifier"] as! String == "idCellValuePicker" {
            cell.textLabel?.text = currentCellDescriptor["primaryTitle"] as? String
            
            //If cell is selected
            if currentCellDescriptor["isSelected"] as? Bool == true {
                cell.accessoryType = .checkmark // set checkmark to cell
            }
            else if currentCellDescriptor["isSelected"] as? Bool == false {
                cell.accessoryType = .none // remove checkmark from cell
            }
            
            if currentCellDescriptor["isExpandable"] as? Bool == false {
                /// Dropdown text colour set to white
                cell.textLabel?.textColor = HouseStyleManager.color.white.getColor()
            }
        }
        cell.delegate = self
        return cell
    }
    
    /// Sets whether a cell has be selected or not.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexOfTappedRow = visibleRowsPerSection[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        
        //Checks if the cell is expandable
        if cellDescriptors[(indexPath as NSIndexPath).section][indexOfTappedRow]["isExpandable"] as! Bool == true {
            var shouldExpandAndShowSubRows: Bool
            // check if it isn't already expanded
            if cellDescriptors[(indexPath as NSIndexPath).section][indexOfTappedRow]["isExpanded"] as! Bool == false {
                shouldExpandAndShowSubRows = true // sets as expanded
                
            } else {
                shouldExpandAndShowSubRows = false // sets as not expanded
                updateCheckValues((indexPath as NSIndexPath).section, cellRow: indexOfTappedRow) // Updates selected values
            }
            // Sets the descriptor to whether the dropdown should be expanded/collapsed
            cellDescriptors[(indexPath as NSIndexPath).section][indexOfTappedRow].setValue(shouldExpandAndShowSubRows, forKey: "isExpanded")
            
            //make dropdown cell visible
            for i in (indexOfTappedRow + 1)...(indexOfTappedRow + (cellDescriptors[(indexPath as NSIndexPath).section][indexOfTappedRow]["additionalRows"] as! Int)) {
                cellDescriptors[(indexPath as NSIndexPath).section][i].setValue(shouldExpandAndShowSubRows, forKey: "isVisible")
            }
        }
        else {
            //checks if the cell is a value picker
            if cellDescriptors[(indexPath as NSIndexPath).section][indexOfTappedRow]["cellIdentifier"] as! String == "idCellValuePicker" {
                
                // if the cell isn't already selected
                if cellDescriptors[(indexPath as NSIndexPath).section][indexOfTappedRow]["isSelected"] as? Bool == false {
                    // update descriptor as selected
                    cellDescriptors[(indexPath as NSIndexPath).section][indexOfTappedRow].setValue(true, forKey: "isSelected")
                } // if the cell is already selected
                else if cellDescriptors[(indexPath as NSIndexPath).section][indexOfTappedRow]["isSelected"] as? Bool == true {
                    // update descriptor as unselected
                    cellDescriptors[(indexPath as NSIndexPath).section][indexOfTappedRow].setValue(false, forKey: "isSelected")
                }
            }
        }
        getIndicesOfVisibleRows() // update visible cell
        filterTable.reloadSections(IndexSet(integer: (indexPath as NSIndexPath).section), with: UITableViewRowAnimation.fade) // reload table
    }
}
