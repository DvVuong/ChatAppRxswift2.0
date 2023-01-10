//
//  ListCellPresenter.swift
//  ChatAppDemo
//
//  Created by BeeTech on 09/12/2022.
//

import UIKit
final class ListCellPresenter {
    static var shared = ListCellPresenter()
    
    func setHiglight(_ search: String, _ text: String) -> NSAttributedString {
            let range = (text.lowercased() as NSString).range(of: search.lowercased())
            let  mutableAttrinbutedString = NSMutableAttributedString.init(string: text)
            mutableAttrinbutedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.green, range: range)
            return mutableAttrinbutedString
        }
}
