//
//  SignInPresenter.swift
//  ChatAppDemo
//
//  Created by BeeTech on 07/12/2022.
//

import Firebase
import FirebaseFirestore
import FBSDKLoginKit
import RxSwift

protocol SignInPresenterDelegate: NSObject {
    func showUserRegiter(_ email: String, password: String)
}

class SinginViewModel {
    //MARK: -Properties
    private weak var view: SignInPresenterDelegate?
    private var users = [User]()
    var currentUser: User?
    private let db = Firestore.firestore()
    let emailtextPublisherSubjetc = PublishSubject<String>()
    let passwordPublisherSubject = PublishSubject<String>()
    
    
    let emailError = BehaviorSubject<String?>(value: "")
    let passwordError = BehaviorSubject<String?>(value: "")
    private let disponeBag = DisposeBag()
    
    //MARK: -Init
    init(with view: SignInPresenterDelegate) {
        self.view = view
        
        emailtextPublisherSubjetc.map{self.validateEmail($0)}.subscribe {[weak self] valiPair in
            if let validate = valiPair.element {
                self?.emailError.onNext(validate.1)
            }
        }.disposed(by: disponeBag)
        
        passwordPublisherSubject.map {self.validatePassword($0)}.subscribe {[weak self] valiPair in
            if let validate = valiPair.element {
                self?.passwordError.onNext(validate.1)
            }
        }.disposed(by: disponeBag)
        
    }

    //MARK: -Fetch User
    func fetchUser() {
        self.users.removeAll()
        FirebaseService.share.fetchUser { user in
            self.users.append(contentsOf: user)
        }
    }
    
    //MARK: Resgiter
    func registerSocialMediaAccount(_ result: [String: Any]) {
        let email = result["email"] as? String ?? ""
        let name = result["name"] as? String ?? ""
        let id = result["id"] as? String ?? ""
        let pictureData: [String: Any] = result["picture"] as? [String: Any] ?? [:]
        let pictureUrl: [String: Any] = pictureData["data"] as? [String: Any] ?? [:]
        let url = pictureUrl["url"] as? String ?? ""
    
        FirebaseService.share.registerSocialMedia(name, email: email, id: id, picture: url)
    }
    
    
    //MARK: -Login
    func loginZalo(_ vc: SiginViewController) -> Observable<User> {
        return Observable.create { observable in
            ZaloService.shared.login(vc)
            
            ZaloService.shared.userZalo.subscribe {[weak self] user in
                if let user = user.element {
                    print("vuongdv", user)
                    FirebaseService.share.registerSocialMedia(user.name, email: user.email, id: user.id, picture: user.picture)
                    self?.changeStateUser(user)
                    observable.onNext(user)
                }
            }.disposed(by: self.disponeBag)
            return Disposables.create()
        }
    }

    func loginWithGoogle(_ vc: SiginViewController) -> Observable<User> {
        return Observable.create {[weak self] observable in
            GoogleService.shared.login(vc).subscribe { [weak self] user in
                if let user = user.element {
                    self?.changeStateUser(user)
                    FirebaseService.share.registerSocialMedia(user.name, email: user.email, id: user.id, picture: user.picture)
                    observable.onNext(user)
                }
            }.disposed(by: self?.disponeBag ?? DisposeBag())
            return Disposables.create()
        }
    }
    
    func loginWithFacebook(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) -> Observable<User> {
        return Observable.create { observable in
            FaceBookService.shared.login(loginButton, didCompleteWith: result, error: error).subscribe { [weak self] data in
                if let data = data.element {
                    self?.registerSocialMediaAccount(data.1)
                    self?.changeStateUser(data.0)
                    observable.onNext(data.0)
                }
            }.disposed(by: self.disponeBag)
            return Disposables.create()
        }
       
    }
    
    //MARK: -Validate
    func validateSocialMediaAccount(_ email: String) -> Observable<(Bool,User?)>{
        return Observable.create { observable in
            var currentUser: User?
            var isvalid: Bool = false
            self.users.forEach { user in
                if user.email == email {
                    currentUser = user
                    isvalid = true
                }
            }
            observable.onNext((isvalid, currentUser))
            return Disposables.create()
        }
    }
    
    func validateEmailPassword(_ email: String, _ password: String, completion: (_ currentUser: User?, Bool) -> Void) {
            var currentUser: User?
            var isvalid: Bool = false
            users.forEach { user in
                if user.email == email && user.password == password {
                    currentUser = user
                    isvalid = true
                }
            }
            completion(currentUser, isvalid)
        }
    
    // Use Show error on lable
    func validateEmail(_ email: String) -> (Bool, String?) {
        if email.isEmpty {
            return (false, "Email can't not empty")
        }
        
        if let user = users.first(where: { $0.email == email }) {
            self.currentUser = user
            return (true, nil)
        } else {
            return (false, "Wrong Email")
        }
    }
    
    func validatePassword(_ password: String) -> (Bool, String?) {
        if password.isEmpty {
            return (false, "Password can't not empty")
        }
        
        if let user = users.first(where: { $0.password == password }) { self.currentUser = user
            return (true, nil)
        } else {
            return (false, "Wrong Password")
        }
    }
    
    
    //MARK: Change State User
    func changeStateUser(_ currentUser: User) {
        FirebaseService.share.changeStateActiveForUser(currentUser)
    }
    
    func getUserData() -> [User] {
        return users
    }
    
    func showUserInfo() -> (email: String, password: String )  {
        let email: String = ""
        let password: String = ""
//        let info = DataManager.shareInstance.getUser()
//        _ = info.map { item in
//            email = item.email
//            password = item.password
//        }
        return (email, password)
    }
    
    func showUserResgiter(_ email: String, password: String) {
        view?.showUserRegiter(email, password: password)
    }
}
