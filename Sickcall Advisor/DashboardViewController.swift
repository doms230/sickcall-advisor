//
//  DashboardViewController.swift
//  Sickcall
//
//  Created by Dom Smith on 7/14/17.
//  Copyright © 2017 Sickcall LLC All rights reserved.
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
import BulletinBoard
import UserNotifications

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable {
    
    let color = Color()
    
    var medLabel = [String]()
    var medDuration = [String]()
    var userId: String!
    var objectId: String!
    var videoFile: PFFile!
    var firstNameString: String!
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    var selectedIndex = 0
    
    var answerButton: UIButton!
    
    var advisorRec = ""
    
    var isOnline = false
    var isActive = false
    var hasProfile = false
    
    var connectId: String!
    var isConnected = false
    
    var needBankInfo = false
    var didLoad = false
    
    var payments = 0.00
    
    @IBOutlet weak var tableJaunt: UITableView!
        
    let liveQueryClient = ParseLiveQuery.Client()
    var subscription: Subscription<Post>?
    var questionsQuery: PFQuery<Post>{
        return (Post.query()!
            .whereKey("isRemoved", equalTo: false) as! PFQuery<Post> )
    }
    
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
        
        let installation = PFInstallation.current()
        installation?.badge = 0
        installation?.saveInBackground()
        
        self.startQuestionSubscription()

        if UserDefaults.standard.object(forKey: "notifications") == nil{
            self.notificationsManager.prepare()
            self.notificationsManager.presentBulletin(above: self)
        }
        
        self.title = "Dashboard"
        
        self.tableJaunt.register(AdvisorTableViewCell.self, forCellReuseIdentifier: "dashboardReuse")
        self.tableJaunt.estimatedRowHeight = 50
        self.tableJaunt.rowHeight = UITableViewAutomaticDimension
        
        super.viewDidLoad()
        NVActivityIndicatorView.DEFAULT_TYPE = .ballScaleMultiple
        NVActivityIndicatorView.DEFAULT_COLOR = color.sickcallGreen()
        NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE = CGSize(width: 60, height: 60)
        NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        startAnimating()
        
        loadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditProfile"{
            let desti = segue.destination as! EditProfileViewController
            desti.nameString = firstNameString
        }
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
        
        cell.paymentAmount.text = "$\(payments)0"
        
        if !hasProfile{
            cell.queueLabel.text = "Verify that you're a registered nurse."
            cell.statusButton.setTitle("Get Started", for: .normal)
            cell.statusButton.backgroundColor = color.newColor(0xc0392b)
            cell.statusButton.setTitleColor(.white, for: .normal)
            cell.statusButton.tag = 0
            
        } else if !isActive{
            cell.queueLabel.text = "We'll email you via your Sickcall email when we're finished!"
            cell.statusButton.setTitle("RN Verification Pending", for: .normal)
            cell.statusButton.backgroundColor = color.newColor(0x2c3e50)
            cell.statusButton.setTitleColor(UIColor.white, for: .normal)
            cell.statusButton.isEnabled = false
            cell.statusButton.tag = 0
            
        } else if !isConnected{
            cell.queueLabel.text = "You're almost there!"
            cell.statusButton.setTitle("Complete My Setup", for: .normal)
            cell.statusButton.backgroundColor = color.newColor(0xf39c12)
            cell.statusButton.setTitleColor(.white, for: .normal)
            cell.statusButton.tag = 1
            
        } else if needBankInfo{
            cell.queueLabel.text = "Update your bank account"
            cell.statusButton.setTitle("Link Your Bank", for: .normal)
            cell.statusButton.backgroundColor = color.newColor(0xc0392b)
            cell.statusButton.setTitleColor(.white, for: .normal)
            cell.statusButton.tag = 2
            
        } else if isOnline{
            cell.queueLabel.text = "You're in queue for a question"
            cell.statusButton.setTitle("Online", for: .normal)
            cell.statusButton.backgroundColor = color.sickcallGreen()
            cell.statusButton.setTitleColor(.white, for: .normal)
            cell.statusButton.tag = 3
            
        } else {
            cell.queueLabel.text = "Start answering questions to make money"
            cell.statusButton.setTitle("Go Online", for: .normal)
            cell.statusButton.backgroundColor = color.sickcallBlack()
            cell.statusButton.setTitleColor(.black, for: .normal)
            cell.statusButton.tag = 3
        }
        
        cell.statusButton.addTarget(self, action: #selector(DashboardViewController.statusAction(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func statusAction(_ sender: UIButton){
        if sender.tag == 0{
            self.performSegue(withIdentifier: "showNewAdvisor", sender: self)
            
        } else if sender.tag == 1{
            self.performSegue(withIdentifier: "showEditProfile", sender: self)
            
        } else if sender.tag == 2{
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
     
    func loadData(){
        let userId = PFUser.current()?.objectId
        let query = PFQuery(className: "Advisor")
        query.whereKey("userId", equalTo: userId!)
        query.getFirstObjectInBackground {
            (object: PFObject?, error: Error?) -> Void in
            self.didLoad = true
            if error == nil || object != nil {
                self.firstNameString = object?["first"] as! String
                self.hasProfile = true
                self.isOnline = object?["isOnline"] as! Bool
                self.connectId = object?["connectId"] as! String
                self.isActive = object?["isActive"] as! Bool
                
                if self.isActive{
                    if self.connectId == ""{
                        self.didLoad = true
                        self.stopAnimating()
                        
                    } else {
                        self.isConnected = true
                        self.getAccountInfo()
                        self.getTransfers()
                    }
                }
                self.tableJaunt.reloadData()
                self.stopAnimating()
                
            } else{
                self.tableJaunt.reloadData()
                self.stopAnimating()
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
                    self.tableJaunt.reloadData()
                }
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
}
