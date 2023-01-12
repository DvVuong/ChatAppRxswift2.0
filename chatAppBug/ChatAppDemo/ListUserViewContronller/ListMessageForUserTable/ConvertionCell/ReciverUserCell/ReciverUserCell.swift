//
//  ReciverUserCell.swift
//  ChatAppDemo
//
//  Created by mr.root on 12/21/22.
//

import UIKit

class ReciverUserCell: UITableViewCell {
    
    private  var lbMessage: CustomLabel = {
       let lbMessage = CustomLabel()
        lbMessage.translatesAutoresizingMaskIntoConstraints = false
        lbMessage.backgroundColor = .systemGray
        lbMessage.textColor = .white
        lbMessage.numberOfLines = 0
        lbMessage.layer.cornerRadius = 6
        lbMessage.layer.masksToBounds = true
        return lbMessage
    }()
    
    private var lbTime: UILabel = {
       let lbTime = UILabel()
        lbTime.translatesAutoresizingMaskIntoConstraints = false
        lbTime.textColor = .black
        lbTime.textAlignment = .center
        lbTime.font = .systemFont(ofSize: 10)
        return lbTime
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        contentView.addSubview(lbMessage)
        lbMessage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        lbMessage.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        lbMessage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        lbMessage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15).isActive = true
        
        contentView.addSubview(lbTime)
        lbTime.bottomAnchor.constraint(equalTo: lbMessage.bottomAnchor).isActive = true
        lbTime.widthAnchor.constraint(equalToConstant: 50).isActive = true
        lbTime.trailingAnchor.constraint(equalTo: lbMessage.trailingAnchor, constant: 50).isActive = true
        lbTime.heightAnchor.constraint(equalToConstant: 15).isActive = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func updateUI(_ message: Message?) {
        guard let message = message else {return}
        
        lbMessage.text = message.text
        if message.text == "👍" {
            lbMessage.backgroundColor = .clear
            
        } else {
            lbMessage.backgroundColor = .systemGray
            
        }
        // Time
        let time = Date(timeIntervalSince1970: TimeInterval(message.time))
        let timeDateFormatter = DateFormatter()
        timeDateFormatter.dateFormat = "hh:mm"
        lbTime.text = timeDateFormatter.string(from: time)
    }
    
}
