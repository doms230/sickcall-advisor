//
//  QualificationsViewController.swift
//  Sickcall
//
//  Created by Dom Smith on 8/6/17.
//  Copyright © 2017 Socialgroupe Incorporated All rights reserved.
//

import UIKit
import SnapKit

class QualificationsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
        label.text = "Qualifications"
        label.textColor = UIColor.black
        label.numberOfLines = 0
        return label
    }()
    
    lazy var licenseLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 20)
        label.text = "License Number"
        label.textColor = UIColor.black
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    lazy var licenseText: UITextField = {
        let label = UITextField()
        label.placeholder = "RN-12345"
        label.backgroundColor = .white
        label.font = UIFont(name: "HelveticaNeue", size: 17)
        label.clearButtonMode = .whileEditing
        label.borderStyle = .roundedRect
        return label
    }()
    
    lazy var stateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 20)
        label.text = "State"
        label.textColor = UIColor.black
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    lazy var stateButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 17)
        button.backgroundColor = .white
        button.layer.cornerRadius = 4
        button.titleLabel?.textAlignment = .left
        button.clipsToBounds = true
        return button
    }()
    
    //Name Values from NameViewController
    var firstName: String!
    var lastName: String!
    
    //Qualifications
    //@IBOutlet weak var licenseNumberText: UITextField!
    //@IBOutlet weak var licenseTypeButton: UIButton!
    //@IBOutlet weak var stateButton: UIButton!
    
    //picker view values
    var statePrompt: UIAlertController!
    var licenseTypePrompt: UIAlertController!
    var didChooseState = false
    
    let states = ["","Alabama","Alaska","Arizona","Arkansas","California","Colorado","Connecticut","Delaware","Florida","Georgia","Hawaii","Idaho"," Illinois","Indiana","Iowa","Kansas","Kentucky", "Louisiana","Maine","Maryland","Massachusetts","Michigan","Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire","New Jersey","New Mexico","New York","North Carolina","North Dakota","Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island","South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont","Virginia","Washington","West Virginia","Wisconsin","Wyoming"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "2/3"
        
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextAction(_:)))
        self.navigationItem.setRightBarButton(nextButton, animated: true)
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(licenseLabel)
        self.view.addSubview(licenseText)
        self.view.addSubview(stateLabel)
        self.view.addSubview(stateButton)
        stateButton.addTarget(self, action: #selector(stateAction(_:)), for: .touchUpInside)
        
        titleLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(75)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
        }
        
        licenseLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(self.view).offset(10)
        }
        
        licenseText.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(licenseLabel.snp.top)
            make.left.equalTo(self.view).offset(165)
            make.right.equalTo(self.view).offset(-10)
        }
        
        stateLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(licenseText.snp.bottom).offset(10)
            make.left.equalTo(self.view).offset(10)
        }
        
        stateButton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(30)
            make.top.equalTo(stateLabel.snp.top)
            make.left.equalTo(self.view).offset(165)
            make.right.equalTo(self.view).offset(-10)
        }
        
        licenseText.becomeFirstResponder()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let desti = segue.destination as! IDViewController
        desti.firstName = firstName
        desti.lastName = lastName
        desti.licenseNumber = licenseText.text!
        desti.state = stateButton.titleLabel?.text!
    }
 
    @objc func nextAction(_ sender: UIBarButtonItem){
        if validateLicenseNumber() && validateStateButton(){
            performSegue(withIdentifier: "showId", sender: self)
        }
    }
    
    @objc func stateAction(_ sender: UIButton) {
        
        statePrompt = UIAlertController(title: "Choose State", message: "", preferredStyle: .actionSheet)
        
        let statePickerView: UIPickerView = UIPickerView()
        statePickerView.delegate = self
        statePickerView.dataSource = self
        statePrompt.view.addSubview(statePickerView)
        
        let space = UIAlertAction(title: "", style: UIAlertActionStyle.default) {
            UIAlertAction in
        }
        
        space.isEnabled = false
        
        statePrompt.addAction(space)
        
        let height:NSLayoutConstraint = NSLayoutConstraint(item: statePrompt.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.view.frame.height * 0.6)
        
        statePrompt.view.addConstraint(height);
        
        let okayJaunt = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            
        }
        
        statePrompt.addAction(okayJaunt)
        
        present(statePrompt, animated: true, completion: nil)
    }
    
    //picker view stuff
    
    // data method to return the number of column shown in the picker.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // data method to return the number of row shown in the picker.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return states.count
    }
    
    // delegate method to return the value shown in the picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return states[row]
    }
    
    // delegate method called when the row was selected.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        stateButton.setTitle(" \(states[row])", for: .normal)
        stateButton.setTitleColor(.black, for: .normal)
        
        if states[row] != ""{
            didChooseState = true 
        }
    }
    
    //validation tests 
    func validateLicenseNumber() ->Bool{
        var isValidated = false
        
        if licenseText.text!.isEmpty{
            
            licenseText.attributedPlaceholder = NSAttributedString(string:" Field required",
                                                                         attributes:[NSAttributedStringKey.foregroundColor: UIColor.red])
            
        } else{
            isValidated = true
        }
        return isValidated
    }
    
    func validateStateButton() ->Bool{
        var isStateValidated = false
        
        if !didChooseState{
            stateButton.setTitle(" Field Required", for: .normal)
            stateButton.setTitleColor(.red, for: .normal)
            
        } else{
            isStateValidated = true
        }
        print("validation: \(isStateValidated)")
        return isStateValidated
    }
    
    //mich.
    func uicolorFromHex(_ rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
}
