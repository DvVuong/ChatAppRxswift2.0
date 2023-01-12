//
//  CustomView.swift
//  ChatAppDemo
//
//  Created by BeeTech on 19/12/2022.
//

import UIKit
class CustomView: UIView {
    override func awakeFromNib() {
        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true
    }
}
