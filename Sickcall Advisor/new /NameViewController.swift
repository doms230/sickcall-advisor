//
//  NameViewController.swift
//  Sickcall
//
//  Created by Dom Smith on 8/5/17.
//  Copyright © 2017 Socialgroupe Incorporated All rights reserved.
//

import UIKit
import Parse
import SidebarOverlay
import Kingfisher
import SCLAlertView
import SnapKit

class NameViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIButton!
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
        label.text = "Name"
        label.textColor = UIColor.black
        label.numberOfLines = 0
        return label
    }()
    
    lazy var firstlabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 20)
        label.text = "First Name"
        label.textColor = UIColor.black
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    lazy var firstNameText: UITextField = {
        let label = UITextField()
        label.placeholder = "First Name"
        label.backgroundColor = .white
        label.font = UIFont(name: "HelveticaNeue", size: 17)
        label.clearButtonMode = .whileEditing
        label.borderStyle = .roundedRect
        return label
    }()
    
    lazy var lastLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 20)
        label.text = "Last Name"
        label.backgroundColor = .clear
        label.textColor = UIColor.black
        label.numberOfLines = 0
        return label
    }()
    
    lazy var lastNameText: UITextField = {
        let label = UITextField()
        label.placeholder = "Last Name"
        label.font = UIFont(name: "HelveticaNeue", size: 17)
        label.backgroundColor = .white
        label.borderStyle = .roundedRect
        label.clearButtonMode = .whileEditing
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "1/3"
        
        //set up UI elements
        self.view.addSubview(titleLabel)
        self.view.addSubview(firstlabel)
        self.view.addSubview(firstNameText)
        self.view.addSubview(lastLabel)
        self.view.addSubview(lastNameText)
        
        titleLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(75)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
        }
        
        firstlabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(self.view).offset(10)
        }
        
        firstNameText.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(firstlabel.snp.top)
            make.left.equalTo(self.view).offset(125)
            make.right.equalTo(self.view).offset(-10)
        }
        
        lastLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(firstNameText.snp.bottom).offset(10)
            make.left.equalTo(self.view).offset(10)
        }
        
        lastNameText.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(lastLabel.snp.top)
            make.left.equalTo(self.view).offset(125)
            make.right.equalTo(self.view).offset(-10)
        }
        
        firstNameText.becomeFirstResponder()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let desti = segue.destination as! QualificationsViewController
        desti.firstName = firstNameText.text
        desti.lastName = lastNameText.text
    }
    
    //make keyboard go away 
    /*override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }*/
    
    @IBAction func nextAction(_ sender: UIBarButtonItem) {
        //startAnimating()
        if validateFirstName() && validateLastName(){
            performSegue(withIdentifier: "showLicense", sender: self)
            
        }
    }
    
    @IBAction func profileAction(_ sender: UIButton) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }
    
    //validation tests
    func validateFirstName() ->Bool{
        var isValidated = false
        
        if firstNameText.text!.isEmpty{
            
            firstNameText.attributedPlaceholder = NSAttributedString(string:"Field required",
                                                                     attributes:[NSAttributedStringKey.foregroundColor: UIColor.red])
            
        } else{
            isValidated = true
        }
        return isValidated
    }
    
    func validateLastName() ->Bool{
        var isValidated = false
        
        if lastNameText.text!.isEmpty{
            
            lastNameText.attributedPlaceholder = NSAttributedString(string:"Field required",
                                                                    attributes:[NSAttributedStringKey.foregroundColor: UIColor.red])
            
        } else{
            isValidated = true
        }
        return isValidated
    }
    
    func uicolorFromHex(_ rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
}
