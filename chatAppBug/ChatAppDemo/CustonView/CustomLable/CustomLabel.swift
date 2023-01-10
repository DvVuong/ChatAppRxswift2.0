//
//  CustomLabel.swift
//  ChatAppDemo
//
//  Created by BeeTech on 09/12/2022.
//

import UIKit

public class CustomLabel: UILabel {

   @IBInspectable var topInset: CGFloat = 5.0
   @IBInspectable var bottomInset: CGFloat = 3.0
   @IBInspectable var leftInset: CGFloat = 5.0
   @IBInspectable var rightInset: CGFloat = 5.0

    public override func drawText(in rect: CGRect) {
      let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
       super.drawText(in: rect.inset(by: insets))
   }

    public override var intrinsicContentSize: CGSize {
      get {
         var contentSize = super.intrinsicContentSize
         contentSize.height += topInset + bottomInset
         contentSize.width += leftInset + rightInset
         return contentSize
      }
   }
}
