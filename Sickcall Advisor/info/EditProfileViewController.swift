//
//  EditProfileViewController.swift
//  Sickcall
//
//  Created by Dominic Smtih on 7/19/17.
//  Copyright © 2017 Socialgroupe Incorporated All rights reserved.
//

import UIKit
import Parse
import NVActivityIndicatorView
import Kingfisher
import SnapKit
import SCLAlertView
import BulletinBoard

class EditProfileViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate,NVActivityIndicatorViewable {
    
    let screenSize: CGRect = UIScreen.main.bounds
    var nameString: String!
    
    var pictureUploaded = false
    
    lazy var profiletitle: UILabel = {
        let label = UILabel()
        label.text = "Upload Selfie"
        label.backgroundColor = .clear
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    lazy var username: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.font = UIFont(name: "HelveticaNeue", size: 20)
        label.textAlignment = .center
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
    
    lazy var selfieManager: BulletinManager = {
        
        let selfiePage = PageBulletinItem(title: "Make Your Selfie Clear")
        selfiePage.image = UIImage(named: "selfie")
        
        selfiePage.descriptionText = "We want your Sickcallers to see that you're a real person!"
        selfiePage.shouldCompactDescriptionText = true
        selfiePage.actionButtonTitle = "Okay"
        selfiePage.interfaceFactory.tintColor = uicolorFromHex(0x006a52)// green
        selfiePage.interfaceFactory.actionButtonTitleColor = .white
        selfiePage.isDismissable = true
        selfiePage.actionHandler = { (item: PageBulletinItem) in
            selfiePage.manager?.dismissBulletin()
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        return BulletinManager(rootItem: selfiePage)
        
    }()
    
    var imageJaunt: String!
    var nameJaunt: String!
    
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(updateAction(_:)))
        self.navigationItem.setRightBarButton(nextButton, animated: true)
        
        imagePicker.delegate = self

        image.layer.cornerRadius = 50
        image.clipsToBounds = true
        image.setBackgroundImage(UIImage(named: "appy.png"), for: .normal)
        image.addTarget(self, action: #selector(editProfile(_:)), for: .touchUpInside)
        username.text = nameJaunt
        
        self.view.addSubview(profiletitle)
        self.view.addSubview(username)
        self.view.addSubview(image)
        
        profiletitle.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(100)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
            //make.bottom.equalTo(self.view).offset(-20)
        }
        
        image.snp.makeConstraints { (make) -> Void in
            make.height.width.equalTo(100)
            make.top.equalTo(self.profiletitle.snp.bottom).offset(10)
            make.left.equalTo(self.view).offset(screenSize.width / 2 - 50)
        }
        
        username.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(image.snp.bottom).offset(10)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
            //make.bottom.equalTo(self.view).offset(-20)
        }
        username.text = "\(nameString!), RN"
        username.backgroundColor = .clear
        
        NVActivityIndicatorView.DEFAULT_TYPE = .ballScaleMultiple
        NVActivityIndicatorView.DEFAULT_COLOR = uicolorFromHex(0x006a52)
        NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE = CGSize(width: 60, height: 60)
        NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    }

    @objc func updateAction(_ sender: UIBarButtonItem) {
        
        if pictureUploaded{
            startAnimating()
            let query = PFQuery(className:"_User")
            query.getObjectInBackground(withId: PFUser.current()!.objectId!) {
                (object: PFObject?, error: Error?) -> Void in
                if error == nil && object != nil {
                    object?["DisplayName"] = "\(self.nameString!), RN"
                    object?.saveEventually {
                        (success: Bool, error: Error?) -> Void in
                        self.stopAnimating()
                        if (success) {
                            self.performSegue(withIdentifier: "showNewAddress", sender: self)
                        }
                    }
                    
                } else {
                    print(error!)
                }
            }
            
        } else {
            SCLAlertView().showError("Oops!", subTitle: "Profile picture required.")
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        dismiss(animated: true, completion: nil)
        self.image.setBackgroundImage(chosenImage, for: .normal)
        self.pictureUploaded = true
        
        let proPic = UIImageJPEGRepresentation(chosenImage, 0.5)
       let uploadedImage = PFFile(name: "profile_ios.jpeg", data: proPic!)
        uploadedImage?.saveInBackground {
            (success: Bool, error: Error?) -> Void in
            if (success) {
                
                if PFUser.current() != nil{
                    let query = PFQuery(className:"_User")
                    query.getObjectInBackground(withId: PFUser.current()!.objectId!) {
                        (object: PFObject?, error: Error?) -> Void in
                        if error == nil && object != nil {
                            if uploadedImage != nil{
                                object!["Profile"] = uploadedImage
                            }
                            object?.saveEventually()
                            
                        } else {
                            print(error!)
                        }
                    }
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func editProfile(_ sender: UIButton) {
        self.selfieManager.prepare()
        self.selfieManager.presentBulletin(above: self)
    }
    
    func uicolorFromHex(_ rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
}
