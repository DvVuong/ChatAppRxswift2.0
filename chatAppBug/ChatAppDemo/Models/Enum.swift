//
//  Enum.swift
//  ChatAppDemo
//
//  Created by BeeTech on 15/12/2022.
//

import Foundation

public enum State: String {
    case emptyEmail = "Email must not be empty"
    case emailInvalidate = "Email invalidate"
    case emptyName = " Name must not be empty"
    case emailAlreadyExist = " Email already exist  "
    case emptPassword = "Password must not be empty"
    case weakPassword = "Password more than 8 characters"
    case emptyAvatarUrl = "You have not selected a profile picture"
    case passwordNotincorrect = "Confirm Password incorrect"
    case allCorrect = ""
}
