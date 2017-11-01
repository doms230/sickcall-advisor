//
//  LoginViewController.swift
//  Sickcall
//
//  Created by Dom Smith on 6/29/17.
//  Copyright © 2017 Socialgroupe Incorporated All rights reserved.
//

import UIKit
import Parse
import SCLAlertView
import NVActivityIndicatorView

class LoginViewController: UIViewController,NVActivityIndicatorViewable {
    
    var valUsername = false
    var valPassword = false
    var valEmail = false
    
    var signupHidden = true
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 30)
        label.text = "Sign In"
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
    
    lazy var signButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 20)
        button.titleLabel?.textAlignment = .right
        button.setTitle("Sign In", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        //label.numberOfLines = 0
        return button
    }()
    
    var forgotPasswordView: SCLAlertView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let exitItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(LoginViewController.exitAction(_:)))
        self.navigationItem.leftBarButtonItem = exitItem
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(emailText)
        self.view.addSubview(passwordText)
        self.view.addSubview(signButton)
        
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
        
        signButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(passwordText.snp.bottom).offset(10)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
        //    make.bottom.equalTo(self.view).offset(-20)
        }
        signButton.addTarget(self, action: #selector(loginAction(_:)), for: .touchUpInside)
        
        emailText.becomeFirstResponder()
        
        NVActivityIndicatorView.DEFAULT_TYPE = .ballScaleMultiple
        NVActivityIndicatorView.DEFAULT_COLOR = uicolorFromHex(0x006a52)
        NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE = CGSize(width: 60, height: 60)
        NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    }
    
    @IBAction func forgotPasswordAction(_ sender: UIBarButtonItem) {
        forgotPasswordUI()
        forgotPasswordView.showEdit("Forgot Password", subTitle: "Enter in your Sickcall email")
    }
    
    @objc func loginAction(_ sender: UIButton) {
        emailText.resignFirstResponder()
        passwordText.resignFirstResponder()
        let emailString = emailText.text?.lowercased()
        if validateUsername() && validatePassword(){
            returningUser( password: passwordText.text!, username: emailString!)
        }
    }
    
    func validateUsername() ->Bool{
        
        //Validate username
        
        if emailText.text!.isEmpty{
            
            emailText.attributedPlaceholder = NSAttributedString(string:"Field required",
                                                             attributes:[NSAttributedStringKey.foregroundColor: UIColor.red])
            valUsername = false
            
        } else{
            valUsername = true
        }
        return valUsername
    }
    
    func validatePassword() -> Bool{
        
        if passwordText.text!.isEmpty{
            passwordText.attributedPlaceholder = NSAttributedString(string:"Field required",
                                                                attributes:[NSAttributedStringKey.foregroundColor: UIColor.red])
            valPassword = false
            
        } else{
            valPassword = true
        }
        
        return valPassword
    }
    
    func returningUser( password: String, username: String){
        
        startAnimating()
        
        let userJaunt = username.trimmingCharacters(
            in: NSCharacterSet.whitespacesAndNewlines
        )
        
        PFUser.logInWithUsername(inBackground: userJaunt, password:password) {
            (user: PFUser?, error: Error?) -> Void in
            if user != nil {
                
                //associate current user with device
                let installation = PFInstallation.current()
                installation?["user"] = PFUser.current()
                installation?["userId"] = PFUser.current()?.objectId
                installation?.saveEventually()
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "main")
                self.present(initialViewController, animated: true, completion: nil)
                
            } else {
                self.stopAnimating()
                SCLAlertView().showError("Login Attemmpt Unsuccessful", subTitle: "Check username and password combo.")
            }
        }
    }
    
    func forgotPasswordUI(){
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: true
        )
        
        forgotPasswordView = SCLAlertView(appearance: appearance)
        let txt = forgotPasswordView.addTextField("Sickcall email")
        forgotPasswordView.addButton("Reset"){
            let blockQuery = PFQuery(className: "_User")
            blockQuery.whereKey("email", equalTo: "\(txt.text!)")
            blockQuery.findObjectsInBackground{
                (objects: [PFObject]?, error: Error?) -> Void in
                if objects?.count != 0{
                    PFUser.requestPasswordResetForEmail(inBackground: "\(txt.text!)")
                    SCLAlertView().showSuccess("Check your inbox", subTitle: "Click on the link from noreply@sickcallhealth.com")
                } else {
                    SCLAlertView().showNotice("Oops", subTitle: "Couldn't find an email associated with \(txt.text!)")
                }
            }
        }
    }
    
    
    @objc func exitAction(_ sender: UIBarButtonItem){
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "welcome")
        self.present(initialViewController, animated: true, completion: nil)
    }
    
    func uicolorFromHex(_ rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
}
