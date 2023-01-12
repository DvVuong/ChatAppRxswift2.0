//
//  FaceBookService.swift
//  ChatAppDemo
//
//  Created by BeeTech on 26/12/2022.
//
import Foundation
import FBSDKLoginKit
import RxSwift
public class FaceBookService {
    static var shared = FaceBookService()
    
    
    func login(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) -> Observable<(User, [String: Any])> {
        return Observable.create { observable in
            let token = result?.token?.tokenString
            let requets = FBSDKLoginKit.GraphRequest.init(graphPath: "me", parameters: ["fields" : "id,email,name, picture.type(large)"], tokenString: token, version: nil, httpMethod: .get)
            requets.start {( connection, result, error ) in
                if error != nil {return}
                let result = result as! [String: Any]
                let currentUser = User(dict: result)
                observable.onNext((currentUser, result))
                
            }
            return Disposables.create()
        }
       
    }
    
    func logout() {
        FBSDKLoginKit.LoginManager().logOut()
    }
}
