//
//  FilterViewController.swift
//  YelpHomework
//
//  Created by Franklin Ho on 9/21/14.
//  Copyright (c) 2014 Franklin Ho. All rights reserved.
//

import UIKit

// Protocol for passing filter data back to main ViewController
protocol FilterViewControllerDelegate{
    func didFinishUpdatingFilters(dealFilterEnabled:Bool,distanceFilter:Int, sortByFilter: Int)
}



class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Delegate
    var delegate: FilterViewControllerDelegate?
    
    // Filter values
    var dealFilterEnabled = false
    var distanceFilter = 0
    var sortByFilter = 0
    
    // Array of expanded states for sections
    var isExpanded: [Int:Bool]! = [Int:Bool]()
    


    // Section header names
    var sectionNames = ["Deals","Distance","Sort By","Category"]
    

    // Lists labels and counts of different sections
    var sectionsLabels = [   ["Offering a Deal"],
                            ["Auto", "0.3 miles", "1 miles", "5 miles", "20 miles"],
                            ["Best Match", "Distance", "Rating"]
                        ]
    //Filter defaults
    var dealsFilterSelection = false
    var distanceFilterSelection: Int = 0
    var sortByFilterSelection = 0
    
    
    
    
    @IBOutlet weak var filterNavigationBar: UINavigationBar!
    @IBOutlet weak var filterTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Format navigation bar
        self.view.backgroundColor = UIColor.redColor()
        filterNavigationBar.barTintColor = UIColor.redColor()
        filterNavigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        filterNavigationBar.tintColor = UIColor.whiteColor()
        filterNavigationBar.backgroundColor = UIColor.redColor()
        
        navigationController?.navigationBar.backgroundColor = UIColor.redColor()

        
        // Assign filterTableView delegate
        self.filterTableView.delegate = self
        self.filterTableView.dataSource = self
        

        self.filterTableView.rowHeight = 60
        

        self.filterTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func dismissFilters(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Checks if section is expanded. If it is show all rows. If not, show only top row.
        if let expanded = isExpanded[section] {
            return expanded ? sectionsLabels[section].count : 1
        } else {
            return 1
        }
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        var cellRow: Int!
        
        // Checks section that the cell is in
        if ((indexPath.section) == 0){
            // Deals section uses the standard UI Switch prototype cell
            var cell = tableView.dequeueReusableCellWithIdentifier("SwitchTableViewCell") as SwitchTableViewCell
            cell.filterLabel.text = sectionsLabels[indexPath.section][indexPath.row] as String
            cell.filterSwitch.on = dealFilterEnabled
            return cell
            
        } else if ((indexPath.section) == 1 ){
            // Distance section uses the custom radio button prototype cell
            var cell = tableView.dequeueReusableCellWithIdentifier("RadioTableViewCell") as RadioTableViewCell
            
            // Check expansion. If expanded cells should be normal cells. If collapsed, show the selected value (as indicated by the filter variables). If collapsed show dropdown arrow instead of radio button.
            if isExpanded[indexPath.section] == true {
                cellRow = indexPath.row
                cell.filterButton.hidden = false
                cell.downImage.hidden = true
            } else {
                cellRow = distanceFilter
                cell.filterButton.hidden = true
                cell.downImage.hidden = false
            }
            cell.filterLabel.text = sectionsLabels[indexPath.section][cellRow] as String
            if cellRow == distanceFilter{
                cell.filterButton.selected = true
            } else {
                cell.filterButton.selected = false
            }
            return cell
        } else {
            // Same as distance section.
            var cell = tableView.dequeueReusableCellWithIdentifier("RadioTableViewCell") as RadioTableViewCell
            
            if isExpanded[indexPath.section] == true {
                cellRow = indexPath.row
                cell.filterButton.hidden = false
                cell.downImage.hidden = true
            } else {
                cellRow = sortByFilter
                cell.filterButton.hidden = true
                cell.downImage.hidden = false
            }

            cell.filterLabel.text = sectionsLabels[indexPath.section][cellRow] as String
            
            
            if cellRow == sortByFilter{
                cell.filterButton.selected = true
            } else {
                cell.filterButton.selected = false
            }
            
            
            return cell
        }
        
        
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Names sections.
        return sectionNames[section]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Deal filter section should not expand.
        if ((indexPath.section) == 0){
            // Switch deal filter state
            dealFilterEnabled = !dealFilterEnabled
            
        } else {
            // If other sections are already expanded, set selection to the filter value.
            if  isExpanded[indexPath.section] == true {
                if ((indexPath.section)==1){
                    distanceFilter = indexPath.row
                    
                } else {
                    sortByFilter = indexPath.row
                }
                isExpanded[indexPath.section] = false
            } else {
            //For all other sections, if the section is collapsed, expand it.
                isExpanded[indexPath.section] = true
                
            }
        }
        
        
        println("expanded: \(isExpanded[indexPath.section])")
        
        
        
        // Clear selection after user has made the selection.
        if (filterTableView.indexPathForSelectedRow() != nil){
            filterTableView.deselectRowAtIndexPath(filterTableView.indexPathForSelectedRow()!, animated: true)
        }
        
        // Reload section and animate it with the automatic animation.
        self.filterTableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Automatic)
        
    }
    
    // When search button is pressed, dismiss modal filter view and pass filter values to the main search view controller
    @IBAction func searchButtonPressed(sender: AnyObject) {
        self.delegate?.didFinishUpdatingFilters(self.dealFilterEnabled, distanceFilter: self.distanceFilter, sortByFilter: self.sortByFilter)
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }


}


