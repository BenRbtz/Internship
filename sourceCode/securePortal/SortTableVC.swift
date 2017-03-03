//
//  sortTableContoller.swift
//  securePortal
//
//  Created by Ben Roberts on 14/07/2016.
//  Copyright © 2016 SecureTrading. All rights reserved.
//

import Foundation

class SortTableVC: UITableViewController {
    @IBOutlet var sortTable: UITableView!
    
    var cellDescriptors: NSMutableArray! // cell descriptor for table
    var visibleRowsPerSection = [[Int]]() // rows visible per section
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        loadCellDescriptors()
    }
    
    /// Loads the cell descriptor from the global varaible then displays the cells.
    func loadCellDescriptors() {
        cellDescriptors = DropdownSelectionManager.sharedInstance.sortCellDescriptors
        getIndicesOfVisibleRows()
        sortTable.reloadData()
    }
    
    /// Gets the cell descriptor for index path.
    func getCellDescriptorForIndexPath(_ indexPath: IndexPath) -> [String: AnyObject] {
        let indexOfVisibleRow = visibleRowsPerSection[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        let cellDescriptor = (cellDescriptors[(indexPath as NSIndexPath).section] as! NSMutableArray)[indexOfVisibleRow] as! [String: AnyObject]
        return cellDescriptor
    }
    
    /// Gets all the current cells to be visible to the user.
    func getIndicesOfVisibleRows() {
        visibleRowsPerSection.removeAll()
        
        for currentSectionCells in cellDescriptors {
            var visibleRows = [Int]()
            
            for row in 0...((currentSectionCells as! [[String: AnyObject]]).count - 1) {
                visibleRows.append(row)
            }
            visibleRowsPerSection.append(visibleRows)
        }
    }
    
    /// Configures the table view.
    func configureTableView() {
        sortTable.delegate = self
        sortTable.dataSource = self
        sortTable.tableFooterView = UIView(frame: CGRect.zero)
        
        sortTable.register(UINib(nibName: "ValuePickerSortCell", bundle: nil), forCellReuseIdentifier: "idSortCellValuePicker")
    }
    
    /// Sets the size of the cells
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentCellDescriptor = getCellDescriptorForIndexPath(indexPath)
        
        switch currentCellDescriptor["cellIdentifier"] as! String {
        default:
            return 60.0
        }
    }
    
    /// Sets which table cells are visible
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleRowsPerSection[section].count
    }
    
    /// Sets the number of sections in the table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        if cellDescriptors != nil {
            return cellDescriptors.count
        }
        else {
            return 0
        }
    }
    
    /// Customises the appearence of the cell and check if the cells are selected or not and respectively showing a checkmark if true
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentCellDescriptor = getCellDescriptorForIndexPath(indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: currentCellDescriptor["cellIdentifier"] as! String, for: indexPath) as! sortCell
        
        cell.backgroundColor = HouseStyleManager.color.darkGrey.getColor() // sets cell colour to dark grey
        
        if currentCellDescriptor["cellIdentifier"] as! String == "idSortCellValuePicker" {
            cell.textLabel?.text = currentCellDescriptor["primaryTitle"] as? String
            // If cell has be selected
            if currentCellDescriptor["isSelected"] as? Bool == true {
                cell.accessoryType = .checkmark // show checkmark on the cell
            } else if currentCellDescriptor["isSelected"] as? Bool == false { // if cell has be deselected
                cell.accessoryType = .none // Don't show a checkmark on the cell
            }
        }
        return cell
    }
    
    /// Sets whether a cell has be selected or not.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexOfTappedRow = visibleRowsPerSection[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        
        // checks the cell id if it is idSortCellValuePicker
        if cellDescriptors[(indexPath as NSIndexPath).section][indexOfTappedRow]["cellIdentifier"] as! String == "idSortCellValuePicker" {
            // if cell isn't selected
            if cellDescriptors[(indexPath as NSIndexPath).section][indexOfTappedRow]["isSelected"] as? Bool == false {
                cellDescriptors[(indexPath as NSIndexPath).section][indexOfTappedRow].setValue(true, forKey: "isSelected") // set as selected
            } else {
                cellDescriptors[(indexPath as NSIndexPath).section][indexOfTappedRow].setValue(false, forKey: "isSelected") // set as unselected
            }
        }
        
        getIndicesOfVisibleRows() // gets all visible rows
        sortTable.reloadSections(IndexSet(integer: (indexPath as NSIndexPath).section), with: UITableViewRowAnimation.fade) // reloads table
        DropdownSelectionManager.sharedInstance.sortCellDescriptors = cellDescriptors // saves changes to the global variable.
    }
}
