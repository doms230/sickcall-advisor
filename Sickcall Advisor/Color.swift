//
//  Color.swift
//  Sickcall Advisor
//
//  Created by Dominic Smith on 1/22/18.
//  Copyright © 2018 Sickcall LLC. All rights reserved.
//

import UIKit

public class Color{
    
    func red(_ rgbValue: UInt32) -> CGFloat{
        return CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
    }
    
    func green(_ rgbValue: UInt32) -> CGFloat{
        return CGFloat((rgbValue & 0xFF00) >> 8)/256.0
    }
    
    func blue(_ rgbValue: UInt32) -> CGFloat{
        return CGFloat(rgbValue & 0xFF)/256.0
    }
    
    //
    func newColor(_ rgbValue : UInt32) -> UIColor{
        return UIColor(red: red(rgbValue), green:green(rgbValue), blue: blue(rgbValue), alpha: 1.0)
    }
    
    func sickcallGreen() -> UIColor{
        let rgbValue: UInt32 = 0x006a52
        return UIColor(red: red(rgbValue), green: green(rgbValue), blue: blue(rgbValue), alpha: 1.0)
    }
    
    func sickcallTan() -> UIColor{
        let rgbValue: UInt32 = 0xe8e6df
        return UIColor(red: red(rgbValue), green: green(rgbValue), blue: blue(rgbValue), alpha :1.0)
    }
    
    func sickcallBlack() -> UIColor{
        let rgbValue: UInt32 = 0x180d22
        return UIColor(red: red(rgbValue), green: green(rgbValue), blue: blue(rgbValue), alpha :1.0)
    }
}
