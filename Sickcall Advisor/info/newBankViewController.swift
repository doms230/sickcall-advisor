//
//  newBankViewController.swift
//  Sickcall
//
//  Created by Dominic Smith on 10/17/17.
//  Copyright © 2017 Sickcall LLC. All rights reserved.
//

import UIKit
import Parse
import Alamofire
import SwiftyJSON
import SnapKit
import NVActivityIndicatorView
import SCLAlertView

class newBankViewController: UIViewController, NVActivityIndicatorViewable {
    
    lazy var accountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 17)
        label.text = "Account Number"
        label.textColor = UIColor.black
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    lazy var bAccountText: UITextField = {
        let label = UITextField()
        label.placeholder = "Account Number"
        label.backgroundColor = .white
        label.font = UIFont(name: "HelveticaNeue", size: 17)
        label.clearButtonMode = .whileEditing
        label.borderStyle = .roundedRect
        label.keyboardType = .numberPad
        return label
    }()
    
    lazy var routingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 17)
        label.text = "Routing Number"
        label.textColor = UIColor.black
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    lazy var bRoutingtext: UITextField = {
        let label = UITextField()
        label.placeholder = "Routing Number"
        label.backgroundColor = .white
        label.font = UIFont(name: "HelveticaNeue", size: 17)
        label.clearButtonMode = .whileEditing
        label.borderStyle = .roundedRect
        label.keyboardType = .numberPad
        return label
    }()
    
    var connectId: String!
    var first_name: String!
    var last_name: String!
    var dobDay: Int!
    var dobMonth: Int!
    var dobYear: Int!
    var email: String!

    //bank
    var routing: String!
    var account: String!
    var bankName: String!
    var accountLast4: String!
    
    //personal
    var personal_id_number: String!
    
    //address
    var line1: String!
    var line2: String!
    var city: String!
    var zipCode: String!
    var state: String!
    
    var successView: SCLAlertView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Bank Info 3/3"
        let nextButton = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(doneAction(_:)))
        self.navigationItem.setRightBarButton(nextButton, animated: true)
        
        configureBank()
        
        NVActivityIndicatorView.DEFAULT_TYPE = .ballScaleMultiple
        NVActivityIndicatorView.DEFAULT_COLOR = uicolorFromHex(0x159373)
        NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE = CGSize(width: 60, height: 60)
        NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        // Do any additional setup after loading the view.
        
        let userId = PFUser.current()?.objectId
        let query = PFQuery(className: "Advisor")
        query.whereKey("userId", equalTo: userId!)
        query.getFirstObjectInBackground {
            (object: PFObject?, error: Error?) -> Void in
            if error == nil || object != nil {
                
                self.first_name = object!["first"] as! String
                self.last_name = object!["last"] as! String
                self.dobMonth = Int(object!["birthdaymonth"] as! String)
                self.dobDay = Int(object!["birthdayday"] as! String)
                self.dobYear = Int(object!["birthdayyear"] as! String)
                
            } else{
                //you're not connected to the internet message
            }
        }
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false
        )
        
        successView = SCLAlertView(appearance: appearance)
        successView.addButton("Okay") {
            let storyboard = UIStoryboard(name: "Advisor", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "container") as! AdvisorContainerViewController
            controller.isAdvisor = true
            self.present(controller, animated: true, completion: nil)
        }
        
    }
    
    @objc func doneAction(_ sender: UIBarButtonItem){
        startAnimating()
        bAccountText.resignFirstResponder()
        bRoutingtext.resignFirstResponder()
        postNewAccount()
    }
    
    func postNewAccount(){
        //class won't compile with textfield straight in parameters so has to be put to string first
        let last4 = String(personal_id_number.suffix(4))
        let email = PFUser.current()!.email!
        let routing = bRoutingtext.text!
        let account = bAccountText.text!
        
        let p: Parameters = [
            "email": email ,
            "ssn_last_4": last4,
            "personal_id_number": personal_id_number,
            "city": city,
            "line1": line1,
            "line2": line2,
            "postal_code": zipCode,
            "state": state,
            "day": dobDay,
            "month": dobMonth,
            "year": dobYear,
            "first_name": first_name,
            "last_name": last_name,
            "account_number": account,
            "routing_number": routing
            ]
        let url = "https://celecare.herokuapp.com/payments/newAccount"
        Alamofire.request(url, method: .post, parameters: p, encoding: URLEncoding.default).validate().responseJSON { response in switch response.result {
        case .success(let data):
            let json = JSON(data)
            print("JSON: \(json)")
            self.stopAnimating()
            
            if let status = json["statusCode"].int{
                print(status)
                let message = json["message"].string
                SCLAlertView().showError("Something Went Wrong", subTitle: message!)
                
            } else {
                self.bankName = json["external_accounts"]["data"][0]["bank_name"].string
                self.accountLast4 = json["external_accounts"]["data"][0]["last4"].string
                self.connectId = json["id"].string
                self.saveConnectId()
            }
            
        case .failure(let error):
            self.stopAnimating()
            print(error)
            SCLAlertView().showError("Something Went Wrong", subTitle: error as! String)
            
            }
        }
    }
    
    func saveConnectId(){
        let userId = PFUser.current()?.objectId
        let query = PFQuery(className: "Advisor")
        query.whereKey("userId", equalTo: userId!)
        query.getFirstObjectInBackground {
            (object: PFObject?, error: Error?) -> Void in
            if error == nil || object != nil {
                
                object?["connectId"]  = self.connectId
                object?.saveEventually {
                    (success: Bool, error: Error?) -> Void in
                    if (success) {
                        self.successView.showSuccess("Account Updated!", subTitle: "Your funds will be deposited to \(self.bankName!) ****\(self.accountLast4!) from now on.")
                    }
                }
            } else{
                //you're not connected to the internet message
            }
        }
    }
    
    func configureBank(){
        self.view.addSubview(accountLabel)
        self.view.addSubview(bAccountText)
        self.view.addSubview(routingLabel)
        self.view.addSubview(bRoutingtext)
        
        accountLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(75)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
        }
        
        bAccountText.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(accountLabel.snp.bottom).offset(5)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
        }
        
        routingLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(bAccountText.snp.bottom).offset(10)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
        }
        
        bRoutingtext.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(routingLabel.snp.bottom).offset(5)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
            //make.bottom.equalTo(self.view).offset(-20)
        }
    }
    
    //mich.
    func uicolorFromHex(_ rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
}
