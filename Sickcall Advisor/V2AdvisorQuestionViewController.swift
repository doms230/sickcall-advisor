//
//  V2AdvisorQuestionViewController.swift
//  Sickcall
//
//  Created by Dom Smith on 8/14/17.
//  Copyright © 2017 Socialgroupe Incorporated All rights reserved.
//

import UIKit
import SlackTextViewController
import Parse
import NVActivityIndicatorView
import MobileCoreServices
import AVKit
import AVFoundation
import SCLAlertView
import ParseLiveQuery
import Alamofire
import SwiftyJSON

class V2AdvisorQuestionViewController: SLKTextViewController,NVActivityIndicatorViewable {
    var baseURL = "https://celecare.herokuapp.com/posts/assignQuestion"
    var chargeURL = "https://celecare.herokuapp.com/payments/captureCharge"
    
    //advisor
    var advisorUserImage: String!
    var advisorUsername: String!
    var advisorUserId: String!
    var connectId: String!
    
    //patient
    var patientUserImage: String!
    var patientUsername: String!
    var patientUserId: String!
    
    //answer info
    var level: String!
    var comments = ""
    var commentButton = "Add a comment that supports your opinion"
    var optionBody = ""
    var didPressRightButton = false
    var didChooseConcernLevel = false
    
    //question info
    var objectId: String!
    var summary: String!
    var duration: String!
    //var videoJaunt: PFFile!
    var videoPreview: String!
    var chargeId: String!
    
    //video
    var playerItem: AVPlayerItem!
    var player: AVPlayer!
    var playerController: AVPlayerViewController!
    
    /*** In case user presses play before video is loaded */
    var didPressPlay = false
    var didWatchVideo = false
    
    //mich
    let screenSize: CGRect = UIScreen.main.bounds
    var viewQuestionButton: UIButton!
    var respondButton: UIButton!
    
    var isAnswered = false
    
    var cancelQuestionView: SCLAlertView!
    var skipQuestionView: SCLAlertView!
    
