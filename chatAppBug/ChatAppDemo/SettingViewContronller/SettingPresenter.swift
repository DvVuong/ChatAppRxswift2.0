//
//  SettingPresenterView.swift
//  ChatAppDemo
//
//  Created by BeeTech on 20/12/2022.
//

import UIKit
protocol SettingPresenterDelegate: NSObject {
    
}

class SettingPresenter {
    //MARK: - Properties
    private weak var view: SettingPresenterDelegate?
    private var user: User?
    private var avatarUrl: String = ""
    
    //MARK: -Init
    init(with view: SettingPresenterDelegate, user: User) {
        self.view = view
        self.user = user
    }
    
    //MARK: -Getter,Setter
    
    func getUser() -> User? {
        return user
    }
    //MARK: -Action
    func setStateUserForLogOut() {
        guard let user = user else  {return}
        FirebaseService.share.changeStateInActiveForUser(user)
    }
    
    func fetchNewAvatarUrl(_ image: UIImage) {
        FirebaseService.share.fetchAvatarUrl(image)
    }
    
    // MARK: -Change Information
    func changeAvatar() {
        guard let user = user else {return}
        FirebaseService.share.updateAvatar(user)
    }
    
    func changeName(name: String) {
        guard let user = user else {return}
        FirebaseService.share.updateName(user, name: name)
    }
    
    func changeEmail( email: String) {
        guard let user = user else {return}
        FirebaseService.share.updateEmail(user, email: email)
    }
    
    func changePassword( password: String) {
        guard let user = user else {return}
        FirebaseService.share.updatePassword(user, password: password)
    }
    
    
    // MARK: -Logout
    func logoutZalo() {
        ZaloService.shared.logoutZalo()
    }
    
    func logoutGoogle() {
        GoogleService.shared.logout()
    }
    
    func logoutFacebook() {
        FaceBookService.shared.logout()
    }
    
    
    
}
