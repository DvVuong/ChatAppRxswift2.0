//
//  User.swift
//  ChatAppDemo
//
//  Created by BeeTech on 07/12/2022.
//

import Foundation

public struct User {
    let name: String
    let email: String
    let password: String
    let picture: String
    let id: String
    let isActive: Bool
    init(dict: [String: Any]) {
        self.name = dict["name"] as? String ?? ""
        self.email = dict["email"] as? String ?? ""
        self.password = dict["password"] as? String ?? ""
        self.picture = dict["picture"] as? String ?? ""
        self.id = dict["id"] as? String ?? ""
        self.isActive = dict["isActive"] as? Bool ?? false
    }
    
    init(name: String, id: String, picture: String, email: String, password: String, isActive: Bool) {
        self.id = id
        self.email = email
        self.name = name
        self.picture = picture
        self.password = password
        self.isActive = isActive
    }
    
}



