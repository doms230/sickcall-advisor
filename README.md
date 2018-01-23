#  Sickcall Advisor

### Health answers from U.S. Registered Nurses [Nurse advisor version]

Features
======
* View and reply to Sickcalls

Demo: 
<a href="http://www.youtube.com/watch?feature=player_embedded&v=DuHmLggVOpY
" target="_blank"><img src="http://img.youtube.com/vi/DuHmLggVOpY/0.jpg" 
alt="Sickcall run through" width="240" height="180" border="10" /></a>

Component Libraries
======

Frameworks
-
[AVFoundation and AVKit](https://github.com/doms230/sickcall#avfoundation)
[UserNotifications](https://github.com/doms230/sickcall#usernotifications)

### AVFoundation and AVKit
 * Used to playback Sickcallers' videos. 
 
 Nurse advisors are required to watch the Sickcaller's video before they can replying. 
 ```swift
     //PFFile is the required video format for Parse server. The video has to be converted from PFFile to .mov to play 
     func loadvideo(videoJaunt: PFFile){
        videoJaunt.getDataInBackground {
            (videoData: Data?, error: Error?) -> Void in
            if error == nil {
                if let videoData = videoData {
                    //convert video file to playable format
                    let documentsPath : AnyObject =                
                    NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as AnyObject
                    let destinationPath:String = documentsPath.appending("/file.mov")
                    try? videoData.write ( to: URL(fileURLWithPath: destinationPath as String), options: [.atomic])
                    self.playerItem = AVPlayerItem(asset: AVAsset(url: URL(fileURLWithPath: destinationPath as String)))
                    self.player = AVPlayer(playerItem: self.playerItem)
                    self.playerController = AVPlayerViewController()
                    self.playerController.player = self.player
                    
                    //Notification is set up to observe if/when the user reaches the end of video. The response info is shown       when the user reaches the end of the video. 
                    NotificationCenter.default.addObserver(self,
                    selector: #selector(V2AdvisorQuestionViewController.playerItemDidReachEnd(_:)),
                    name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
                    
                    if self.didPressPlay{
                        self.player.seek(to: kCMTimeZero)
                        self.stopAnimating()
                        self.present(self.playerController, animated: true) {
                            self.player.play()
                        }
                    }
                }
            }
        }
}
 ```
 ### UserNotifications
* Used to register push notifications to the user's phone

Sickcall shows a custom alert detailing why they show enable notifications. It would be really annoying to get this message everytime you open the app so a UserDefault is set to record when the user is shown the alert for the first time.
```swift 
    lazy var notificationsManager: BulletinManager = {
        let page = PageBulletinItem(title: "Notifications")
        page.image = UIImage(named: "bell")
        page.descriptionText = "Sickcall uses notifications to let you know about important updates, like when you receive a new Sickcall."
        page.actionButtonTitle = "Okay"
        page.interfaceFactory.tintColor = color.sickcallGreen()
        page.interfaceFactory.actionButtonTitleColor = .white
        page.isDismissable = true
        page.actionHandler = { (item: PageBulletinItem) in
            page.manager?.dismissBulletin()
            UserDefaults.standard.set(true, forKey: "notifications")
            let current = UNUserNotificationCenter.current()
            current.getNotificationSettings(completionHandler: { (settings) in
                if settings.authorizationStatus == .notDetermined {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                        (granted, error) in
                        
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            })
        }
        return BulletinManager(rootItem: page)
}()

```
External Libraries
-
External Libraries made Sickcall so much better. Thank you. Besides Google Search, I found many of these libraries from [iOS Cookies](http://www.ioscookies.com/). Check it out!

##### Table of Contents 
 * [Alamofire & Swifty JSON](https://github.com/doms230/sickcall#alamofire)
 * [SnapKit](https://github.com/doms230/sickcall#snapkit)
 * [Parse](https://github.com/doms230/sickcall#parse)
 * [Facebook SDK](https://github.com/doms230/sickcall#facebooksdk)
 * [Kingfisher](https://github.com/doms230/sickcall#kingfisher)
 * [SCLAlertView](https://github.com/doms230/sickcall#sclalertview)
 * [BulletinBoard](https://github.com/doms230/sickcall#bulletinboard)
 * [NVActivityIndicatorView](https://github.com/doms230/sickcall#nvactivityindicatorview)
 
### [Alamofire](https://github.com/Alamofire/Alamofire) & [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)
* Alamofire and SwiftyJSON were using to easily communicate with my Node.js API.

The example code below takes the Sickcall Advisor's bank information and securely pushes it to the Node.js API to be processed. A response is sent back in JSON. 
```swift 
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
            
            Alamofire.request(self.baseURL, method: .post, parameters: p, encoding: 
            JSONEncoding.default).validate().responseJSON { response in switch response.result {
            case .success(let data):
                let json = JSON(data)
                
                //can't get status code for some reason
                self.stopAnimating()
                if let status = json["statusCode"].int{
                    let message = json["message"].string
                    
                    SCLAlertView().showError("Something Went Wrong", subTitle: message!)
                    
                } else {
                    let bankName = json["external_accounts"]["data"][0]["bank_name"].string
                    let bankLast4 = json["external_accounts"]["data"][0]["last4"].string
                    self.successView.showSuccess("Success", subTitle: "Your funds will be deposited to \(String(describing: 
                    bankName!)) ****\(String(describing: bankLast4!)) from now on.")
                }
                
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

```
### [SnapKit](https://github.com/SnapKit/SnapKit)
*  SnapKit is A Swift Autolayout DSL for iOS & OS X

SnapKit is one of my favorite libraries. I'm not a fan of dragging and dropping elements because it never works well accross different devices. Without SnapKit you end up spending a lot of time trying to get the layout right.

The code snippet below uses SnapKit to create the Nurse Advisor Dashboard 
```swift 

    //dashboard
    func configureDashboard(){
        //payments
        self.addSubview(paymentView)
        paymentView.addSubview(paymentsLabel)
        paymentView.addSubview(paymentAmount)
        paymentView.addSubview(getPaidLabel)
        
        paymentView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(200)
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
        
        paymentsLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(paymentView.snp.top).offset(20)
            make.left.equalTo(paymentView.snp.left).offset(5)
            make.right.equalTo(paymentView.snp.right).offset(-5)
        }
        
        paymentAmount.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(paymentsLabel.snp.bottom).offset(5)
            make.left.equalTo(paymentView.snp.left).offset(5)
            make.right.equalTo(paymentView.snp.right).offset(-5)
        }
        
        getPaidLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(paymentAmount.snp.bottom).offset(15)
            make.left.equalTo(paymentView.snp.left).offset(10)
            make.right.equalTo(paymentView.snp.right).offset(-10)
        }
        
        //status
        self.addSubview(statusButton)
        self.addSubview(queueLabel)
        
        statusButton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(50)
            make.top.equalTo(paymentView.snp.bottom).offset(15)
            make.left.equalTo(self).offset(10)
            make.right.equalTo(self).offset(-10)
        }
        
        queueLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(statusButton.snp.bottom).offset(5)
            make.left.equalTo(self).offset(5)
            make.right.equalTo(self).offset(-5)
            make.bottom.equalTo(self).offset(-10)
        }
}

```
 
### [Parse](https://github.com/parse-community)
* Parse made it easy for me to store and query data in a mongoDB

The code snippet below queries the Sickcall object, then appends the Sickcall Advisor's concern level and comment and updates the object. 
```swift 
   @objc func respondAction(_ sender: UIButton){
        //postResponse
        if didChooseConcernLevel{
            self.startAnimating()
            let query = PFQuery(className: "Post")
            query.whereKey("objectId", equalTo: objectId)
            query.getFirstObjectInBackground {
                (object: PFObject?, error: Error?) -> Void in
                if error == nil || object != nil {
                    object?["isAnswered"] = true
                    object?["comment"] = self.comments
                    object?["level"] = self.level
                    object?.saveEventually{
                        (success: Bool, error: Error?) -> Void in
                        if (success) {
                            self.chargePatient()
                            
                        } else {
                          SCLAlertView().showError("Issue with Response", subTitle: "Check internet connection and try again")
                        }
                    }
                }
            }
            
        } else {
            SCLAlertView().showNotice("Concern Level?", subTitle: "Choose from Low, Medium, or High")
        }
}

``` 
### [Facebook SDK](https://developers.facebook.com/docs/swift)
* I used Facebook login for a quick and easy login experience

[SignupViewController](https://github.com/doms230/sickcall/blob/master/Celecare/SignupViewController.swift)
```swift
@objc func facebookAction(_ sender: UIBarButtonItem){
    PFFacebookUtils.logInInBackground(withReadPermissions: ["public_profile","email"]){
        (user: PFUser?, error: Error?) -> Void in
        self.startAnimating()
        
            if user.isNew{
                let request = FBSDKGraphRequest(graphPath: "me",parameters: ["fields": "id, name, first_name, last_name, email, gender, picture.type(large)"], tokenString: FBSDKAccessToken.current().tokenString, version: nil, httpMethod: "GET")
                    let _ = request?.start(completionHandler: { (connection, result, error) in
                    guard let userInfo = result as? [String: Any] else { return } //handle the error

                    //The url is nested 3 layers deep into the result so it's pretty messy
                    if let imageURL = ((userInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {

                        if let url = URL(string: imageURL){
                            if let data = NSData(contentsOf: url){
                            self.image = UIImage(data: data as Data)
                            }
                        }
                        let proPic = UIImageJPEGRepresentation(self.image, 0.5)
                        
                        //save new user to database once facebook profile photo is retrieved
                        self.retreivedImage = PFFile(name: "profile_ios.jpeg", data: proPic!)
                        self.retreivedImage?.saveInBackground{
                        (success: Bool, error: Error?) -> Void in
                            if (success){
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
                                    if(success){
                                        self.stopAnimating()
                                        self.goHome()
                                    }
                                }
                            }
                        }
                    }
                })
            } else {
            self.stopAnimating()
            self.goHome()
            }
            
        } else {
        self.stopAnimating()
        }
    }
}
```
### [Kingfisher](https://github.com/onevcat/Kingfisher)
* Kingfisher handles downloading and caching images for you.

### [SCLAlertView](https://github.com/vikmeup/SCLAlertView-Swift)
* Custom animated Alertview

### [BulletinBoard](https://github.com/alexaubry/BulletinBoard)
* General-purpose contextual cards for iOS

### [NVActivityIndicatorView](https://github.com/ninjaprox/NVActivityIndicatorView)
* A collection of awesome loading animations
 
 
