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
    
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var reviewsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var businessName = business["name"] as String
        self.nameLabel.text = businessName
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
