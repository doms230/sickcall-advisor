//
//  BankTableViewController.swift
//  Sickcall
//
//  Created by Dominic Smith on 7/26/17.
//  Copyright © 2017 Sickcall LLC All rights reserved.
//

//get bank info and post it above

import UIKit
import Parse
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import SCLAlertView

class BankTableViewController: UITableViewController, NVActivityIndicatorViewable {
    
    let color = Color()
    
    //payments
    var baseURL = "https://celecare.herokuapp.com/payments/bank"

    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var routingTextField: UITextField!
    var connectId: String!
    
    var successView: SCLAlertView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        NVActivityIndicatorView.DEFAULT_TYPE = .ballScaleMultiple
        NVActivityIndicatorView.DEFAULT_COLOR = color.newColor(0x159373)
        NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE = CGSize(width: 60, height: 60)
        NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        self.title = "Bank Info"
        let nextButton = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(nextAction(_:)))
        self.navigationItem.setRightBarButton(nextButton, animated: true)
        nextButton.tag = 0
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(nextAction(_:)))
        self.navigationItem.setLeftBarButton(cancelButton, animated: true)
        cancelButton.tag = 1
        
        startAnimating()
        let query = PFQuery(className: "Advisor")
        query.whereKey("userId", equalTo: PFUser.current()!.objectId!)
        query.getFirstObjectInBackground {
            (object: PFObject?, error: Error?) -> Void in
            if error == nil || object != nil {
                self.connectId = object!["connectId"] as! String
                self.getAccountInfo()
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
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "main")
            self.present(controller, animated: true, completion: nil)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    @objc func nextAction(_ sender: UIBarButtonItem){
        //loading view
        if sender.tag == 0{
            accountTextField.resignFirstResponder()
            routingTextField.resignFirstResponder()
            startAnimating()
            
            //class won't compile with textfield straight in parameters so has to be put to string first
            let accountString =  accountTextField.text!
            let routingString = routingTextField.text!
            
            let p: Parameters = [
                "account_Id": connectId,
                "account_number": accountString,
                "routing_number": routingString
            ]
            
            Alamofire.request(self.baseURL, method: .post, parameters: p, encoding: JSONEncoding.default).validate().responseJSON { response in switch response.result {
            case .success(let data):
                let json = JSON(data)
                print("JSON: \(json)")
                
                //can't get status code for some reason
                self.stopAnimating()
                if let status = json["statusCode"].int{
                    print(status)
                    let message = json["message"].string
                    
                    SCLAlertView().showError("Something Went Wrong", subTitle: message!)
                    
                } else {
                    let bankName = json["external_accounts"]["data"][0]["bank_name"].string
                    let bankLast4 = json["external_accounts"]["data"][0]["last4"].string
                    self.successView.showSuccess("Success", subTitle: "Your funds will be deposited to \(String(describing: bankName!)) ****\(String(describing: bankLast4!)) from now on.")
                }
                print("Validation Successful")
                
            case .failure(let error):
                print(error)
                SCLAlertView().showError("Error", subTitle: error as! String)
                }
            }
            
        } else {
            //cancel
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "main")
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func getAccountInfo(){
        //class won't compile with textfield straight in parameters so has to be put to string first
        let p: Parameters = [
            "account_Id": connectId,
            ]
        let url = "https://celecare.herokuapp.com/payments/account"
        Alamofire.request(url, parameters: p, encoding: URLEncoding.default).validate().responseJSON { response in switch response.result {
        case .success(let data):
            let json = JSON(data)
            print("JSON: \(json)")
            self.stopAnimating()
            
            if let status = json["statusCode"].int{
                print(status)
                let message = json["message"].string
                SCLAlertView().showError("Something Went Wrong", subTitle: message!)
                
            } else if let last4 = json["external_accounts"]["data"][0]["last4"].string{
                self.accountTextField.text = "****\(last4)"
                self.routingTextField.text = json["external_accounts"]["data"][0]["routing_number"].string
            }
            
        case .failure(let error):
            self.stopAnimating()
            print(error)
            SCLAlertView().showError("Something Went Wrong", subTitle: "")
            
            }
        }
    }
}
