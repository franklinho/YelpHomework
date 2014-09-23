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
        
        var camera : GMSCameraPosition = GMSCameraPosition(target: CLLocationCoordinate2DMake(latitude, longitude), zoom: 11, bearing: CLLocationDirection.abs(0), viewingAngle: 0)
        var mapView : GMSMapView = GMSMapView(frame: CGRectZero)
        mapView.camera = camera
        
        
        
//        var marker : GMSMarker = GMSMarker()
//        marker.position = camera.target
//        marker.snippet = "Hello World"
//        marker.appearAnimation = kGMSMarkerAnimationPop
//        marker.map = mapView;
        
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
    

    @IBAction func listButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
