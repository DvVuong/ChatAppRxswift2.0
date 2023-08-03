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
    private var reciverUser = [User]()
    var finalUser = BehaviorSubject(value: [User]())
    var allOtherUser = BehaviorSubject(value: [User]())
    var activeUsers = BehaviorSubject(value: [User]())
    let currentUser: User?
    let imgAvatarUserPublisher = BehaviorSubject<UIImage?>(value: nil)
    //MARK: Message Properties
    var messages = [Message]()
    let messageBehaviorSubject = BehaviorSubject<[Message]>(value: [])
    let searchUserPublisher = PublishSubject<String>()
    let doSomeThing = PublishSubject<Void>()
    var messageID = ""
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
            self.doSomeThing.onNext(())
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
                self?.reciverUser.append(contentsOf: user)
            }
        }.disposed(by: disposeBag)
    }
    //MARK: - FetchMessage
    
    func fetchMessageRxSwift() -> Observable<[Message]> {
        return Observable.create { observable in
            self.allMessages.removeAll()
            self.messages.removeAll()
            self.allOtherUser.subscribe { users in
                if let users = users.element {
                    for user in users {
                        FirebaseService.share.fetchMessageRxSwift(user, senderUser: self.currentUser ?? user).subscribe {[weak self] data in
                            if let data = data.element {
                                let mess = Message(dict: data)
                                if mess.receiverID == self?.currentUser?.id || mess.receiverID == user.id {
                                    self?.allMessages[user.id] = mess
                                    self?.messageID = mess.messageID
                                    self?.messages = Array((self?.allMessages.values)!)
                                    self?.messages = self?.messages.sorted {
                                        return $0.time > $1.time
                                    } ?? []
                                }
                                print("vuongdv mess \(self?.messages.count)")
                                observable.onNext(self?.messages ?? [])
                            }
                        }.disposed(by: self.disposeBag )
                    }
                }
            }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    //MARK: - ChangeState Active User    
    func changesStateReadMessage() {
        guard let currentUser = currentUser else {return}
        reciverUser.forEach { user in
            FirebaseService.share.changeStateReadMessage(currentUser, revicerUser: user, messageID: self.messageID)
//            print("vuongdv", "State on......")
        }
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
