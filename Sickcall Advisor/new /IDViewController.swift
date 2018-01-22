//
//  IDViewController.swift
//  Sickcall Advisor
//
//  Created by Dominic Smith on 10/23/17.
//  Copyright © 2017 Sickcall LLC. All rights reserved.
//

import UIKit
import Parse
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import SCLAlertView
import SnapKit

class IDViewController: UIViewController, NVActivityIndicatorViewable {
    
    //Name Values from QualificationsViewController
    var firstName: String!
    var lastName: String!
    var licenseNumber: String!
    var state: String!
    
    var successView: SCLAlertView!
    
    var birthdayMonth: Int!
    var birthdayDay: Int!
    var birthdayYear: Int!
    
    var didSelectBirthday = false
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
        label.text = "ID Verification"
        label.textColor = UIColor.black
        label.numberOfLines = 0
        return label
    }()
    
    lazy var birthdayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 20)
        label.text = "Birthday"
        label.textColor = UIColor.black
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    lazy var birthdayButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 17)
        button.setTitle("", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 4
        button.titleLabel?.textAlignment = .left
        button.clipsToBounds = true
        return button
    }()
    
    lazy var ssnLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 20)
        label.text = "SSN-last 4"
        label.textColor = UIColor.black
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    lazy var ssnText: UITextField = {
        let label = UITextField()
        label.placeholder = "1234"
        label.backgroundColor = .white
        label.font = UIFont(name: "HelveticaNeue", size: 17)
        label.clearButtonMode = .whileEditing
        label.borderStyle = .roundedRect
        label.keyboardType = .numberPad
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "3/3"
        
        let nextButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction(_:)))
        self.navigationItem.setRightBarButton(nextButton, animated: true)
        
        NVActivityIndicatorView.DEFAULT_TYPE = .ballScaleMultiple
        NVActivityIndicatorView.DEFAULT_COLOR = uicolorFromHex(0x006a52)
        NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE = CGSize(width: 60, height: 60)
        NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false
        )
        
        successView = SCLAlertView(appearance: appearance)
        successView.addButton("Okay") {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "main") as UIViewController
            self.present(controller, animated: true, completion: nil)
        }
        
        //creat UI elements
        self.view.addSubview(titleLabel)
        self.view.addSubview(birthdayLabel)
        self.view.addSubview(birthdayButton)
        birthdayButton.addTarget(self, action: #selector(birthdayAction(_:)), for: .touchUpInside)
        self.view.addSubview(ssnLabel)
        self.view.addSubview(ssnText)
        
        titleLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(100)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
        }
        
        ssnLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(self.view).offset(10)
        }
        
        ssnText.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(30)
            make.top.equalTo(ssnLabel.snp.top)
            make.left.equalTo(self.view).offset(125)
            make.right.equalTo(self.view).offset(-10)
        }
        
        birthdayLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(ssnText.snp.bottom).offset(10)
            make.left.equalTo(self.view).offset(10)
        }
        
        birthdayButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(birthdayLabel.snp.top)
            make.left.equalTo(self.view).offset(125)
            make.right.equalTo(self.view).offset(-10)
        }
        
        ssnText.becomeFirstResponder()
        
        
        // Do any additional setup after loading the view.
    }
    
    @objc func doneAction(_ sender: UIBarButtonItem){
        self.ssnText.resignFirstResponder()
        
        startAnimating()
        if validateBirthday() && validateSSN(){
            let newAdvisor = PFObject(className: "Advisor")
            newAdvisor["userId"] = PFUser.current()?.objectId
            newAdvisor["first"] = firstName
            newAdvisor["last"] = lastName
            newAdvisor["licenseNumber"] = licenseNumber
            newAdvisor["state"] = state
            newAdvisor["ssn"] = ssnText.text
            newAdvisor["connectId"] = ""
            newAdvisor["isActive"] = false
            newAdvisor["isOnline"] = false
            newAdvisor["birthdayDay"] = self.birthdayDay
            newAdvisor["birthdayMonth"] = self.birthdayMonth
            newAdvisor["birthdayYear"] = self.birthdayYear
            newAdvisor.saveEventually{
                (success: Bool, error: Error?) -> Void in
                self.stopAnimating()
                if (success) {
                    
                    self.successView.showSuccess("Success", subTitle: "Thank You! Our Sickcall team will verify your information and get back to you via your Sickcall email.")
                    
                } else {
                    SCLAlertView().showError("Post Failed", subTitle: "Check internet connection and try again. Contact help@sickcallhealth.com if the issue persists.")
                }
            }
        } else {
            stopAnimating()
        }
        
    }
    
    @objc func birthdayAction(_ sender: UIButton) {
        let prompt = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        //date jaunts
        let datePickerView  : UIDatePicker = UIDatePicker()
        // datePickerView.date = date!
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.addTarget(self, action: #selector(datePickerAction(_:)), for: UIControlEvents.valueChanged)
        prompt.view.addSubview(datePickerView)
        
        let datePicker = UIAlertAction(title: "", style: UIAlertActionStyle.default) {
            UIAlertAction in
        }
        
        datePicker.isEnabled = false
        
        prompt.addAction(datePicker)
        //prompt.addAction(okay)
        
        let height:NSLayoutConstraint = NSLayoutConstraint(item: prompt.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.view.frame.height * 0.6)
        
        prompt.view.addConstraint(height);
        
        let okayJaunt = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            
        }
        
        prompt.addAction(okayJaunt)
        
        present(prompt, animated: true, completion: nil)
    }
    
    @objc func datePickerAction(_ sender: UIDatePicker){
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .short
        
        let formattedDate = timeFormatter.string(from: sender.date)
        
        birthdayButton.setTitle(" \(formattedDate)", for: .normal)
        birthdayButton.setTitleColor(.black, for: .normal)
        
        didSelectBirthday = true
        
        ///
        let calendar = Calendar.current
        
        self.birthdayYear = calendar.component(.year, from: sender.date)
        self.birthdayMonth = calendar.component(.month, from: sender.date)
        self.birthdayDay = calendar.component(.day, from: sender.date)
    }
    
    //validate
    func validateBirthday() ->Bool{
        var isValidated = false
        
        if !didSelectBirthday{
            birthdayButton.setTitle(" Field Required", for: .normal)
            birthdayButton.setTitleColor(.red, for: .normal)
            
        } else{
            isValidated = true
        }
        return isValidated
    }
    
    func validateSSN() ->Bool{
        var isValidated = false
        if ssnText.text!.isEmpty{
            
            ssnText.attributedPlaceholder = NSAttributedString(string:"Field required",
                                                               attributes:[NSAttributedStringKey.foregroundColor: UIColor.red])
            
        } else if (ssnText.text?.count)! != 4{
            ssnText.text = ""
            ssnText.attributedPlaceholder = NSAttributedString(string:"last 4 digits of your social security number",
                                                               attributes:[NSAttributedStringKey.foregroundColor: UIColor.red])
        }else{
            isValidated = true
        }
        return isValidated
    }
    
    //mich.
    func uicolorFromHex(_ rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
}
