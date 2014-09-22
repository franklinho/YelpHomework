//
//  YelpClient.swift
//  Yelp
//
//  Created by Timothy Lee on 9/19/14.
//  Copyright (c) 2014 Timothy Lee. All rights reserved.
//

import UIKit



class YelpClient: BDBOAuth1RequestOperationManager {
    var accessToken: String!
    var accessSecret: String!
    

    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(consumerKey key: String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
        self.accessToken = accessToken
        self.accessSecret = accessSecret
        var baseUrl = NSURL(string: "http://api.yelp.com/v2/")
        super.init(baseURL: baseUrl, consumerKey: key, consumerSecret: secret);
        
        var token = BDBOAuthToken(token: accessToken, secret: accessSecret, expiration: nil)
        self.requestSerializer.saveAccessToken(token)
    }
    
    func searchWithTerm(term: String, deals:Bool, sortBy:Int, radius:Int, latitude:Double, longitude:Double, success: (AFHTTPRequestOperation!, AnyObject!) -> Void, failure: (AFHTTPRequestOperation!, NSError!) -> Void) -> AFHTTPRequestOperation! {
        // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
        var latLongString = "\(latitude),\(longitude)"
        println("\(latLongString)")
        var dealsValue = deals ? "true":"false"
        var sort = "\(sortBy)"
        
        var parameters = ["term": term, "cll": latLongString, "location": "San Francisco", "deals_filter": dealsValue ]
        
        if radius != 0 {
            var radiusValue: String = ""
            
            switch radius {
            case 1:
                radiusValue = "483"
            case 2:
                radiusValue = "1609"
            case 3:
                radiusValue = "8047"
            case 4:
                radiusValue = "32187"
            default:
                break
                
            }
            
            parameters["radius_filter"] = radiusValue
        }
        
        
        
        
        
        return self.GET("search", parameters: parameters, success: success, failure: failure)
    }
    

    
}


