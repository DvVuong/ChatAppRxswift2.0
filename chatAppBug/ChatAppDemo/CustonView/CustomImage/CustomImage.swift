//
//  CustomImage.swift
//  ChatAppDemo
//
//  Created by BeeTech on 15/12/2022.
//

import UIKit
class CustomImage: UIImageView {
    override func awakeFromNib() {
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        self.contentMode = .scaleToFill
    }
}
