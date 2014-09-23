//
//  MapViewController.swift
//  YelpHomework
//
//  Created by Franklin Ho on 9/21/14.
//  Copyright (c) 2014 Franklin Ho. All rights reserved.
//

import UIKit

class BusinessMarker: GMSMarker {
    var location :  NSDictionary!
    
    var coordinate : NSDictionary!
    var latitude : Double!
    var longitude : Double!
}

class MapViewController: UIViewController {
    var latitude : Double!
    var longitude : Double!
    var businesses: NSMutableArray = []
    var navSearchBar: UISearchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.titleView = self.navSearchBar
        
        println("\(latitude),\(longitude)")
        
        // Create camera position for Google Map View centered on user location
        var camera : GMSCameraPosition = GMSCameraPosition(target: CLLocationCoordinate2DMake(latitude, longitude), zoom: 11, bearing: CLLocationDirection.abs(0), viewingAngle: 0)
        
        // Create google Map View
        var mapView : GMSMapView = GMSMapView(frame: CGRectZero)
        mapView.camera = camera
        
        
        // Creates a marker on Google map for each business with appropriate location
        for var index = 0; index < businesses.count; ++index{
            var businessMarker : BusinessMarker = BusinessMarker()
            var business = self.businesses[index]

            businessMarker.location = business["location"]  as NSDictionary
            
            if businessMarker.location["coordinate"] != nil {
                businessMarker.coordinate = businessMarker.location["coordinate"]  as NSDictionary
                businessMarker.latitude = businessMarker.coordinate["latitude"] as Double
                businessMarker.longitude = businessMarker.coordinate["longitude"] as Double
                businessMarker.snippet = business["name"] as String
                businessMarker.position = CLLocationCoordinate2DMake(businessMarker.latitude, businessMarker.longitude)
                businessMarker.map = mapView
            }
            
            
            
        }
        
        // Return Google Map View
        self.view = mapView
        
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
    
    // Returns to list view
    @IBAction func listButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
