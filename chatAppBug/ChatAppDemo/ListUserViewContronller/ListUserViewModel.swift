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
    private var db = Firestore.firestore()
    private var allMessages = [String: Message]()
    private let disposeBag = DisposeBag()
    private var reciverUser = PublishSubject<[User]>()
    var finalUser = BehaviorSubject(value: [User]())
    var allOtherUser = BehaviorSubject(value: [User]())
    var activeUsers = BehaviorSubject(value: [User]())
    let currentUser: User?
    let imgAvatarUserPublisher = BehaviorSubject<UIImage?>(value: nil)
    var messages = [Message]()
    let messageBehaviorSubject = BehaviorRelay(value: [Message]())
    let searchUserPublisher = PublishSubject<String>()
    let doSomeThing = PublishSubject<Void>()
    let reciverIdPublicsher = PublishSubject<(String, String)>()
    var _messageID = ""
    //MARK: - Init
    init(with data: User) {
        self.currentUser = data
        //MARK: Search User
        self.allOtherUser.subscribe { user in
            self.finalUser.onNext(user)
        }.disposed(by: self.disposeBag)
        
        searchUserPublisher.subscribe { text in
            if let text = text.element {
                
                if text.isEmpty {
                    textIsEmpty()
                }else {
                   fillterData(text)
                }
            }
            self.doSomeThing.onNext(())
        }.disposed(by: disposeBag)
        
        func textIsEmpty() {
            self.allOtherUser.subscribe { user in
                self.finalUser.onNext(user)
            }.disposed(by: self.disposeBag)
        }
        
        func fillterData(_ text: String) {
            let lowcaseText = text.lowercased()
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
    //MARK: - FetchUser
    func fetchUserRxSwift() {
        guard let currentId = currentUser?.id else {return}
        FirebaseService.share.fetchUserRxSwift().subscribe {[weak self] users in
            if let users = users.element {
                let user = users.filter({$0.id != currentId})
                let activeUser = users.filter({$0.id != currentId}).filter({$0.isActive == true})
                self?.allOtherUser.onNext(user)
                self?.activeUsers.onNext(activeUser)
                self?.reciverUser.onNext(user)
                self?.reciverUser.onCompleted()
            }
        }
        .disposed(by: disposeBag)
    }
    
    //MARK: - FetchMessage
    func fetchMessageRxSwift() {
        var temp = [Message]()
        guard let currentUser = currentUser else {return}
        allMessages.removeAll()
        messages.removeAll()
        temp.removeAll()
        allOtherUser.subscribe {[weak self] users in
            guard let users = users.element else {return}
            for user in users {
                FirebaseService.share.fetchMessageRxSwift(user, senderUser: currentUser).subscribe { data in
                    let mess = Message(dict: data)
                    temp.append(mess)
                    temp = temp.sorted {
                       return $0.time < $1.time
                   }
                    self?.doSomeThing.onNext(())
                    temp.forEach { mess in
                        if mess.receiverID == currentUser.id || mess.receiverID == user.id {
                            self?.allMessages[user.id] = mess
                            self?._messageID = mess.messageID
                            self?.messages = Array((self?.allMessages.values)!)
                            self?.messages = self?.messages.sorted {
                               return $0.time > $1.time
                           } ?? []
                        }
                       self?.messageBehaviorSubject.accept(self?.messages ?? [])
                    }
                }.disposed(by: self!.disposeBag)
            }
        }.disposed(by: disposeBag)
    }
    
    //MARK: - ChangeState Active User    
    func changesStateReadMessage() {
        reciverIdPublicsher.subscribe { userID in
            guard let userID = userID.element else {return}
            FirebaseService.share.changeStateReadMessage(userID.1, revicerID: userID.0, messageID: self._messageID)
        }.disposed(by: disposeBag)
    }
  
    func getImageForCurrentUser() {
        if let currentUser = self.currentUser {
            ImageService.share.fetchImage(with: currentUser.picture) {[weak self] image in
                self?.imgAvatarUserPublisher.onNext(image)
            }
        }
    }
}
