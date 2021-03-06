//
//  WelcomeViewController.swift
//  Sickcall
//
//  Created by Dom Smith on 6/29/17.
//  Copyright © 2017 Sickcall LLC All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import ParseFacebookUtilsV4
import Parse
import NVActivityIndicatorView
import Kingfisher
import SCLAlertView
import SnapKit
import BulletinBoard

class WelcomeViewController: UIViewController,NVActivityIndicatorViewable {
    
    let color = Color()
    
    //bulletin wasn't showing on viewdidload.. moved to view did appear.. because of fb login, show bulleting again.. trying to avoid that by manualyy making sure it's not shown again.
    var didShowWelcome = false
    
    var image: UIImage!
    var retreivedImage: PFFile!
    let screenSize: CGRect = UIScreen.main.bounds
    
    lazy var appImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "appy")
        return image
    }()
    
    lazy var appName: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 45)
        label.text = "Sickcall Advisor"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var appEx: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 20)
        label.text = "Answer Sickcalls, whenever & wherever you want"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var signinButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 20)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        return button
    }()
    
    lazy var signupButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign up", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 20)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        return button
    }()
    
    lazy var facebookButton: UIButton = {
        let button = UIButton()
        button.setTitle(" Login with Facebook", for: .normal)
        button.setImage(UIImage(named: "facebook"), for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 20)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        return button
    }()
    
    lazy var termsButton: UIButton = {
        let button = UIButton()
        button.setTitle("By continuing, you agree to our terms and privacy policy", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 11)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 3
        button.clipsToBounds = true
        return button
    }()
    
    var welcomePage: PageBulletinItem!
    lazy var welcomeManager: BulletinManager = {
        
        welcomePage = PageBulletinItem(title: "Welcome to Sickcall ADV!")
        welcomePage.image = UIImage(named: "appy")
        
        welcomePage.descriptionText = "Sickcall helps people find out how serious their health concern is. People record their question and an advisor responds with a low, medium, or high concern. We're counting on you to help us help people!"
        welcomePage.shouldCompactDescriptionText = true
        welcomePage.actionButtonTitle = "Next"
        welcomePage.alternativeButtonTitle = "Get Started"
        welcomePage.interfaceFactory.tintColor = color.sickcallGreen()
        welcomePage.interfaceFactory.actionButtonTitleColor = .white
        welcomePage.isDismissable = true
        welcomePage.actionHandler = { (item: PageBulletinItem) in
            self.welcomePage.manager?.dismissBulletin()
            self.affordablemanger.prepare()
            self.affordablemanger.presentBulletin(above: self)
        }
        welcomePage.alternativeHandler = { (item: PageBulletinItem) in
            self.welcomePage.manager?.dismissBulletin()
        }
        return BulletinManager(rootItem: self.welcomePage)
        
    }()
    
    var affordablePage: PageBulletinItem!
    lazy var affordablemanger: BulletinManager = {
        
        affordablePage = PageBulletinItem(title: "Make extra money")
        affordablePage.image = UIImage(named: "dollar")
        
        affordablePage.descriptionText = "You get paid per answered question and can make $30-$60 per hour."
        affordablePage.actionButtonTitle = "next"
        affordablePage.alternativeButtonTitle = "Go Back"
        affordablePage.interfaceFactory.tintColor = color.sickcallGreen()
        affordablePage.interfaceFactory.actionButtonTitleColor = .white
        affordablePage.isDismissable = true
        affordablePage.nextItem = accesiblePage
        affordablePage.actionHandler = { (item: PageBulletinItem) in
            self.affordablePage.manager?.dismissBulletin()
            self.accesibleManger.prepare()
            self.accesibleManger.presentBulletin(above: self)
        }
        
        affordablePage.alternativeHandler = { (item: PageBulletinItem) in
            self.affordablePage.manager?.dismissBulletin()
            self.welcomeManager.prepare()
            self.welcomeManager.presentBulletin(above: self)
            
        }
        return BulletinManager(rootItem: self.affordablePage)
        
    }()
    
    var accesiblePage: PageBulletinItem!
    lazy var accesibleManger: BulletinManager = {
        
        accesiblePage = PageBulletinItem(title: "Set your own schedule")
        accesiblePage.image = UIImage(named: "calendar")
        
        accesiblePage.descriptionText = "Answer questions when it's convenient for you. Anytime, anywhere."
        accesiblePage.actionButtonTitle = "Get Started"
        accesiblePage.alternativeButtonTitle = "Go Back"
        accesiblePage.interfaceFactory.tintColor = color.sickcallGreen()
        accesiblePage.interfaceFactory.actionButtonTitleColor = .white
        accesiblePage.isDismissable = true
        accesiblePage.actionHandler = { (item: PageBulletinItem) in
            self.accesiblePage.manager?.dismissBulletin()
            UserDefaults.standard.set(true, forKey: "welcomeInfo")
            
        }
        accesiblePage.alternativeHandler = { (item: PageBulletinItem) in
            self.accesiblePage.manager?.dismissBulletin()
            self.affordablemanger.prepare()
            self.affordablemanger.presentBulletin(above: self)
        }
        
        return BulletinManager(rootItem: self.accesiblePage)
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        if !didShowWelcome{
            if UserDefaults.standard.object(forKey: "welcomeInfo") == nil{
                self.welcomeManager.prepare()
                self.welcomeManager.presentBulletin(above: self)
            }
            didShowWelcome = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NVActivityIndicatorView.DEFAULT_TYPE = .ballScaleMultiple
        NVActivityIndicatorView.DEFAULT_COLOR = color.sickcallGreen()
        NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE = CGSize(width: 60, height: 60)
        NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        self.view.addSubview(appImage)
        self.view.addSubview(appName)
        appName.textColor = color.sickcallGreen()
        self.view.addSubview(appEx)
        self.view.addSubview(signinButton)
        signinButton.addTarget(self, action: #selector(signInAction(_:)), for: .touchUpInside)
        signinButton.setTitleColor(color.sickcallGreen(), for: .normal)
        self.view.addSubview(signupButton)
        signupButton.backgroundColor = color.sickcallGreen()
        signupButton.addTarget(self, action: #selector(signupAction(_:)), for: .touchUpInside)
        self.view.addSubview(facebookButton)
        facebookButton.backgroundColor = color.newColor(0x0950D0)
        facebookButton.addTarget(self, action: #selector(facebookAction(_:)), for: .touchUpInside)
        self.view.addSubview(termsButton)
        termsButton.addTarget(self, action: #selector(termsAction(_:)), for: .touchUpInside)
        
        appImage.snp.makeConstraints { (make) -> Void in
            make.height.width.equalTo(100)
            make.left.equalTo(self.view).offset(screenSize.width / 2 - 50)
            make.bottom.equalTo(self.appName.snp.top).offset(-1)
        }
        
        appName.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
            make.bottom.equalTo(self.appEx.snp.top).offset(-5)
        }
        
        appEx.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
            make.bottom.equalTo(self.view).offset(-(screenSize.height / 2))
        }
        
        signinButton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(50)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
            make.bottom.equalTo(self.signupButton.snp.top).offset(-10)
        }
        
        signupButton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(50)
            make.top.equalTo(signinButton.snp.bottom).offset(10)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
        }
        
        facebookButton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(50)
            make.top.equalTo(signupButton.snp.bottom).offset(10)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
        }
        
        termsButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.facebookButton.snp.bottom).offset(10)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
            make.bottom.equalTo(self.view).offset(-20)
        }
    }

    @objc func signInAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showSignin", sender: self)
    }

    @objc func signupAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showSignup", sender: self)
    }
    
    @objc func facebookAction(_ sender: UIButton) {
        PFFacebookUtils.logInInBackground(withReadPermissions: ["public_profile","email"]){
            (user: PFUser?, error: Error?) -> Void in
            self.startAnimating()
            if let user = user {
                let installation = PFInstallation.current()
                installation?["user"] = user
                installation?["userId"] = user.objectId
                installation?.saveEventually()
                
                if user.isNew {
                    let request = FBSDKGraphRequest(graphPath: "me",parameters: ["fields": "id, name, first_name, last_name, email, gender, picture.type(large)"], tokenString: FBSDKAccessToken.current().tokenString, version: nil, httpMethod: "GET")
                    let _ = request?.start(completionHandler: { (connection, result, error) in
                        guard let userInfo = result as? [String: Any] else { return } //handle the error
                        
                        //The url is nested 3 layers deep into the result so it's pretty messy
                        if let imageURL = ((userInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                            
                            //self.image.kf.setImage(with: URL(string: imageURL))
                            if let url = URL(string: imageURL) {
                                if let data = NSData(contentsOf: url){
                                    self.image = UIImage(data: data as Data)
                                }
                            }
                            let proPic = UIImageJPEGRepresentation(self.image, 0.5)
                            
                            self.retreivedImage = PFFile(name: "profile_ios.jpeg", data: proPic!)
                            self.retreivedImage?.saveInBackground {
                                (success: Bool, error: Error?) -> Void in
                                if (success) {
                                    user.email = userInfo["email"] as! String?
                                    user["DisplayName"] = userInfo["first_name"] as! String?
                                    user["Profile"] = self.retreivedImage
                                    user["foodAllergies"] = []
                                    user["gender"] = userInfo["gender"] as! String?
                                    user["height"] = " "
                                    user["medAllergies"] = []
                                    user["weight"] = " "
                                    user["birthday"] = " "
                                    user["beatsPM"] = " "
                                    user["healthIssues"] = " "
                                    user["respsPM"] = " "
                                    user["medHistory"] = " "
                                    user.saveEventually{
                                        (success: Bool, error: Error?) -> Void in
                                        if (success) {
                                            self.stopAnimating()
                                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                            let initialViewController = storyboard.instantiateViewController(withIdentifier: "main")
                                            self.present(initialViewController, animated: true, completion: nil)
                                        }
                                    }
                                }
                            }
                        }
                    })
                } else {
                    self.stopAnimating()
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "main")
                    self.present(initialViewController, animated: true, completion: nil)
                }
            } else {
                self.stopAnimating()
            }
        }
    }
    
    @objc func termsAction(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "https://www.sickcallhealth.com/terms" )!, options: [:], completionHandler: nil)
    }
}
