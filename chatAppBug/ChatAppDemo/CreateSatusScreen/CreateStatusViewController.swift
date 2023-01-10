//
//  CreateStatusViewController.swift
//  ChatAppDemo
//
//  Created by BeeTech on 28/12/2022.
//

import UIKit

final class CreateStatusViewController: UIViewController {
    
    static func instance(_ user: User?) -> CreateStatusViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createStatusScreen") as! CreateStatusViewController
        vc.presenter = CreateStatusPresenter(with: vc, user: user)
        return vc
    }

    
    @IBOutlet private weak var viewInputStatus: UIView!
    
    @IBOutlet private weak var tvInputText: UITextView!
    
    @IBOutlet private weak var lbCountCharacter: UILabel!
    
    
    private var presenter: CreateStatusPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
       setupViewTextView()
        setupTextView()
        setupLbCountCharater()
    }
    
    private func setupTextView() {

        tvInputText.layer.borderWidth = 0
        tvInputText.delegate = self

        tvInputText.becomeFirstResponder() 
    }
    
    private func setupLbCountCharater() {
        lbCountCharacter.text = "\(tvInputText.text.count) /60"
    }
    
    private func setupViewTextView() {
        viewInputStatus.layer.borderWidth = 1
        viewInputStatus.layer.borderColor = UIColor.systemGray.cgColor
        viewInputStatus.layer.cornerRadius = 8
        viewInputStatus.layer.masksToBounds = true

    }
    
    
}



extension CreateStatusViewController: CreateStatusPresenterViewDelegate {
    
}

extension CreateStatusViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
      
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        return true
    }
    
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        tvInputText.text = "What are you doing?"
//        tvInputText.textColor = .lightGray
//    }
//
//    func textViewDidEndEditing(_ textView: UITextView) {
//        print(textView.text)
//    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
       
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        lbCountCharacter.text = "\(newText.count) /60"
        return numberOfChars <= 60
    }
}
