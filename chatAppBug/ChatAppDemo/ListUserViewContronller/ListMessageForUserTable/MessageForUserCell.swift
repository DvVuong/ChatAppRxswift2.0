//
//  ListUserTableViewCell.swift
//  ChatAppDemo
//
//  Created by BeeTech on 07/12/2022.
//

import UIKit

class MessageForUserCell: UITableViewCell {
    @IBOutlet weak var lbNameUser: UILabel!
    @IBOutlet private weak var lbMessage: UILabel!
    @IBOutlet private weak var imgAvt: UIImageView!
    @IBOutlet private weak var bubbleView: UIView!
    @IBOutlet private weak var imgState: UIImageView!
    @IBOutlet private weak var imgStateReciverUser: UIImageView!
    
    
    @IBOutlet weak var lbTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgAvt.contentMode = .scaleToFill
        imgAvt.layer.cornerRadius = imgAvt.frame.height / 2
        imgAvt.layer.masksToBounds = true
        imgState.isHidden = true
        // Setup BubbleView
        bubbleView.layer.borderWidth = 1
        bubbleView.layer.borderColor = UIColor.black.cgColor
        bubbleView.layer.cornerRadius = 10
        bubbleView.layer.masksToBounds = true
        
        imgStateReciverUser.layer.cornerRadius = imgStateReciverUser.frame.height / 2
        imgStateReciverUser.layer.masksToBounds = true
        imgStateReciverUser.layer.borderWidth = 2
        imgStateReciverUser.layer.borderColor = UIColor.white.cgColor
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateUI(_ currentUser: User?, message: Message?, reciverUser: User?) {
        guard let message = message else {return}
        guard let currentUser = currentUser else {return}
        guard let reciverUser = reciverUser else {return}
        
        let time = Date(timeIntervalSince1970: TimeInterval(message.time))
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "hh:mm"
       
        lbTime.text = dateFormater.string(from: time)
        // Show Message and State message
        if message.sendId == currentUser.id && message.receiverID == reciverUser.id {
            self.imgStateReciverUser.tintColor = reciverUser.isActive ? .systemGreen : .systemGray
        }
        
        if message.sendId == currentUser.id || message.receiverID == reciverUser.id {
            lbMessage.text = "you: \(message.text)"
            lbNameUser.text = message.receivername
            // Show Avatar
            ImageService.share.fetchImage(with: message.avatarReciverUser) { image in
                DispatchQueue.main.async {
                    self.imgAvt.image = image
                }
            }
            
           
            
        } else {
            
            lbMessage.text = "\(message.nameSender) sent: \(message.text)"
            lbNameUser.text = message.nameSender
            ImageService.share.fetchImage(with: message.avataSender) { image in
                DispatchQueue.main.async {
                    self.imgAvt.image = image
                }
            }
        }
        
        if !message.image.isEmpty {
            if message.sendId == currentUser.id {
                lbMessage.text = "you sent a Photo"
            }else {
                
                lbMessage.text = "\(message.nameSender) sent a Photo"
            }
            return
        }
       
    }
}
