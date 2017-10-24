//
//  InfoTableViewCell.swift
//  Celecare
//
//  Created by Dominic Smith on 10/17/17.
//  Copyright © 2017 Celecare LLC. All rights reserved.
//

import UIKit
import SnapKit

class InfoTableViewCell: UITableViewCell {

    //address
    
    lazy var streetlabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
        label.text = "Street Address"
        label.textColor = UIColor.black
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    lazy var line1Text: UITextField = {
        let label = UITextField()
        label.placeholder = "Street Address"
        label.backgroundColor = .white
        label.font = UIFont(name: "HelveticaNeue", size: 17)
        label.clearButtonMode = .whileEditing
        label.borderStyle = .roundedRect
        return label
    }()
    
    lazy var line2Text: UITextField = {
        let label = UITextField()
        label.placeholder = "Apt, building, etc."
        label.backgroundColor = .white
        label.font = UIFont(name: "HelveticaNeue", size: 17)
        label.clearButtonMode = .whileEditing
        label.borderStyle = .roundedRect
        return label
    }()
    
    lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
        label.text = "City"
        label.textColor = UIColor.black
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    lazy var cityText: UITextField = {
        let label = UITextField()
        label.placeholder = "City"
        label.backgroundColor = .white
        label.font = UIFont(name: "HelveticaNeue", size: 17)
        label.clearButtonMode = .whileEditing
        label.borderStyle = .roundedRect
        return label
    }()
    
    lazy var zipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
        label.text = "Zip Code"
        label.textColor = UIColor.black
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    lazy var zipText: UITextField = {
        let label = UITextField()
        label.placeholder = "Zip Code"
        label.backgroundColor = .white
        label.font = UIFont(name: "HelveticaNeue", size: 17)
        label.clearButtonMode = .whileEditing
        label.borderStyle = .roundedRect
        label.keyboardType = .numberPad
        return label
    }()
    
    lazy var statelabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

       configureAddress()
        
    }
    
    // We won’t use this but it’s required for the class to compile
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    func configureAddress(){
        self.addSubview(streetlabel)
        self.addSubview(line1Text)
        self.addSubview(line2Text)
        self.addSubview(cityLabel)
        self.addSubview(cityText)
        self.addSubview(zipLabel)
        self.addSubview(zipText)
        self.addSubview(statelabel)
        self.addSubview(stateButton)
        
        streetlabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self).offset(20)
            make.left.equalTo(self).offset(10)
            make.right.equalTo(self).offset(-10)
        }
        
        line1Text.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.streetlabel.snp.bottom).offset(5)
            make.left.equalTo(self).offset(10)
            make.right.equalTo(self).offset(-10)
        }
        
        line2Text.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.line1Text.snp.bottom).offset(5)
            make.left.equalTo(self).offset(10)
            make.right.equalTo(self).offset(-10)
        }
        
        cityLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.line2Text.snp.bottom).offset(10)
            make.left.equalTo(self).offset(10)
            make.right.equalTo(self).offset(-10)
        }
        
        cityText.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.cityLabel.snp.bottom).offset(5)
            make.left.equalTo(self).offset(10)
            make.right.equalTo(self).offset(-10)
        }
        
        statelabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.cityText.snp.bottom).offset(10)
            make.left.equalTo(self).offset(10)
        }
        
        stateButton.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(150)
            make.top.equalTo(self.statelabel.snp.bottom).offset(5)
            make.left.equalTo(self).offset(10)
            //make.bottom.equalTo(self).offset(-20)
        }
        
        zipLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.cityText.snp.bottom).offset(10)
            make.left.equalTo(self.stateButton.snp.right).offset(10)
            make.right.equalTo(self).offset(-10)
        }
        
        zipText.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.zipLabel.snp.bottom).offset(5)
            make.left.equalTo(self.stateButton.snp.right).offset(10)
            make.right.equalTo(self).offset(-10)
            make.bottom.equalTo(self).offset(-20)
        }
    }
}
