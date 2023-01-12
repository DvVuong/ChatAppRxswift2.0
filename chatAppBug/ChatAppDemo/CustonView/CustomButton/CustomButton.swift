//
//  CustomButton.swift
//  ChatAppDemo
//
//  Created by BeeTech on 15/12/2022.
//

import UIKit


class CustomButton: UIButton {
    override func awakeFromNib() {
        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true
        self.setTitle("", for: .normal)
    }
}
