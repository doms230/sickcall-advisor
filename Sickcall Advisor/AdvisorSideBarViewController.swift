//
//  AdvisorSideBarViewController.swift
//  Sickcall
//
//  Created by Dom Smith on 7/11/17.
//  Copyright © 2017 Sickcall LLC All rights reserved.
//

import UIKit
import Parse
import SnapKit
import BulletinBoard
import ParseLiveQuery

class AdvisorSideBarViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let color = Color()
    
    lazy var profileView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var profileName: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 25)
        label.text = "Sickcaller"
        label.textAlignment = .left
        label.textColor = UIColor.black
        label.numberOfLines = 0
        return label
    }()
    
    lazy var profileImage: UIImageView = {
        let label = UIImageView()
        label.image = UIImage(named: "appy")
        return label
    }()
    
    lazy var paymentsButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 20)
        button.titleLabel?.textAlignment = .left
        button.setTitle(" Payments", for: .normal)
        button.setImage(UIImage(named: "money"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    lazy var editProfileButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 20)
        button.titleLabel?.textAlignment = .left
        button.setTitle(" Edit Profile Picture", for: .normal)
        button.setImage(UIImage(named: "profile"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    lazy var supportButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 20)
        button.titleLabel?.textAlignment = .left
        button.setTitle(" Support", for: .normal)
        button.setImage(UIImage(named: "support"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    lazy var notActiveLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 25)
        label.text = "Profile options will become available after you become an active nurse advisor."
        label.textAlignment = .left
        label.textColor = UIColor.black
        label.numberOfLines = 0
        return label
    }()
    
    let liveQueryClient = ParseLiveQuery.Client()
    var subscription: Subscription<Post>?
    var questionsQuery: PFQuery<Post>{
        return (Post.query()!
            .whereKey("isRemoved", equalTo: false) as! PFQuery<Post> )
    }
    
    lazy var selfieManager: BulletinManager = {
        let selfiePage = PageBulletinItem(title: "Make Your Selfie Clear")
        selfiePage.image = UIImage(named: "selfie")
        selfiePage.descriptionText = "We want your Sickcallers to see that you're a real person!"
        selfiePage.shouldCompactDescriptionText = true
        selfiePage.actionButtonTitle = "Okay"
        selfiePage.interfaceFactory.tintColor = color.sickcallGreen()
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
    
     let imagePicker = UIImagePickerController()
    
    override func viewDidAppear(_ animated: Bool) {
        let query = PFQuery(className: "Post")
        query.whereKey("advisorUserId", equalTo: PFUser.current()!.objectId!)
        query.whereKey("isAnswered", equalTo: false)
        query.whereKey("isRemoved", equalTo: false)
        query.order(byAscending: "createdAt")
        query.getFirstObjectInBackground {
            (object: PFObject?, error: Error?) -> Void in
            if error == nil || object != nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "question")
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startQuestionSubscription()
        imagePicker.delegate = self
        
        let query = PFQuery(className: "_User")
        query.whereKey("objectId", equalTo: PFUser.current()!.objectId!)
        query.getFirstObjectInBackground {
            (object: PFObject?, error: Error?) -> Void in
            if error == nil || object != nil {
                let imageFile: PFFile = object!["Profile"] as! PFFile
                self.profileImage.kf.setImage(with: URL(string: imageFile.url!))
                self.profileImage.layer.cornerRadius = 25
                self.profileImage.clipsToBounds = true
                
                let name = object!["DisplayName"] as! String
                self.profileName.text = name
                
                self.showProfile()
                self.loadAdvisor()
            }
        }
    }
    
    func loadAdvisor(){
        let adQuery = PFQuery(className: "Advisor")
        adQuery.whereKey("userId", equalTo: PFUser.current()!.objectId!)
        adQuery.getFirstObjectInBackground {
            (object: PFObject?, error: Error?) -> Void in
            if error == nil || object != nil {
                let isActive = object?["isActive"] as! Bool
                if isActive{
                    self.showUIOptions()
                    
                } else {
                    self.showNotActiveView()
                }
                
            } else {
                self.showNotActiveView()
            }
        }
    }
    
    func showUIOptions(){
        self.view.addSubview(editProfileButton)
        editProfileButton.addTarget(self, action: #selector(buttonActions(_:)) , for: .touchUpInside)
        self.editProfileButton.tag = 0
        
        self.view.addSubview(paymentsButton)
        paymentsButton.addTarget(self, action: #selector(buttonActions(_:)), for: .touchUpInside)
        self.paymentsButton.tag = 1
        
        self.view.addSubview(supportButton)
        supportButton.addTarget(self, action: #selector(buttonActions(_:)) , for: .touchUpInside)
        self.supportButton.tag = 2
        
        editProfileButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(profileView.snp.bottom).offset(25)
            make.left.equalTo(self.view).offset(10)
        }
        
        paymentsButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.editProfileButton.snp.bottom).offset(20)
            make.left.equalTo(self.view).offset(10)
        }
        
        supportButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(paymentsButton.snp.bottom).offset(20)
            make.left.equalTo(self.view).offset(10)
        }
    }
    
    func showProfile(){
        self.view.addSubview(profileView)
        self.profileView.addSubview(profileImage)
        self.profileView.addSubview(profileName)
        profileView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(50)
            make.top.equalTo(self.view).offset(100)
            make.left.equalTo(self.view).offset(5)
            make.right.equalTo(self.view).offset(10)
        }
        
        profileImage.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.top.equalTo(self.profileView.snp.top)
            make.left.equalTo(self.profileView.snp.left)
        }
        
        profileName.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.top.equalTo(self.profileView.snp.top)
            make.left.equalTo(self.profileImage.snp.right).offset(5)
            make.right.equalTo(self.profileView.snp.right).offset(10)
        }
    }
    
    func showNotActiveView(){
        self.view.addSubview(notActiveLabel)
        notActiveLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.profileName.snp.bottom).offset(50)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
        }
    }
    
    @objc func buttonActions(_ sender: UIButton) {
        switch sender.tag{
        case 0:
            self.selfieManager.prepare()
            self.selfieManager.presentBulletin(above: self)
        break
            
        case 1:
            self.performSegue(withIdentifier: "showBankInfo", sender: self)
            break
            
        case 2:
            let url = URL(string : "https://www.sickcallhealth.com/support" )
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            break
            
        default:
            break
        }
    }
    
    @IBAction func signoutAction(_ sender: UIBarButtonItem) {
        PFUser.logOut()
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "welcome")
        self.present(controller, animated: true, completion: nil)
    }
    
    //image jaunts
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        dismiss(animated: true, completion: nil)
        self.profileImage.image = chosenImage
        
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
    
    //live query
    func startQuestionSubscription(){
        subscription = liveQueryClient
            .subscribe(questionsQuery)
            .handle(Event.updated) { _, object in
                print(object)
                let user = object["advisorUserId"] as! String
                if user == PFUser.current()?.objectId{
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "question")
                    self.present(controller, animated: true, completion: nil)
                }
        }
    }
}
