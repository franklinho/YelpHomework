//
//  FilterViewController.swift
//  YelpHomework
//
//  Created by Franklin Ho on 9/21/14.
//  Copyright (c) 2014 Franklin Ho. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    


    var sectionNames = ["Deals","Distance","Sort By","Category"]
    

    
    var sectionsLabels = [   ["Offering a Deal"],
                            ["Auto", "0.3", "1", "5", "20"],
                            ["Best Match", "Distance", "Rating", "Most Reviews"]
                        ]
    //Filter defaults
    var dealsFilterSelection = false
    var distanceFilterSelection: Int = 0
    var sortByFilterSelection = 0
    
    
    
    @IBOutlet weak var filterTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.filterTableView.delegate = self
        self.filterTableView.dataSource = self
        

        

        
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
        return sectionsLabels[section].count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        

        
        if ((indexPath.section) == 0){
            var cell = tableView.dequeueReusableCellWithIdentifier("SwitchTableViewCell") as SwitchTableViewCell
            cell.filterLabel.text = sectionsLabels[indexPath.section][indexPath.row] as String
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("RadioTableViewCell") as RadioTableViewCell
            cell.filterLabel.text = sectionsLabels[indexPath.section][indexPath.row] as String
            return cell
        }
        
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }
    
}
