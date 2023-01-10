//
//  ImgCell.swift
//  ChatAppDemo
//
//  Created by BeeTech on 21/12/2022.
//

import UIKit

class ImgCell: UITableViewCell {
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        img.contentMode = .scaleToFill
        img.layer.cornerRadius = 6
        img.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        img.isUserInteractionEnabled = true
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(handleZoomImage(_:)))
        img.addGestureRecognizer(tapGes)
    }
    func updateUI(_ message: Message?, currentUser: User?) {
        guard let message = message else {return}
        guard let currentUser = currentUser else {return}

        ImageService.share.fetchImage(with: message.image) { image in
            DispatchQueue.main.async {
                self.img.image = image
            }
        }
        
        if message.sendId == currentUser.id {
            stackView.alignment = .trailing
        } else {
            stackView.alignment = .leading
            
        }
    }
    
    @objc func handleZoomImage(_ tapGes: UITapGestureRecognizer) {
        ImageService.share.zoomImage(img)
    }
}
