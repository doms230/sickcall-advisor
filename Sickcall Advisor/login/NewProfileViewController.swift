//NewProfileViewController.swift
//Sickcall
//
//  Created by Dom Smith on 7/2/17.
//  Copyright © 2017 Socialgroupe Incorporated All rights reserved.


import UIKit
import Parse
import NVActivityIndicatorView
import SCLAlertView
import SnapKit

class NewProfileViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate,NVActivityIndicatorViewable{
    
    let screenSize: CGRect = UIScreen.main.bounds

    lazy var username: UITextField = {
        let label = UITextField()
        label.placeholder = "Name"
        label.backgroundColor = .white
        label.font = UIFont(name: "HelveticaNeue", size: 17)
        label.clearButtonMode = .whileEditing
        label.borderStyle = .roundedRect
        return label
    }()
    
    lazy var image: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 40)
        button.titleLabel?.textAlignment = .left
        button.setTitle("+", for: .normal)
        button.setTitleColor(.black, for: .normal)
        //label.numberOfLines = 0
        return button
    }()
        
    var userNameString: String!
    var emailString: String!
    var passwordString: String!
    var isSwitchOn: Bool! 
    //image picker stuff
    
    var uploadedImage: PFFile!
    
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "2/2"
        let doneItem = UIBarButtonItem(title: "Sign up", style: .plain, target: self, action: #selector(NewProfileViewController.signUpAction(_:)))
        self.navigationItem.rightBarButtonItem = doneItem
        
        let proPic = UIImageJPEGRepresentation(UIImage(named: "appy")!, 0.5)
        uploadedImage = PFFile(name: "defaultProfile_ios.jpeg", data: proPic!)
        
        imagePicker.delegate = self
        
        image.layer.cornerRadius = 50
        image.clipsToBounds = true
        image.addTarget(self, action: #selector(uploadProfilePicAction(_:)), for: .touchUpInside)
        
        self.view.addSubview(username)
        self.view.addSubview(image)
        
        image.snp.makeConstraints { (make) -> Void in
            make.height.width.equalTo(100)
            make.top.equalTo(self.view).offset(75)
            make.left.equalTo(self.view).offset(screenSize.width / 2 - 50)
        }
        
        username.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(image.snp.bottom).offset(10)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
            //make.bottom.equalTo(self.view).offset(-20)
        }
        
        NVActivityIndicatorView.DEFAULT_TYPE = .ballScaleMultiple
        NVActivityIndicatorView.DEFAULT_COLOR = uicolorFromHex(0x006a52)
        NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE = CGSize(width: 60, height: 60)
        NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    }
    
    @objc func signUpAction(_ sender: UIBarButtonItem) {
        //create new Profile.. send to med info
        startAnimating()
        newUser(displayName: username.text!, username: emailString!, password: passwordString, email: emailString!, imageFile: uploadedImage)
        
    }
    
    func newUser( displayName: String, username: String,
                  password: String, email: String, imageFile: PFFile ){
        let user = PFUser()
        user.username = username
        user.password = password
        user.email = email
        user["DisplayName"] = displayName
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
                SCLAlertView().showError("Oops", subTitle: "We couldn't sign you up. Check internet connection and try again")
                
            } else {
                let installation = PFInstallation.current()
                installation?["user"] = PFUser.current()
                installation?["userId"] = PFUser.current()?.objectId
                installation?.saveEventually()
                
                if self.isSwitchOn{
                    let storyboard = UIStoryboard(name: "Advisor", bundle: nil)
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "container") as! AdvisorContainerViewController
                    initialViewController.isAdvisor = false
                    self.present(initialViewController, animated: true, completion: nil)
                } else {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "main")
                    self.present(initialViewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    //Image picker functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        dismiss(animated: true, completion: nil)
        
        //userImage.setTitle("", for: .normal)
        image.setBackgroundImage(chosenImage, for: .normal)
        //tableJaunt.reloadData()
        
        let proPic = UIImageJPEGRepresentation(chosenImage, 0.5)
        uploadedImage = PFFile(name: "profile_ios.jpeg", data: proPic!)
        uploadedImage?.saveInBackground {
            (success: Bool, error: Error?) -> Void in
            if (success) {
                
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func uploadProfilePicAction(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType =  .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func uicolorFromHex(_ rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
}
