//
//  CustomStackView.swift
//  ChatAppDemo
//
//  Created by BeeTech on 16/12/2022.
//

import UIKit
class CustomStackView: UIStackView {
    override func awakeFromNib() {
        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
    }
}
