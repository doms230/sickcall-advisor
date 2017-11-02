//
//  SignupViewController.swift
//  Sickcall
//
//  Created by Dom Smith on 8/23/17.
//  Copyright © 2017 Sickcall LLC All rights reserved.
//

import UIKit
import Parse
import SCLAlertView
import NVActivityIndicatorView
import SnapKit

class SignupViewController: UIViewController,NVActivityIndicatorViewable {

    //propic
    
    var uploadedImage: PFFile!
    
    //UI components
    
    //validate jaunts
    var valPassword = false
    var valEmail = false
    var isSwitchOn = false
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 30)
        label.text = "Sign Up"
        label.textColor = UIColor.black
        label.numberOfLines = 0
        return label
    }()
    
    lazy var emailText: UITextField = {
        let label = UITextField()
        label.placeholder = "Email"
        label.font = UIFont(name: "HelveticaNeue", size: 17)
        label.backgroundColor = .white
        label.borderStyle = .roundedRect
        label.clearButtonMode = .whileEditing
        label.keyboardType = .emailAddress
        return label
    }()
    
    lazy var passwordText: UITextField = {
        let label = UITextField()
        label.placeholder = "Password"
        label.font = UIFont(name: "HelveticaNeue", size: 17)
        label.backgroundColor = .white
        label.borderStyle = .roundedRect
        label.clearButtonMode = .whileEditing
        label.isSecureTextEntry = true 
        return label
    }()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        //print(numberToSend[0])
        let exitItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(SignupViewController.exitAction(_:)))
        self.navigationItem.leftBarButtonItem = exitItem
        
        let doneItem = UIBarButtonItem(title: "Sign Up", style: .plain, target: self, action: #selector(SignupViewController.next(_:)))
        self.navigationItem.rightBarButtonItem = doneItem
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(emailText)
        self.view.addSubview(passwordText)
        
        titleLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(100)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
        }
        
        emailText.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
        }
        
        passwordText.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(emailText.snp.bottom).offset(10)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
        }
        
        emailText.becomeFirstResponder()
        
        NVActivityIndicatorView.DEFAULT_TYPE = .ballScaleMultiple
        NVActivityIndicatorView.DEFAULT_COLOR = uicolorFromHex(0x006a52)
        NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE = CGSize(width: 60, height: 60)
        NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        let proPic = UIImageJPEGRepresentation(UIImage(named: "appy")!, 0.5)
        uploadedImage = PFFile(name: "defaultProfile_ios.jpeg", data: proPic!)
        uploadedImage?.saveInBackground()
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let desti = segue.destination as! NewProfileViewController
        
        //user info
        desti.emailString = emailString
        desti.passwordString = passwordText.text!
        desti.isSwitchOn = isSwitchOn
    }*/
    
    @objc func next(_ sender: UIBarButtonItem){
        emailText.resignFirstResponder()
        passwordText.resignFirstResponder()
        
        let emailString = emailText.text?.lowercased()
        
        if validateEmail() && validatePassword(){
            startAnimating()
            //self.performSegue(withIdentifier: "showNewProfile", sender: self)
            /*let emailQuery = PFQuery(className: "_User")
            emailQuery.whereKey("email", equalTo: self.emailString )
            emailQuery.findObjectsInBackground{
                (objects: [PFObject]?, error: Error?) -> Void in
                self.stopAnimating()
                if objects?.count == 0{
                    self.performSegue(withIdentifier: "showNewProfile", sender: self)
                    
                } else {
                    SCLAlertView().showError("Oops", subTitle: "Email already in use")
                }
            }*/
            
            newUser(username: emailString!, password: passwordText.text!, email: emailString!, imageFile:
                uploadedImage)
            
        }
    }
    
    func newUser( username: String,
                  password: String, email: String, imageFile: PFFile ){
        let user = PFUser()
        user.username = username
        user.password = password
        user.email = email
        user["DisplayName"] = "Sickcaller"
        user["Profile"] = imageFile
        user["foodAllergies"] = []
        user["gender"] = " "
        user["height"] = " "
        user["medAllergies"] = []
        user["weight"] = " "
        user["birthday"] = " "
        user["beatsPM"] = " "
        user["healthIssues"] = " "
        user["respsPM"] = " "
        user["medHistory"] = " "
        user.signUpInBackground{ (succeeded: Bool, error: Error?) -> Void in
            self.stopAnimating()
            if error != nil {
                // let errorString = erro_userInfofo["error"] as? NSString
                //
                print(error!)
                SCLAlertView().showError("Oops", subTitle: "Email already taken.")
                
            } else {
                let installation = PFInstallation.current()
                installation?["user"] = PFUser.current()
                installation?["userId"] = PFUser.current()?.objectId
                installation?.saveEventually()
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "main")
                self.present(initialViewController, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: Validate jaunts
    
    func validatePassword() -> Bool{
        if passwordText.text!.isEmpty{
            passwordText.attributedPlaceholder = NSAttributedString(string:"Field required",
                                                                     attributes:[NSAttributedStringKey.foregroundColor: UIColor.red])
            valPassword = false
            
        } else{
            print("true")
            valPassword = true
        }
        
        return valPassword
    }
    
    func validateEmail() -> Bool{
        let emailString : NSString = emailText.text! as NSString
        if emailText.text!.isEmpty{
            emailText.attributedPlaceholder = NSAttributedString(string:"Field required",
                                                                  attributes:[NSAttributedStringKey.foregroundColor: UIColor.red])
            valEmail = false
            view.endEditing(true)
            
        } else if !emailString.contains("@"){
            emailText.text = ""
            emailText.attributedPlaceholder = NSAttributedString(string:"Valid email required",
                                                                  attributes:[NSAttributedStringKey.foregroundColor: UIColor.red])
            valEmail = false
            view.endEditing(true)
            
        } else if !emailString.contains("."){
            emailText.text = ""
            emailText.attributedPlaceholder = NSAttributedString(string:"Valid email required",
                                                                  attributes:[NSAttributedStringKey.foregroundColor: UIColor.red])
            valEmail = false
            view.endEditing(true)
            
        } else{
            valEmail = true
        }
        return valEmail
    }
    
    @objc func switchAction(_ sender: UISwitch) {
        if sender.isOn{
            isSwitchOn = true
            
        } else {
            isSwitchOn = false 
        }
    }
    
    @objc func exitAction(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "welcome") as UIViewController
        self.present(controller, animated: true, completion: nil)
    }
    
    func uicolorFromHex(_ rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
}
