//
//  CustomTextField.swift
//  ChatAppDemo
//
//  Created by BeeTech on 15/12/2022.
//


import UIKit

class CustomTextField: UITextField {
    override func awakeFromNib() {
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [.foregroundColor: UIColor.brown])
        
    }
   
    
   
}
