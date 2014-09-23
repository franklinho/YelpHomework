//
//  BusinessDetailViewController.swift
//  YelpHomework
//
//  Created by Franklin Ho on 9/22/14.
//  Copyright (c) 2014 Franklin Ho. All rights reserved.
//

import UIKit

class BusinessDetailViewController: UIViewController {
    
    var business : NSDictionary!
    
    @IBOutlet weak var reviewImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var reviewsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Load up display variables from business
        
        var businessName = business["name"] as String
        self.nameLabel.text = businessName
        
        var ratingsImageURL = business["rating_img_url"] as String
        self.reviewImage.setImageWithURL(NSURL(string: ratingsImageURL))
        
        var reviewCount = business["review_count"] as Int
        
        self.reviewsLabel.text = String(reviewCount)+" Reviews" as String
        
        var location = business["location"] as NSDictionary
        
        var address = location["display_address"] as NSArray
        
        var addressString = address[0] as String
        
        var neighborhoodString = ""
        
        if address.count > 1 {
            neighborhoodString = address[1] as String
        }
        
        
        self.addressLabel.text = addressString+", \n"+neighborhoodString as String
        
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
        
        
        self.categoryLabel.text = categoryString
        
        

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

}
