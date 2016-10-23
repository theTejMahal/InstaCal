//
//  DesignableButton.swift
//  InstaCal
//
//  Created by Jet on 10/22/16.
//  Copyright © 2016 InstaCal. All rights reserved.
//

import UIKit

@IBDesignable class DesignableButton : UIButton {
    
    // Corner Radius
    @IBInspectable var cornerRadius : CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }
    
    // Border Width
    @IBInspectable var borderWidth : CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    // Border Color
    @IBInspectable var borderColor : UIColor = UIColor.clear {
        didSet{
            layer.borderColor = borderColor.cgColor
        }
    }
    
}
