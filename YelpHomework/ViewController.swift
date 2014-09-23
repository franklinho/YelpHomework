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
    var businesses: NSMutableArray = []
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
    
    var currentOffset = 0
    
    var refreshControl : UIRefreshControl!
    
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
        
        // Add pull to refresh to the tableview
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "requestBusinesses:offset:", forControlEvents: UIControlEvents.ValueChanged)

        self.searchTableView.addSubview(refreshControl)
        
        self.currentOffset = 0
        self.businesses.removeAllObjects()
        self.requestBusinesses(self,offset: currentOffset)
        
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
        
        
        
        if indexPath.row == searchTableView.numberOfRowsInSection(0)-1 {
            var cell = tableView.dequeueReusableCellWithIdentifier("SpinnerCell") as UITableViewCell
            return cell
        } else {
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
            
            
            cell.categoriesLabel.text = categoryString
            return cell
            
            
        }
    
        
        
        
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.searchTableView.reloadData()
    }
    
    func requestBusinesses(sender:AnyObject, offset: Int){
        
        
        client = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        
        println("Current Coordinates: \(self.latitude),\(self.longitude)")
        client.searchWithTerm(self.navSearchBar.text, deals:dealFilterEnabled, sortBy:sortByFilter, radius:distanceFilter, latitude: self.latitude, longitude: self.longitude, offset: offset, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            
            //            println(response.description)
            var responseDict = response as NSDictionary
            var businessesArray = responseDict["businesses"] as Array<NSDictionary>
            self.businesses.addObjectsFromArray(businessesArray)
            println("View Did Load Biz Count:\(self.businesses.count)")
            println("\(self.businesses)")
            
            self.searchTableView.rowHeight = UITableViewAutomaticDimension
            //            self.searchTableView.rowHeight = 101
            
            
            self.searchTableView.reloadData()
            self.refreshControl.endRefreshing()
            
            
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println(error)
        }
    }
    
    // Trigger search using searchBar text
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        println("Search button pressed")
        self.currentOffset = 0
        self.businesses.removeAllObjects()
        self.requestBusinesses(self,offset: currentOffset)
        
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

        if (segue.identifier == "showFilterSegue") {
            var filterViewController : FilterViewController = segue.destinationViewController as FilterViewController
            filterViewController.dealFilterEnabled = self.dealFilterEnabled
            filterViewController.distanceFilter = self.distanceFilter
            filterViewController.sortByFilter = self.sortByFilter
            var distanceFilter = 0
            filterViewController.delegate = self
        } else if (segue.identifier == "MapViewSegue"){
            var mapViewController:MapViewController = segue.destinationViewController as MapViewController
            mapViewController.businesses = self.businesses
            mapViewController.latitude = self.latitude
            mapViewController.longitude = self.longitude
        } else if (segue.identifier == "BusinessDetailSegue"){
            var businessDetailController: BusinessDetailViewController = segue.destinationViewController as BusinessDetailViewController
            var businessIndex = searchTableView!.indexPathForSelectedRow()?.row
            var selectedBusiness = self.businesses[businessIndex!]
            businessDetailController.business = selectedBusiness as NSDictionary
        }
    }
    
    func didFinishUpdatingFilters(dealFilterEnabled: Bool, distanceFilter: Int, sortByFilter: Int) {
        self.dealFilterEnabled = dealFilterEnabled
        self.distanceFilter = distanceFilter
        self.sortByFilter = sortByFilter
        
        self.currentOffset = 0
        self.businesses.removeAllObjects()
        self.requestBusinesses(self, offset: currentOffset)
        self.searchTableView.reloadData()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        self.latitude = newLocation.coordinate.latitude
        self.longitude = newLocation.coordinate.longitude
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        currentOffset += self.businesses.count
        
        
        
        var actualPosition :CGFloat = scrollView.contentOffset.y
        var contentHeight : CGFloat = scrollView.contentSize.height - 550
        
        println("Actual Position: \(actualPosition), Content Height: \(contentHeight)")
        if (actualPosition >= contentHeight) {
            requestBusinesses(self, offset: currentOffset)
            self.searchTableView.reloadData()
        }
        
    }
    
    
}

