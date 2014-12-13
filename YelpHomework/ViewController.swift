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
    
    // Location Parameters
    var latitude : Double = 37.77492
    var longitude : Double = -122.41941
    var locationManager: CLLocationManager!
    var location: CLLocation!
    
    
    // Yelp API Credentials
    let yelpConsumerKey = "lrryv0uzk-ilfSBVWFuubA"
    let yelpConsumerSecret = "9OJltaQhaUOCP4qu4ishFLqnHtQ"
    let yelpToken = "62lfsuEcNmLSjXYpjfOEPyHvC8kn_uhZ"
    let yelpTokenSecret = "B18rkkGe7Ds79wH29qQpSC5u-ZU"
    
    // Filter Variables
    var dealFilterEnabled = false
    var distanceFilter = 0
    var sortByFilter = 0
    
    // Indicates offset for infinite scrolling
    var currentOffset = 0
    
    // Pull to refresh
    var refreshControl : UIRefreshControl!
    
    @IBOutlet weak var searchTableView: UITableView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        // Customize Navigation bar
        navigationController?.navigationBar.barTintColor = UIColor.redColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.backgroundColor = UIColor.redColor()
        
        
        self.navigationItem.titleView = self.navSearchBar
        self.navSearchBar.delegate = self
        
        //Set Tableview Delegate
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        
        // Set up location passing (lat/long)
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
        
        // Call for businesses
        self.currentOffset = 0
        self.requestBusinesses(self,offset: currentOffset)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("numberOfRows: \(self.businesses.count)")
        // Returns number of businesses + spinner loading cell for infinite scroll
        return self.businesses.count+1


    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Checks if last cell in tableView. Makes that cell the spinner cell. All other cells are normal tableview cells.
        
        if indexPath.row == searchTableView.numberOfRowsInSection(0)-1 {
            var cell = tableView.dequeueReusableCellWithIdentifier("SpinnerCell") as UITableViewCell
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("SearchTableViewCell") as SearchTableViewCell
            
            // Pulls in individual business
            var business = self.businesses[indexPath.row]
            
            
            var indexString = String(indexPath.row+1) as String
            var businessName = business["name"] as String
            cell.nameLabel.text = indexString+". "+businessName
            
            var businessImageURL = business["image_url"] as String
            var ratingsImageURL = business["rating_img_url"] as String
            
            cell.ratingImage.alpha = 0
            cell.businessImage.alpha = 0
            
            // Async load image
            cell.ratingImage.setImageWithURL(NSURL(string: ratingsImageURL))
            cell.businessImage.setImageWithURL(NSURL(string: businessImageURL))
            cell.businessImage.layer.cornerRadius = 10
            cell.businessImage.clipsToBounds = true
            
            
            // Fade in images
            UIView.animateWithDuration(0.5,
                delay: 0.0,
                options: nil,
                animations: {
                    cell.ratingImage.alpha = 1.0
                    cell.businessImage.alpha = 1.0
                },
                completion: {
                    finished in
            })
            
            
            var reviewCount = business["review_count"] as Int
            
            cell.reviewsLabel.text = String(reviewCount)+" Reviews" as String
            
            var location = business["location"] as NSDictionary
            
            var address = location["display_address"] as NSArray
            
            var addressString = address[0] as String
            
            var neighborhoodString = ""
            
            // Checks if there is a neighborhood
            if address.count > 1 {
                neighborhoodString = address[1] as String
            }
            
            
            cell.addressLabel.text = addressString+", \n"+neighborhoodString as String
            
            // Creates category string from categories array
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
            
            // return cell
            return cell
            
            
        }
    
        
        
        
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        // Makes autolayout set up the height for recycled cells correctly
        self.searchTableView.reloadData()
    }
    
    func requestBusinesses(sender:AnyObject, offset: Int){
        
        // Create request using client keys
        client = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        
        println("Current Coordinates: \(self.latitude),\(self.longitude)")
        
        // Pass in request with all current deal filters
        client.searchWithTerm(self.navSearchBar.text, deals:dealFilterEnabled, sortBy:sortByFilter, radius:distanceFilter, latitude: self.latitude, longitude: self.longitude, offset: offset, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            
            //            println(response.description)
            var responseDict = response as NSDictionary
            
            // If the offset is set to 0, then only pull the initial set of objects.
            if offset == 0 {
                self.businesses.removeAllObjects()
            }
            
            // All all items from request to businesses array
            var businessesArray = responseDict["businesses"] as Array<NSDictionary>
            self.businesses.addObjectsFromArray(businessesArray)
            println("View Did Load Biz Count:\(self.businesses.count)")
            println("\(self.businesses)")
            
            // Set dynamic row height using autolayout
            self.searchTableView.rowHeight = UITableViewAutomaticDimension
            //            self.searchTableView.rowHeight = 101
            
            
            // Refresh tableview
            self.searchTableView.reloadData()
            
            // Stop pull to refresh if that occurred
            self.refreshControl.endRefreshing()
            
            
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println(error)
        }
    }
    
    // Trigger search using searchBar text
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        println("Search button pressed")
        self.currentOffset = 0
        self.requestBusinesses(self,offset: currentOffset)
        
        // Dismiss keyboard
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
        
        // Passes filter data from ViewController to FilterViewController
        if (segue.identifier == "showFilterSegue") {
            var filterViewController : FilterViewController = segue.destinationViewController as FilterViewController
            filterViewController.dealFilterEnabled = self.dealFilterEnabled
            filterViewController.distanceFilter = self.distanceFilter
            filterViewController.sortByFilter = self.sortByFilter
            var distanceFilter = 0
            filterViewController.delegate = self
        //Passes list of businesses and locations to MapViewController
        } else if (segue.identifier == "MapViewSegue"){
            var mapViewController:MapViewController = segue.destinationViewController as MapViewController
            mapViewController.businesses = self.businesses
            mapViewController.latitude = self.latitude
            mapViewController.longitude = self.longitude
        // Passes data from tapped cell to BusinessDetailViewController
        } else if (segue.identifier == "BusinessDetailSegue"){
            var businessDetailController: BusinessDetailViewController = segue.destinationViewController as BusinessDetailViewController
            var businessIndex = searchTableView!.indexPathForSelectedRow()?.row
            var selectedBusiness = self.businesses[businessIndex!] as NSDictionary
            businessDetailController.business = selectedBusiness as NSDictionary
        }
    }
    
    // When search button on filters view is pressed, send data to ViewController and update filter values.
    func didFinishUpdatingFilters(dealFilterEnabled: Bool, distanceFilter: Int, sortByFilter: Int) {
        self.dealFilterEnabled = dealFilterEnabled
        self.distanceFilter = distanceFilter
        self.sortByFilter = sortByFilter
        
        self.currentOffset = 0
        self.requestBusinesses(self, offset: currentOffset)
        self.searchTableView.reloadData()
    }
    
    // Received location and updating current location coordinates
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        self.latitude = newLocation.coordinate.latitude
        self.longitude = newLocation.coordinate.longitude
    }
    
    
    // Implements scrolling. Checks if current position of tableview is at the contentHeight position. If so, add businesses to tableView.
    func scrollViewDidScroll(scrollView: UIScrollView) {
        currentOffset = self.businesses.count
        
        var actualPosition :CGFloat = scrollView.contentOffset.y
        var contentHeight : CGFloat = scrollView.contentSize.height - 550
        
        println("Actual Position: \(actualPosition), Content Height: \(contentHeight)")
        if (actualPosition >= contentHeight) {
            requestBusinesses(self, offset: currentOffset)
            self.searchTableView.reloadData()
        }
        
    }
    
    
}

