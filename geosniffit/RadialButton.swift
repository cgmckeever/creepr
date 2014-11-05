//
//  CustomButton.swift
//  geosniffit
//
//  Created by cgmckeever on 11/2/14.
//  Copyright (c) 2014 cgmckeever. All rights reserved.
//

import UIKit

@IBDesignable class RadialButton: UIButton {
    @IBInspectable var borderColor: UIColor = UIColor.clearColor(){
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
