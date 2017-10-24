//
//  AdvisorContainerViewController.swift
//  Sickcall
//
//  Created by Dom Smith on 7/11/17.
//  Copyright © 2017 Socialgroupe Incorporated All rights reserved.
//

import UIKit
import SidebarOverlay
import Parse
import NVActivityIndicatorView

class AdvisorContainerViewController: SOContainerViewController,NVActivityIndicatorViewable {

    var isAdvisor = false
    var segueQuestion = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NVActivityIndicatorView.DEFAULT_TYPE = .ballScaleMultiple
        NVActivityIndicatorView.DEFAULT_COLOR = uicolorFromHex(0x006a52)
        NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE = CGSize(width: 60, height: 60)
        NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        startAnimating()
        
        self.menuSide = .left
        
        if isAdvisor{
            let query = PFQuery(className: "Post")
            query.whereKey("advisorUserId", equalTo: PFUser.current()!.objectId!)
            query.whereKey("isAnswered", equalTo: false)
            query.whereKey("isRemoved", equalTo: false)
            query.addAscendingOrder("createdAt")
            query.getFirstObjectInBackground {
                (object: PFObject?, error: Error?) -> Void in
                self.stopAnimating()
                
                if error != nil{
                    self.topViewController = self.storyboard?.instantiateViewController(withIdentifier: "dashboard")
                    
                } else {
                    self.segueQuestion = true 
                    
                    //doing this roundabout way to send advisor's connect id to view controller 
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "question") 
                    self.topViewController = controller
                    
                }
                
                self.sideViewController = self.storyboard?.instantiateViewController(withIdentifier: "sidebar")
            }
            
        } else {
            self.stopAnimating()
            self.topViewController = self.storyboard?.instantiateViewController(withIdentifier: "new")
            self.sideViewController = self.storyboard?.instantiateViewController(withIdentifier: "sidebar")
        }
    }
    
    func uicolorFromHex(_ rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
}
