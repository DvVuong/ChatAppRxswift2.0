//
//  DetailPresenterView.swift
//  ChatAppDemo
//
//  Created by BeeTech on 08/12/2022.
//

import Firebase
import FirebaseFirestore
import RxSwift
import RxCocoa
import UIKit

class DetailViewModel {
    //MARK: - Properties
    private var imgUrl:String = ""
    private var currentUser: User?
    private var receiverUser: User?
    private var messages: [Message] = []
    let messageBehaviorSubject = BehaviorSubject(value: [Message]())
    private var db = Firestore.firestore()
    private var stateUser = [User]()
    private let _message = "message"
    private let like = "👍"
    private let bag = DisposeBag()
    //MARK: -Init
    init( data: User, currentUser: User) {
        self.receiverUser = data
        self.currentUser = currentUser
    }
    //MARK: -Getter - Setter
    func getCurrentUser() -> User? {
        return currentUser
    }
    //MARK: -SendMessage
    func sendMessage(with message: String) {
        guard let receiverUser = receiverUser else { return }
        guard let senderUser = currentUser else  {  return }
        FirebaseService.share.sendMessage(with: message, receiverUser: receiverUser, senderUser: senderUser)
    }

    func sendImageMessage(with image: UIImage) {
        guard let receiverUser = receiverUser else { return }
        guard let senderUser = currentUser else  {  return }
        FirebaseService.share.setImageMessage(image, receiverUser: receiverUser, senderUser: senderUser)
    }
    
    func sendLikeSymbols() {
        guard let receiverUser = receiverUser else { return }
        guard let senderUser = currentUser else  {  return }
        FirebaseService.share.sendMessage(with: like, receiverUser: receiverUser, senderUser: senderUser)
    }
    
    //MARK: -FetchMessage
    func fetchMessage() {
        self.messages.removeAll()
        guard let reciverUser = receiverUser else {return}
        guard let senderUser = self.currentUser else { return }
        
        FirebaseService.share.fetchMessageRxSwift(reciverUser, senderUser: senderUser).subscribe {[weak self] data in
            if let data = data.element {
                let mess = Message(dict: data)
                if mess.receiverID == reciverUser.id || mess.receiverID == senderUser.id {
                    self?.messages.append(mess)
                    self?.messages = self?.messages.sorted {
                        $0.time < $1.time
                    } ?? []
                }
                self?.messageBehaviorSubject.onNext(self?.messages ?? [])
            }
        }.disposed(by: bag)
    }
       
    func getNumberOfMessage() -> Int {
        return messages.count
    }
    
    func getMessage(_ index: Int) -> Message {
        return messages[index]
    }
    
    //MARK: -Fetch StateMessage
    func fetchStateUser() -> Observable<([User], UIImage?)> {
        return Observable.create { [weak self] observable in
            var image: UIImage? = nil
            if let reciverUser = self?.receiverUser {
                FirebaseService.share.fetchUserRxSwift().subscribe { users in
                    if let user = users.element {
                        let userState = user.filter({$0.id == reciverUser.id})
                        userState.forEach { user in
                            ImageService.share.fetchImage(with: user.picture) { img in
                              image = img
                                observable.onNext((userState, image))
                            }
                        }
                    }
                }.disposed(by: self?.bag ?? DisposeBag())
            }
            return Disposables.create()
        }
    }
}
