//
//  GoogleService.swift
//  ChatAppDemo
//
//  Created by BeeTech on 26/12/2022.
//
import Foundation
import RxSwift
import GoogleSignIn
public class GoogleService {
    static var shared = GoogleService()
    
    func login(_ vc: SiginViewController) -> Observable<User> {
        return Observable.create { observable in
            GIDSignIn.sharedInstance.signIn(withPresenting: vc) { signInResult, error  in
                if error != nil {return}
                guard let signInResult = signInResult else {return}
                let user = signInResult.user
                guard let email = user.profile?.email else {return}
                guard let name = user.profile?.name else {return}
                guard let id = user.userID else {return}
                guard let profilePicUrl = user.profile?.imageURL(withDimension: 320) else {return}
                let userGoogle = User(name: name, id: id, picture: "\(profilePicUrl)", email: email, password: "", isActive: false)
                observable.onNext(userGoogle)
            }
            return Disposables.create()
        }
        
    }
    
    func logout() {
        GIDSignIn.sharedInstance.signOut()
    }
}
