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


class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate {
    var client: YelpClient!
    var businesses: Array<NSDictionary> = []
    var navSearchBar: UISearchBar = UISearchBar()
    var locationManager: CLLocationManager!
    var location: CLLocation!
    
    
    let yelpConsumerKey = "lrryv0uzk-ilfSBVWFuubA"
    let yelpConsumerSecret = "9OJltaQhaUOCP4qu4ishFLqnHtQ"
    let yelpToken = "62lfsuEcNmLSjXYpjfOEPyHvC8kn_uhZ"
    let yelpTokenSecret = "B18rkkGe7Ds79wH29qQpSC5u-ZU"
    
    @IBOutlet weak var searchTableView: UITableView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        self.navigationItem.titleView = self.navSearchBar
        self.navSearchBar.delegate = self
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        locationManager = CLLocationManager()

        
        
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
        var neighborhoodString = address[1] as String
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
        self.searchTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func requestBusinesses(sender:AnyObject){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.startUpdatingLocation()
        
        client = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        
        client.searchWithTerm(self.navSearchBar.text, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            
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
        self.view.endEditing(true)
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
        self.view.endEditing(true)
    }
    
    // dismisses keyboard when you leave the page
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.view.endEditing(true)
    }
    



    
}