    let liveQueryClient = ParseLiveQuery.Client()
    private var subscription: Subscription<Post>?
    var questionsQuery: PFQuery<Post>{
        return (Post.query()!
            .whereKey("advisorUserId", equalTo: PFUser.current()!.objectId!) as! PFQuery<Post> )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.tableView?.register(ViewAnswerTableViewCell.self, forCellReuseIdentifier: "patientReuse")
        self.tableView?.register(AdvisorTableViewCell.self, forCellReuseIdentifier: "noWatchVideoReuse")
        self.tableView?.register(AdvisorTableViewCell.self, forCellReuseIdentifier: "respondReuse")
        self.tableView?.estimatedRowHeight = 50
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.separatorStyle = .none
        
        self.isInverted = false
        self.textView.placeholder = "Comment required to respond"
        self.rightButton.setTitle("Add", for: .normal)
        self.shouldScrollToBottomAfterKeyboardShows = true
        self.setTextInputbarHidden(true, animated: false)
        self.textInputbar.bringSubview(toFront: self.rightButton)
        self.textInputbar.bringSubview(toFront: self.textView)
        
        NVActivityIndicatorView.DEFAULT_TYPE = .ballScaleMultiple
        NVActivityIndicatorView.DEFAULT_COLOR = uicolorFromHex(0x006a52)
        NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE = CGSize(width: 60, height: 60)
        NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        startAnimating()
        
        UIElements()
        self.loadPost()
        setUpAlertView()
        subscribeToUpdates()
        
        let query = PFQuery(className: "Advisor")
        query.whereKey("userId", equalTo: PFUser.current()!.objectId!)
        query.getFirstObjectInBackground {
            (object: PFObject?, error: Error?) -> Void in
            if error == nil || object != nil {
                
                self.connectId = object?["connectId"] as! String
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let desti = segue.destination as! AdvisorMedsViewController
        desti.patientUserId = patientUserId
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.patientUsername == nil{
            return 0
            
        } else {
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        var cell: ViewAnswerTableViewCell!
        var adCell: AdvisorTableViewCell!
        
        if self.patientUsername != nil{
            tableView.separatorStyle = .singleLine
        }
        
        if indexPath.row == 0{
            cell = tableView.dequeueReusableCell(withIdentifier: "patientReuse", for: indexPath) as! ViewAnswerTableViewCell
            
            cell.selectionStyle = .none
            cell.patientImage.kf.setImage(with: URL(string: self.patientUserImage))
            cell.patientName.textColor = uicolorFromHex(0x180d22)
            cell.patientName.text = self.patientUsername
            
            cell.summaryBody.text = self.summary
            cell.summaryBody.textColor = uicolorFromHex(0x180d22)
            cell.durationBody.text = self.duration
            cell.durationBody.textColor = uicolorFromHex(0x180d22)
            
            cell.vitalsButton.backgroundColor = uicolorFromHex(0x8c81ff)
            cell.vitalsButton.addTarget(self, action: #selector(self.showVitals(_:)), for: .touchUpInside)
            
            //TODO: Uncomment
            cell.videoButton.addTarget(self, action: #selector(self.loadPlayJaunt(_:)), for: .touchUpInside)
            cell.videoButton.kf.setImage(with: URL(string: self.videoPreview), for: .normal)
          //  cell.videoImage.kf.setImage(with: URL(string: self.videoPreview))
            
            return cell
        } else if didWatchVideo {
            adCell = tableView.dequeueReusableCell(withIdentifier: "respondReuse", for: indexPath) as! AdvisorTableViewCell
            adCell.selectionStyle = .none
            
            adCell.concernLevelSegment.addTarget(self, action: #selector(self.didPressSegment(_:)), for: .valueChanged)
            
            adCell.optionsBody.text = optionBody
            
            adCell.commentBody.text = comments
            
            adCell.commentButton.setTitle(commentButton, for: .normal)
            adCell.commentButton.addTarget(self, action: #selector(self.addCommentAction(_:)), for: .touchUpInside)
            
            return adCell
        } else {
            adCell = tableView.dequeueReusableCell(withIdentifier: "noWatchVideoReuse", for: indexPath) as! AdvisorTableViewCell
            adCell.selectionStyle = .none
            return adCell
        }
    }
    
    @objc func loadPlayJaunt(_ sender: UIButton){
        if playerItem != nil{
            player.seek(to: kCMTimeZero)
            stopAnimating()
            self.present(playerController, animated: true) {
                self.player.play()
            }
        } else {
            didPressPlay = true
        }
    }
    
    func loadvideo(videoJaunt: PFFile){
        videoJaunt.getDataInBackground {
            (videoData: Data?, error: Error?) -> Void in
            if error == nil {
                if let videoData = videoData {
                    //convert video file to playable format
                    let documentsPath : AnyObject = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as AnyObject
                    let destinationPath:String = documentsPath.appending("/file.mov")
                    try? videoData.write ( to: URL(fileURLWithPath: destinationPath as String), options: [.atomic])
                    self.playerItem = AVPlayerItem(asset: AVAsset(url: URL(fileURLWithPath: destinationPath as String)))
                    self.player = AVPlayer(playerItem: self.playerItem)
                    self.playerController = AVPlayerViewController()
                    self.playerController.player = self.player
                    
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
    
    @objc func playerItemDidReachEnd( _ notification: Notification) {
        player.seek(to: kCMTimeZero)
        viewQuestionButton.isHidden = true
        self.setTextInputbarHidden(false, animated: false)
        didWatchVideo = true
        self.tableView?.reloadData()
    }
    
    @objc func didPressSegment(_ sender: UISegmentedControl){
        switch sender.selectedSegmentIndex{
        case 0:
            optionBody = "- Over the counter solution \n - Doctors Appointment"
            self.level = "low"
            break
        case 1:
            optionBody = "- Doctor's appointment \n - Urgent Care"
            self.level = "medium"
            break
        case 2:
            optionBody = "- Emergency Room \n - Urgent Care \n - Same Day Doctor's Appointment"
            self.level = "high"
            break
        default:
            optionBody = "- Emergency Room \n - Urgent Care \n - Same Day Doctor's Appointment"
            self.level = "high"
            break
        }
        didChooseConcernLevel = true
        self.tableView?.reloadData()
    }
    
    @objc func addCommentAction(_ sender: UIButton){
        if didPressRightButton{
            self.textView.becomeFirstResponder()
            self.textView.text = comments
            self.textView.isHidden = false
            self.respondButton.removeFromSuperview()
        } else {
            self.textView.becomeFirstResponder()
        }
    }
    
    override func didPressRightButton(_ sender: Any?) {
        //add comment and change comment button to Edit comment
        comments = self.textView.text
        commentButton = "Edit Comment"
        
        //clear and hide input text box
        self.textView.text = ""
        self.textView.isHidden = true
        self.textView.resignFirstResponder()

        //comment exists
        didPressRightButton = true
        
        self.tableView?.reloadData()
        
        //so user can post response
        self.view.addSubview(respondButton)
    }
    
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
                           SCLAlertView().showError("Issue with Responding", subTitle: "Check internet connection and try again")
                        }
                    }
                }
            }
            
        } else {
            SCLAlertView().showNotice("Concern Level?", subTitle: "Choose from Low, Medium, or High")
        }
    }
    
    func loadPost(){
        let query = PFQuery(className: "Post")
        query.whereKey("advisorUserId", equalTo: PFUser.current()!.objectId!)
        query.whereKey("isAnswered", equalTo: false)
        query.whereKey("isRemoved", equalTo: false)
        query.addAscendingOrder("createdAt")
        query.getFirstObjectInBackground {
            (object: PFObject?, error: Error?) -> Void in
            if error == nil || object != nil {
                self.summary = object?["summary"] as! String
                self.duration = object?["duration"] as! String
                let videoJaunt = object?["video"] as! PFFile
                self.loadvideo(videoJaunt: videoJaunt)
                let videoPreview = object?["videoScreenShot"] as! PFFile
                self.videoPreview = videoPreview.url
                self.patientUserId = object?["userId"] as! String
                self.chargeId = object?["chargeId"] as! String
                self.objectId = object?.objectId
                self.loadPatient()
            }
        }
    }
    
    func loadPatient(){
        let query = PFQuery(className: "_User")
        query.whereKey("objectId", equalTo: PFUser.current()!.objectId!)
        query.getFirstObjectInBackground {
            (object: PFObject?, error: Error?) -> Void in
            if error == nil || object != nil {
                
                let imageFile: PFFile = object!["Profile"] as! PFFile
                self.patientUserImage = imageFile.url
                
                self.patientUsername = object!["DisplayName"] as! String
                
                self.tableView?.reloadData()
                self.stopAnimating()
            }
        }
    }
    
    @objc func showVitals(_ sender: UIButton){
        self.performSegue(withIdentifier: "showVitals", sender: self)
    }
    
    //mich 
    
    func subscribeToUpdates(){
        self.subscription = self.liveQueryClient
            .subscribe(self.questionsQuery)
            .handle(Event.updated) { _, object in
                
                let isRemoved = object["isRemoved"] as! Bool
                
                if isRemoved{
                    let prompt = UIAlertController(title: "Canceled", message: "Your patient canceled their question.", preferredStyle: .alert)
                    
                    let search = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel) {
                        UIAlertAction in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let controller = storyboard.instantiateViewController(withIdentifier: "main")
                        self.present(controller, animated: true, completion: nil)
                    }
                    
                    prompt.addAction(search)
                    self.present(prompt, animated: true, completion: nil)
                }
        }
    }
    
    func UIElements(){
        viewQuestionButton = UIButton(frame: CGRect(x: 0, y: screenSize.height-50, width: screenSize.width, height: 50))
        viewQuestionButton.setTitleColor(.white, for: .normal)
        viewQuestionButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        viewQuestionButton.titleLabel?.textAlignment = .center
        viewQuestionButton.setTitle("View Question", for: .normal)
        viewQuestionButton.backgroundColor = uicolorFromHex(0x006a52)
        viewQuestionButton.addTarget(self, action: #selector(self.loadPlayJaunt(_:)), for: .touchUpInside)
        self.view.addSubview(viewQuestionButton)

        respondButton = UIButton(frame: CGRect(x: 0, y: screenSize.height-50, width: screenSize.width, height: 50))
        respondButton.setTitleColor(.white, for: .normal)
        respondButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        respondButton.titleLabel?.textAlignment = .center
        respondButton.setTitle("Respond", for: .normal)
        respondButton.backgroundColor = uicolorFromHex(0x006a52)
        respondButton.addTarget(self, action: #selector(self.respondAction(_:)), for: .touchUpInside)
 
    }
    
    func setUpAlertView(){
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false
        )
        
        cancelQuestionView = SCLAlertView(appearance: appearance)
        cancelQuestionView.addButton("Okay"){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "main")
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelQuestionAction(_ sender: UIBarButtonItem) {
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false
        )
        
        skipQuestionView = SCLAlertView(appearance: appearance)
        skipQuestionView.addButton("YES"){
            self.backEndIsh()
        }
        
        skipQuestionView.addButton("NO"){
            
        }
        
        skipQuestionView.showNotice("Skip this Question?", subTitle: "")
    }
    
    func backEndIsh(){
        startAnimating()
        
        Alamofire.request(self.baseURL, method: .post, parameters: ["id": objectId], encoding: JSONEncoding.default).validate().response{response in
            self.stopAnimating()
            print(response)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "main")
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func chargePatient(){
        Alamofire.request(self.chargeURL, method: .post, parameters: ["charge": chargeId, "connectId": connectId, "user": self.patientUserId], encoding: JSONEncoding.default).validate().response{response in
            self.stopAnimating()
            print(response)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "main")
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func uicolorFromHex(_ rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
}
