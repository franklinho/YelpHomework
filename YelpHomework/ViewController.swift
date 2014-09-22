//
//  ViewController.swift
//  YelpHomework
//
//  Created by Franklin Ho on 9/20/14.
//  Copyright (c) 2014 Franklin Ho. All rights reserved.
//

import UIKit
import QuartzCore
import CoreLocation


class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate, FilterViewControllerDelegate, CLLocationManagerDelegate {
    var client: YelpClient!
    var businesses: Array<NSDictionary> = []
    var navSearchBar: UISearchBar = UISearchBar()
    
    var latitude : Double = 37.77492
    var longitude : Double = -122.41941
    var locationManager: CLLocationManager!
    var location: CLLocation!
    
    
    let yelpConsumerKey = "lrryv0uzk-ilfSBVWFuubA"
    let yelpConsumerSecret = "9OJltaQhaUOCP4qu4ishFLqnHtQ"
    let yelpToken = "62lfsuEcNmLSjXYpjfOEPyHvC8kn_uhZ"
    let yelpTokenSecret = "B18rkkGe7Ds79wH29qQpSC5u-ZU"
    
    
    var dealFilterEnabled = false
    var distanceFilter = 0
    var sortByFilter = 0
    
    @IBOutlet weak var searchTableView: UITableView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        
        navigationController?.navigationBar.barTintColor = UIColor.redColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.backgroundColor = UIColor.redColor()
        
        
        self.navigationItem.titleView = self.navSearchBar
        self.navSearchBar.delegate = self
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        locationManager = CLLocationManager()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        self.requestBusinesses(self)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("numberOfRows: \(self.businesses.count)")
        return self.businesses.count


    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("SearchTableViewCell") as SearchTableViewCell
        
        var business = self.businesses[indexPath.row]
        
        
        var indexString = String(indexPath.row+1) as String
        var businessName = business["name"] as String
        cell.nameLabel.text = indexString+". "+businessName
        
        var businessImageURL = business["image_url"] as String
        var ratingsImageURL = business["rating_img_url"] as String
        
        cell.ratingImage.setImageWithURL(NSURL(string: ratingsImageURL))
        cell.businessImage.setImageWithURL(NSURL(string: businessImageURL))
        cell.businessImage.layer.cornerRadius = 10
        cell.businessImage.clipsToBounds = true

        
        var reviewCount = business["review_count"] as Int
        
        cell.reviewsLabel.text = String(reviewCount)+" Reviews" as String
        
        var location = business["location"] as NSDictionary
        
        var address = location["display_address"] as NSArray

        var addressString = address[0] as String
        
        var neighborhoodString = ""
        
        if address.count > 1 {
            neighborhoodString = address[1] as String
        }
        
        
        cell.addressLabel.text = addressString+", \n"+neighborhoodString as String
        
        var categories = business["categories"] as NSArray
        var categoryString : String = ""
        
        for var index = 0; index < categories.count; index++ {
            var currentString = String(categories[index][0] as NSString)
            if index==0{
                categoryString = categoryString+currentString as String
            } else {
                categoryString = categoryString+", "+currentString as String
            }
        }
        
        if (business["distance"] != nil) {
            var distanceString = business["distance"] as String
            cell.distanceLabel.text = distanceString
        } else {
            cell.distanceLabel.text = ""
        }
        
        cell.categoriesLabel.text = categoryString
        
        
        
        return cell
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.searchTableView.reloadData()
    }
    
    func requestBusinesses(sender:AnyObject){
        
        
        client = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        
        println("Current Coordinates: \(self.latitude),\(self.longitude)")
        client.searchWithTerm(self.navSearchBar.text, deals:dealFilterEnabled, sortBy:sortByFilter, radius:distanceFilter, latitude: self.latitude, longitude: self.longitude, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            
            //            println(response.description)
            var responseDict = response as NSDictionary
            self.businesses = responseDict["businesses"] as Array<NSDictionary>
            println("View Did Load Biz Count:\(self.businesses.count)")
            println("\(self.businesses)")
            
            self.searchTableView.rowHeight = UITableViewAutomaticDimension
            //            self.searchTableView.rowHeight = 101
            
            
            self.searchTableView.reloadData()
            
            
            
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println(error)
        }
    }
    
    // Trigger search using searchBar text
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        println("Search button pressed")
        self.requestBusinesses(self)
//        self.view.endEditing(true)        
        self.navSearchBar.endEditing(true)

    }

        // Allows search bar to search on empty strings
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        var navSearchBarTextField : UITextField = UITextField()
        for subview in navSearchBar.subviews {
            for secondLevelSubView in subview.subviews{
                if secondLevelSubView.isKindOfClass(UITextField){
                    navSearchBarTextField = secondLevelSubView as UITextField
                    break
                }
            }
        }
        navSearchBarTextField.enablesReturnKeyAutomatically = false
    }
    
    // dismisses keyboard when you click cancel
    func searchBarCancelButtonClicked(searchBar: UISearchBar){
        navSearchBar.text = ""
        self.navSearchBar.endEditing(true)
    }
    
    // dismisses keyboard when you leave the page
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.navSearchBar.endEditing(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("\(segue.identifier)")
        if (segue.identifier == "showFilterSegue") {
            var filterViewController : FilterViewController = segue.destinationViewController as FilterViewController
            filterViewController.dealFilterEnabled = self.dealFilterEnabled
            filterViewController.distanceFilter = self.distanceFilter
            filterViewController.sortByFilter = self.sortByFilter
            var distanceFilter = 0
            filterViewController.delegate = self
        }
    }
    
    func didFinishUpdatingFilters(dealFilterEnabled: Bool, distanceFilter: Int, sortByFilter: Int) {
        self.dealFilterEnabled = dealFilterEnabled
        self.distanceFilter = distanceFilter
        self.sortByFilter = sortByFilter
        
        self.requestBusinesses(self)
        self.searchTableView.reloadData()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        self.latitude = newLocation.coordinate.latitude
        self.longitude = newLocation.coordinate.longitude
    }
    
}

