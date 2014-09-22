//
//  FilterViewController.swift
//  YelpHomework
//
//  Created by Franklin Ho on 9/21/14.
//  Copyright (c) 2014 Franklin Ho. All rights reserved.
//

import UIKit





class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var dealFilterEnabled = false
    var distanceFilter = 0
    var sortByFilter = 0
    
    var isExpanded: [Int:Bool]! = [Int:Bool]()
    
    var delegate: FilterViewControllerDelegate?


    var sectionNames = ["Deals","Distance","Sort By","Category"]
    

    
    var sectionsLabels = [   ["Offering a Deal"],
                            ["Auto", "0.3 miles", "1 miles", "5 miles", "20 miles"],
                            ["Best Match", "Distance", "Rating", "Most Reviews"]
                        ]
    //Filter defaults
    var dealsFilterSelection = false
    var distanceFilterSelection: Int = 0
    var sortByFilterSelection = 0
    
    
    @IBOutlet weak var filterNavigationBar: UINavigationBar!
    

    @IBOutlet weak var filterTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.redColor()
        
        // Do any additional setup after loading the view.
        

        
        filterNavigationBar.barTintColor = UIColor.redColor()
        filterNavigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        filterNavigationBar.tintColor = UIColor.whiteColor()
        filterNavigationBar.backgroundColor = UIColor.redColor()
        
        navigationController?.navigationBar.backgroundColor = UIColor.redColor()

        
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
        
        
        
        if ((indexPath.section) == 0){
            var cell = tableView.dequeueReusableCellWithIdentifier("SwitchTableViewCell") as SwitchTableViewCell
            cell.filterLabel.text = sectionsLabels[indexPath.section][indexPath.row] as String
            cell.filterSwitch.on = dealFilterEnabled
            return cell
            
        } else if ((indexPath.section) == 1 ){
            var cell = tableView.dequeueReusableCellWithIdentifier("RadioTableViewCell") as RadioTableViewCell
            
            
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
        return sectionNames[section]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if ((indexPath.section) == 0){
            dealFilterEnabled = !dealFilterEnabled
            
        } else {
            if  isExpanded[indexPath.section] == true {
                if ((indexPath.section)==1){
                    distanceFilter = indexPath.row
                    
                } else {
                    sortByFilter = indexPath.row
                }
                isExpanded[indexPath.section] = false
            } else {
                isExpanded[indexPath.section] = true
                
            }
        }
        
        
        println("expanded: \(isExpanded[indexPath.section])")
        
        
        
        
        if (filterTableView.indexPathForSelectedRow() != nil){
            filterTableView.deselectRowAtIndexPath(filterTableView.indexPathForSelectedRow()!, animated: true)
        }
        
        self.filterTableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Automatic)
        
    }
    

    @IBAction func searchButtonPressed(sender: AnyObject) {
        self.delegate?.didFinishUpdatingFilters(self.dealFilterEnabled, distanceFilter: self.distanceFilter, sortByFilter: self.sortByFilter)
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }


}

protocol FilterViewControllerDelegate{
    func didFinishUpdatingFilters(dealFilterEnabled:Bool,distanceFilter:Int, sortByFilter: Int)
}

