//
//  ResgiterPresenter.swift
//  ChatAppDemo
//
//  Created by BeeTech on 12/12/2022.
//

import Firebase
import RxSwift
import RxCocoa

class ResgiterPresenterView {
    private var imgUrl: String = ""
    private var db = Firestore.firestore()
    private let _user = "user"
    private let disponeBag = DisposeBag()
    var user = [User]()
    
    let namePublisherSubject = PublishSubject<String>()
    let emailPublisherSubject = PublishSubject<String>()
    let passwordPublisherSubject = PublishSubject<String>()
   
    
    let nameErrorPublisher = BehaviorSubject<String?>(value: "")
    let emailErrorPublisher = BehaviorSubject<String?>(value: "")
    let passwordErrorPublisher = BehaviorSubject<String?>(value: "")
   
    
    
    init() {
        //MARK: Vaidate
        namePublisherSubject.map({self.vaidateName($0)}).subscribe {[weak self] valiPair in
            if let validate = valiPair.element  {
                self?.nameErrorPublisher.onNext(validate.1)
            }
            
        }.disposed(by: disponeBag)
        
        
        emailPublisherSubject.map({self.validateEmail($0)}).subscribe {[weak self] valiPair in
            if let validate = valiPair.element  {
                self?.emailErrorPublisher.onNext(validate.1)
            }
        }.disposed(by: disponeBag)
        
        passwordPublisherSubject.map({self.validatePassword($0)}).subscribe {[weak self] valiPair in
            if let validate = valiPair.element  {
                self?.passwordErrorPublisher.onNext(validate.1)
            }
        }.disposed(by: disponeBag)
    }
    
    
    func getUrlAvatar(_ image: UIImage) {
        FirebaseService.share.fetchAvatarUrl(image)
    }
    
    func createAccount( email: String,  password: String, name: String) {
        FirebaseService.share.createAccount(email: email, password: password, name: name)
    }
    
    func vaidateName(_ name: String) -> (Bool, String?) {
        if name.isEmpty {
            return (false, State.emptyName.rawValue)
        }
        return (true, nil)
    }
    
    func validateEmail(_ email: String) -> (Bool, String?)  {
        if email.isEmpty {
            return (false, State.emptyEmail.rawValue)
        }
        
        if !isValidEmail(email: email) {
            return (false, State.emailInvalidate.rawValue)
        }
        
        if user.contains(where: { $0.email == email}) {
            return (false, State.emailAlreadyExist.rawValue)
        }
        
        return (true, nil)
    }
    
    func validatePassword(_ password: String) -> (Bool, String?) {
        if password.isEmpty {
            return (false, State.emptPassword.rawValue)
        }
        
        if password.count < 8 {
            return (false, State.weakPassword.rawValue)
        }
        
       return (true, nil)
        
    }
    
   private func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
}
