//
//  Constant.swift
//  ChatAppDemo
//
//  Created by BeeTech on 23/12/2022.
//
import Foundation
class Constant {

    public static let EXT_INFO = [
        "appVersion": "1.0.0",
    ]
    public static let ZALO_APP_ID = "4104534452131369871"

}

enum UserDefaultsKeys: String, CaseIterable {
    case refreshToken = "refreshToken"
    case accessToken = "accessToken"
    case expriedTime = "expriedTime"
}
