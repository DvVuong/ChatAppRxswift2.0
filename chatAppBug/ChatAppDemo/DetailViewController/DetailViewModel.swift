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

class DetailViewModel {
    //MARK: - Properties
    private var imgUrl:String = ""
    private var currentUser: User?
    private var receiverUser: User?
    private var messages: [Message] = []
    let messageBehaviorSubject = BehaviorSubject(value: [Message]())
    let stateUserPublisher = PublishSubject<[User]>()
    let imageUserPublisher = PublishSubject<UIImage?>()
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
        self.messages.removeAll()
        FirebaseService.share.fetchMessageRxSwift(reciverUser, senderUser: senderUser).subscribe {[weak self] data in
            let mess = Message(dict: data)
            if mess.receiverID == reciverUser.id || mess.receiverID == senderUser.id {
                self?.messages.append(mess)
                self?.messages = self?.messages.sorted {
                    $0.time < $1.time
                } ?? []
            }
            self?.messageBehaviorSubject.onNext(self?.messages ?? [])
        }.disposed(by: bag)
    }
       
    func getNumberOfMessage() -> Int {
        return messages.count
    }
    
    func getMessage(_ index: Int) -> Message {
        return messages[index]
    }
    
    //MARK: -Fetch StateMessage
    func fetchStateUser() {
        var image: UIImage? = nil
        guard let reciverUser = receiverUser else  {return}
        FirebaseService.share.fetchUser { [weak self] user in
            let userState = user.filter({$0.id == reciverUser.id})
            self?.stateUserPublisher.onNext(userState)
            userState.forEach { user in
                ImageService.share.fetchImage(with: user.picture) { img in
                  image = img
                 self?.imageUserPublisher.onNext(image)
                }
            }
        }
    }
}
