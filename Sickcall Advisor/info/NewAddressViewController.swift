//
//  NewAddressViewController.swift
//  Celecare
//
//  Created by Dominic Smith on 10/17/17.
//  Copyright © 2017 Celecare LLC. All rights reserved.
//

import UIKit
import SnapKit

class NewAddressViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var tableJaunt: UITableView!

    var didChooseState = false
    
    var line1: UITextField!
    var line2: UITextField!
    var city: UITextField!
    var zipCode: UITextField!
    var state: UIButton!
    
    let states = ["","Alabama","Alaska","Arizona","Arkansas","California","Colorado","Connecticut","Delaware","Florida","Georgia","Hawaii","Idaho"," Illinois","Indiana","Iowa","Kansas","Kentucky", "Louisiana","Maine","Maryland","Massachusetts","Michigan","Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire","New Jersey","New Mexico","New York","North Carolina","North Dakota","Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island","South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont","Virginia","Washington","West Virginia","Wisconsin","Wyoming"]
    
    var row = 0
    var statePrompt: UIAlertController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Address 1/3"
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextAction(_:)))
        self.navigationItem.setRightBarButton(nextButton, animated: true)
        nextButton.tag = 0
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(nextAction(_:)))
        self.navigationItem.setLeftBarButton(cancelButton, animated: true)
        cancelButton.tag = 1
        
        self.tableJaunt = UITableView(frame: self.view.bounds)
        self.tableJaunt.dataSource = self
        self.tableJaunt.delegate = self
        self.tableJaunt.register(InfoTableViewCell.self, forCellReuseIdentifier: "addressReuse")
        self.tableJaunt.estimatedRowHeight = 50
        self.tableJaunt.rowHeight = UITableViewAutomaticDimension
        self.tableJaunt.keyboardDismissMode = .onDrag
        self.tableJaunt.backgroundColor = uicolorFromHex(0xE8E6DF)
        self.tableJaunt.separatorStyle = .none
        self.view.addSubview(self.tableJaunt)
        
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let desti = segue.destination as! NewSSNViewController
        desti.line1 = line1.text
        desti.line2 = line2.text
        desti.city = city.text
        desti.zipCode = zipCode.text
        desti.state = state.titleLabel?.text
    }

    //tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressReuse", for: indexPath) as! InfoTableViewCell
        cell.selectionStyle = .none
        cell.backgroundColor = uicolorFromHex(0xE8E6DF)
        
        line1 = cell.line1Text
        line2 = cell.line2Text
        city = cell.cityText
        zipCode = cell.zipText
        
        cell.line1Text.becomeFirstResponder()
        cell.stateButton.addTarget(self, action: #selector(stateAction(_:)), for: .touchUpInside)
        state = cell.stateButton
        
        return cell
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
        state.setTitle(" \(states[row])", for: .normal)
         state.setTitleColor(.black, for: .normal)
        //self.state = states[row]
        //self.row = row
        self.tableJaunt.reloadData()
        
        if states[row] != ""{
            didChooseState = true
        }
    }
    
    @objc func nextAction(_ sender: UIBarButtonItem){
        if sender.tag == 0{
            if validateInput(textField: line1) && validateInput(textField: city) && validateInput(textField: zipCode) && validateStateButton(){
                self.performSegue(withIdentifier: "showSSN", sender: self)
            }
            
        } else {
            //cancel
            let storyboard = UIStoryboard(name: "Advisor", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "container") as! AdvisorContainerViewController
            controller.isAdvisor = true
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    //validation
    func validateInput(textField: UITextField) ->Bool{
        var isValidated = false
        
        if textField.text!.isEmpty{
            
            textField.attributedPlaceholder = NSAttributedString(string:"Field required",
                                                                     attributes:[NSAttributedStringKey.foregroundColor: UIColor.red])
        } else{
            isValidated = true
        }
        return isValidated
    }
    
    func validateStateButton() ->Bool{
        var isStateValidated = false
        
        if !didChooseState{
            state.setTitle(" Field Required", for: .normal)
            state.setTitleColor(.red, for: .normal)
            
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
