//
//  ListUserPresenter.swift
//  ChatAppDemo
//
//  Created by mr.root on 12/7/22.
//

import Firebase
import FirebaseFirestore
import RxSwift
import RxCocoa
class ListUserViewModel {
    //MARK: -Properties
    private var db = Firestore.firestore()
    private var allMessages = [String: Message]()
    private let disposeBag = DisposeBag()
    //MARK: User Properties
    var reciverUser = BehaviorSubject(value: [User]())
    var finalUser = BehaviorSubject(value: [User]())
    var allOtherUser = BehaviorSubject(value: [User]())
    var activeUsers = BehaviorSubject(value: [User]())
    let currentUser: User?
    let imgAvatarUserPublisher = BehaviorSubject<UIImage?>(value: nil)
    //MARK: Message Properties
    var message = [Message]()
    let messageBehaviorSubject = BehaviorRelay(value: [Message]())
    let searchUserPublisher = PublishSubject<String>()
    //MARK: - Init
    init(with data: User) {
        self.currentUser = data
        //MARK: Search User
        self.allOtherUser.subscribe { user in
            self.finalUser.onNext(user)
        }.disposed(by: self.disposeBag)
        searchUserPublisher.subscribe { text in
            if let text = text.element {
                let lowcaseText = text.lowercased()
                if text.isEmpty {
                    self.allOtherUser.subscribe { user in
                        self.finalUser.onNext(user)
                    }.disposed(by: self.disposeBag)
                }else {
                    self.allOtherUser.subscribe { users in
                        if let user = users.element {
                            let searchUser = user.filter{$0.name
                                    .folding(options: .diacriticInsensitive, locale: nil)
                                    .lowercased()
                                    .contains(lowcaseText)
                            }
                            self.finalUser.onNext(searchUser)
                        }
                    }.disposed(by: self.disposeBag)
                }
            }
        }.disposed(by: disposeBag)
    }
    //MARK: - FetchUser
    func fetchUserRxSwift()  {
        guard let currentId = currentUser?.id else {return}
        FirebaseService.share.fetchUserRxSwift().subscribe {[weak self] users in
            if let users = users.element {
                let user = users.filter({$0.id != currentId})
                let activeUser = users.filter({$0.id != currentId}).filter({$0.isActive == true})
                self?.allOtherUser.onNext(user)
                self?.activeUsers.onNext(activeUser)
                self?.reciverUser.onNext(user)
            }
        }.disposed(by: disposeBag)
    }
    //MARK: - FetchMessage
    func fectchMessageRxSwift() {
        guard let currentUser = currentUser else {return}
        allMessages.removeAll()
        message.removeAll()
        allOtherUser.subscribe {[weak self] users in
            guard let users = users.element else {return}
            for user in users {
                FirebaseService.share.fetchMessageRxSwift(user, senderUser: currentUser).subscribe { data in
                    let mess = Message(dict: data)
                    if mess.receiverID == currentUser.id || mess.receiverID == user.id {
                        self?.allMessages[user.id] = mess
                        self?.message = Array((self?.allMessages.values)!)
                        self?.message = self?.message.sorted {
                            return $0.time > $1.time
                        } ?? []
                    }
                    self?.messageBehaviorSubject.accept(self?.message ?? [])
                }.disposed(by: self?.disposeBag ?? DisposeBag())
            }
        }.disposed(by: disposeBag)
    }
    //MARK: - ChangeState Active User
    func setState(_ sender: User, reciverUser: User) {
        FirebaseService.share.changeStateReadMessage(sender, revicerUser: reciverUser)
    }
    
    func changesStateReadMessage() {
        guard let currentUser = currentUser else {return}
        allOtherUser.subscribe { users in
            if let users = users.element {
                users.forEach { user in
                    FirebaseService.share.changeStateReadMessage(currentUser, revicerUser: user)
                }
            }
        }.disposed(by: disposeBag)
    }
    //MARK: -Getter,Setter
    func getcurrentUser() -> User?{
        return currentUser
    }
    
    func getImageForCurrentUser(){
        if let currentUser = self.currentUser {
            ImageService.share.fetchImage(with: currentUser.picture) {[weak self] image in
                self?.imgAvatarUserPublisher.onNext(image)
            }
        }
        
    }
}
