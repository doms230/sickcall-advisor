//
//  NewSSNViewController.swift
//  Celecare
//
//  Created by Dominic Smith on 10/17/17.
//  Copyright © 2017 Celecare LLC. All rights reserved.
//

import UIKit
import SnapKit

class NewSSNViewController: UIViewController {
    
    lazy var ssnLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
        label.text = "Social Security Number"
        label.textColor = UIColor.black
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    lazy var ssnText: UITextField = {
        let label = UITextField()
        label.placeholder = "Social Security Number"
        label.backgroundColor = .white
        label.font = UIFont(name: "HelveticaNeue", size: 17)
        label.clearButtonMode = .whileEditing
        label.borderStyle = .roundedRect
        label.keyboardType = .numberPad
        return label
    }()
    
    lazy var ssnExplanation: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 12)
        label.text = "Your social security number is needed to verify your identity."
        label.textColor = UIColor.black
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    var line1: String!
    var line2: String!
    var city: String!
    var zipCode: String!
    var state: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "SSN 2/3"
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextAction(_:)))
        self.navigationItem.setRightBarButton(nextButton, animated: true)
        
        configureSSN()
        ssnText.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let desti = segue.destination as! newBankViewController
        desti.line1 = line1
        desti.line2 = line2
        desti.city = city
        desti.zipCode = zipCode
        desti.state = state
        desti.personal_id_number = ssnText.text
    }
    
    @objc func nextAction(_ sender: UIBarButtonItem){
        if validateInput(textField: ssnText){
            self.performSegue(withIdentifier: "showBank", sender: self)
        }
    }

    func configureSSN(){
        self.view.addSubview(ssnLabel)
        self.view.addSubview(ssnText)
        self.view.addSubview(ssnExplanation)
        
        ssnLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(75)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
        }
        
        ssnText.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(ssnLabel.snp.bottom).offset(5)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
        }
        
        ssnExplanation.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(ssnText.snp.bottom).offset(5)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
          //  make.bottom.equalTo(self.view).offset(-20)
        }
    }
    
    func validateInput(textField: UITextField) ->Bool{
        var isValidated = false
        
        if textField.text!.isEmpty{
            
            textField.attributedPlaceholder = NSAttributedString(string:"Field required",
                                                                 attributes:[NSAttributedStringKey.foregroundColor: UIColor.red])
            
        } else if textField.text?.count != 9{
            textField.attributedPlaceholder = NSAttributedString(string:"Valid SSN required",
                                                                 attributes:[NSAttributedStringKey.foregroundColor: UIColor.red])
        } else {
            isValidated = true
        }
        return isValidated
    }
    
}
