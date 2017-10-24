//
//  DashboardViewController.swift
//  Sickcall
//
//  Created by Dom Smith on 7/14/17.
//  Copyright © 2017 Socialgroupe Incorporated All rights reserved.
//

import UIKit
import Parse
import SidebarOverlay
import ParseLiveQuery
import SnapKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import SCLAlertView
import Kingfisher

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable {
    
    var medLabel = [String]()
    var medDuration = [String]()
    var userId: String!
    var objectId: String!
    var videoFile: PFFile!
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    var selectedIndex = 0
    
    var answerButton: UIButton!
    
    var advisorRec = ""
    
    var isOnline = false
    
    var connectId: String!
    var isConnected = false
    
    var needBankInfo = false
    var didLoad = false
    
    var payments = 0.00
    
    @IBOutlet weak var tableJaunt: UITableView!
    
    let liveQueryClient = ParseLiveQuery.Client()
    private var subscription: Subscription<Post>?
    var questionsQuery: PFQuery<Post>{
        return (Post.query()!
        .whereKey("isRemoved", equalTo: false) as! PFQuery<Post> )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startQuestionSubscription()
        
        self.title = "Dashboard"
        
        self.tableJaunt.register(AdvisorTableViewCell.self, forCellReuseIdentifier: "dashboardReuse")
        self.tableJaunt.estimatedRowHeight = 50
        self.tableJaunt.rowHeight = UITableViewAutomaticDimension
        self.tableJaunt.backgroundColor = uicolorFromHex(0xe8e6df)
        
        super.viewDidLoad()
        NVActivityIndicatorView.DEFAULT_TYPE = .ballScaleMultiple
        NVActivityIndicatorView.DEFAULT_COLOR = uicolorFromHex(0x006a52)
        NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE = CGSize(width: 60, height: 60)
        NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        startAnimating()
        
        loadData()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if didLoad{
            return 1
            
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dashboardReuse", for: indexPath) as! AdvisorTableViewCell
        
        cell.backgroundColor = uicolorFromHex(0xe8e6df)
        
        cell.paymentAmount.text = "$\(payments)0"
        
        if !isConnected{
            cell.queueLabel.text = "You're almost there!"
            cell.statusButton.setTitle("Complete my Setup", for: .normal)
            cell.statusButton.backgroundColor = uicolorFromHex(0xcf3812)
            cell.statusButton.setTitleColor(.white, for: .normal)
            cell.statusButton.tag = 0
            
        } else if needBankInfo{
            cell.queueLabel.text = "Update your bank account"
            cell.statusButton.setTitle("Link Your Bank", for: .normal)
            cell.statusButton.backgroundColor = uicolorFromHex(0xcf3812)
            cell.statusButton.setTitleColor(.white, for: .normal)
            cell.statusButton.tag = 1
            
        } else if isOnline{
            cell.queueLabel.text = "You're in queue for a question"
            cell.statusButton.setTitle("Online", for: .normal)
            cell.statusButton.backgroundColor = uicolorFromHex(0x180d22)
            cell.statusButton.setTitleColor(.white, for: .normal)
            
        } else {
            cell.queueLabel.text = "Start answering questions to make money"
            cell.statusButton.setTitle("Go Online", for: .normal)
            cell.statusButton.backgroundColor = .white
            cell.statusButton.setTitleColor(.black, for: .normal)
        }
        
        cell.statusButton.addTarget(self, action: #selector(DashboardViewController.statusAction(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func statusAction(_ sender: UIButton){
        if sender.tag == 0{
            self.performSegue(withIdentifier: "showNewBank", sender: self)
            
        } else if sender.tag == 1{
            self.performSegue(withIdentifier: "showBank", sender: self)
            
        } else {
            if isOnline{
                isOnline = false
                
            } else {
                isOnline = true
            }
            
            let userId = PFUser.current()?.objectId
            let query = PFQuery(className: "Advisor")
            query.whereKey("userId", equalTo: userId!)
            query.getFirstObjectInBackground {
                (object: PFObject?, error: Error?) -> Void in
                if error == nil || object != nil {
                    
                    object?["isOnline"] = self.isOnline
                    if self.isOnline{
                        object?["questionQueue"] = Date()
                    }
                    
                    object?.saveInBackground {
                        (success: Bool, error: Error?) -> Void in
                        if (success) {
                            //do something
                        }
                    }
                    
                    self.tableJaunt.reloadData()
                    
                } else{
                    //your offline message
                }
            }
        }
    }

    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }
    
    func startQuestionSubscription(){
        self.subscription = self.liveQueryClient
            .subscribe(self.questionsQuery)
            .handle(Event.updated) { _, object in
                //print(object)
                let user = object["advisorUserId"] as! String
                if user == PFUser.current()?.objectId{
                    let storyboard = UIStoryboard(name: "Advisor", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "question")
                    self.present(controller, animated: true, completion: nil)
                }
        }
    }
     
    //TODO: change userId to something proper
    func loadData(){
        let userId = PFUser.current()?.objectId
        let query = PFQuery(className: "Advisor")
        query.whereKey("userId", equalTo: userId!)
        query.getFirstObjectInBackground {
            (object: PFObject?, error: Error?) -> Void in
            if error == nil || object != nil {
                /*if object?["isOnline"] as! Bool{
                    self.isOnline = true
                }*/
                
                self.connectId = object?["connectId"] as! String
                
                if self.connectId == ""{
                    self.didLoad = true
                    self.tableJaunt.reloadData()
                    self.stopAnimating()
                
                } else {
                    self.isConnected = true
                    self.getAccountInfo()
                    self.getTransfers()
                    self.tableJaunt.reloadData()
                }
                
            } else{
                //you're not connected to the internet message
            }
        }
    }
    
    func getAccountInfo(){
        
        //class won't compile with textfield straight in parameters so has to be put to string first
        let p: Parameters = [
            "account_Id": connectId,
            ]
        let url = "https://celecare.herokuapp.com/payments/account"
        Alamofire.request(url, parameters: p, encoding: URLEncoding.default).validate().responseJSON { response in switch response.result {
        case .success(let data):
            let json = JSON(data)
            print("JSON: \(json)")
            self.stopAnimating()
            self.didLoad = true
            //can't get status code for some reason
            if let status = json["statusCode"].int{
                print(status)
                let message = json["message"].string
                SCLAlertView().showError("Something Went Wrong", subTitle: message!)
                
            } else {
                for object in json["verification"]["fields_needed"].arrayObject! {
                    print(object as! String)
                    if object as! String == "external_account"{
                     self.needBankInfo = true
                    }
                }
                self.tableJaunt.reloadData()
            }
            
        case .failure(let error):
            self.stopAnimating()
            print(error)
            SCLAlertView().showError("Something Went Wrong", subTitle: "")
            
            }
        }
    }
    
    func getTransfers(){
        
        let query = PFQuery(className:"Post")
        query.whereKey("advisorUserId", equalTo: PFUser.current()!.objectId!)
        query.whereKey("isAnswered", equalTo: true)
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        let weds = self.get(direction: .Previous, "Wednesday", considerToday: false)
                        print(weds)
                        let createdAt = object.createdAt!
                        print(createdAt)
                        if createdAt.compare(weds as Date) == .orderedDescending {
                            self.payments = self.payments + 5.00
                        }
                    }
                    // print(self.unAnsweredQuestionTitle[0])
                    
                    self.tableJaunt.reloadData()
                    
                }
            } else {
                // Log details of the failure
                print("Error: \(error!)")
            }
        }
    }
    
    //for figuring out previous weds .. see https://stackoverflow.com/questions/33397101/how-to-get-mondays-date-of-the-current-week-in-swift
    func getWeekDaysInEnglish() -> [String] {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        calendar.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        return calendar.weekdaySymbols
    }
    
    enum SearchDirection {
        case Next
        case Previous
        
        var calendarOptions: NSCalendar.Options {
            switch self {
            case .Next:
                return .matchNextTime
            case .Previous:
                return [.searchBackwards, .matchNextTime]
            }
        }
    }
    
    func get(direction: SearchDirection, _ dayName: String, considerToday consider: Bool = false) -> NSDate {
        let weekdaysName = getWeekDaysInEnglish()
        
        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
        
        let nextWeekDayIndex = weekdaysName.index(of: dayName)! + 1 // weekday is in form 1 ... 7 where as index is 0 ... 6
        
        let today = NSDate()
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        if consider && calendar.component(.weekday, from: today as Date) == nextWeekDayIndex {
            return today
        }
        
        let nextDateComponent = NSDateComponents()
        nextDateComponent.weekday = nextWeekDayIndex
        
        
        let date = calendar.nextDate(after: today as Date, matching: nextDateComponent as DateComponents, options: direction.calendarOptions)
        return date! as NSDate
    }
    
    func uicolorFromHex(_ rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
}
