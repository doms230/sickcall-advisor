//
//  AdvisorSideBarViewController.swift
//  Sickcall
//
//  Created by Dom Smith on 7/11/17.
//  Copyright © 2017 Socialgroupe Incorporated All rights reserved.
//

import UIKit
import Parse

class AdvisorSideBarViewController: UIViewController {
    @IBOutlet weak var imageJaunt: UIImageView!
    @IBOutlet weak var nameJaunt: UILabel!
    @IBOutlet weak var paymentsButton: UIButton!
    @IBOutlet weak var switchButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        let query = PFQuery(className: "_User")
        query.whereKey("objectId", equalTo: PFUser.current()!.objectId!)
        query.getFirstObjectInBackground {
            (object: PFObject?, error: Error?) -> Void in
            if error == nil || object != nil {
                let imageFile: PFFile = object!["Profile"] as! PFFile
                self.imageJaunt.kf.setImage(with: URL(string: imageFile.url!))
                self.imageJaunt.layer.cornerRadius = 50
                self.imageJaunt.clipsToBounds = true
                
                self.nameJaunt.text = object!["DisplayName"] as? String
                

            }
        }
        
        let adQuery = PFQuery(className: "Advisor")
        adQuery.whereKey("userId", equalTo: PFUser.current()!.objectId!)
        adQuery.getFirstObjectInBackground {
            (object: PFObject?, error: Error?) -> Void in
            if error == nil || object != nil {
                let isActive = object?["isActive"] as! Bool
                
                if !isActive{
                    self.paymentsButton.isHidden = true
                }
                
            } else {
                self.paymentsButton.isHidden = true
            }
        }
        
    }
    
    @IBAction func switchAction(_ sender: UIButton) {
        UserDefaults.standard.set("patient", forKey: "side")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "main") as UIViewController
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func bankInfoAction(_ sender: UIButton) {
                self.performSegue(withIdentifier: "showBankInfo", sender: self)
    }
}
