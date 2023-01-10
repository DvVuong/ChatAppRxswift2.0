//
//  MessageRespone.swift
//  ChatAppDemo
//
//  Created by BeeTech on 08/12/2022.
//

import Foundation
import UIKit

struct Message {
    let image: String
    let nameSender: String
    let receiverID: String
    let receivername: String
    let sendId: String
    let text: String
    let time: Double
    let read: Bool
    let messageID: String
    let avataSender: String
    let avatarReciverUser: String
    let ratioImage: CGFloat
    init(dict: [String: Any]) {
        self.image = dict["image"] as? String ?? ""
        self.nameSender = dict["nameSender"] as? String ?? ""
        self.receiverID = dict["receiverID"] as? String ?? ""
        self.receivername = dict["receivername"] as? String ?? ""
        self.sendId = dict["sendId"] as? String ?? ""
        self.text = dict["text"] as? String ?? ""
        self.time = dict["time"] as? Double ?? 0
        self.read = dict["read"] as? Bool ?? false
        self.messageID = dict["messageID"] as? String ?? ""
        self.avataSender = dict["avataSender"] as? String ?? ""
        self.avatarReciverUser = dict["avatarReciverUser"] as? String ?? ""
        self.ratioImage = dict["ratioImage"] as? CGFloat ?? 0
       
    }
}
