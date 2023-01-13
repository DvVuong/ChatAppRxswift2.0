//
//  FirebaseService.swift
//  ChatAppDemo
//
//  Created by BeeTech on 16/12/2022.
//
import Firebase
import FirebaseFirestore
import RxSwift

public class FirebaseService {
    static var share = FirebaseService()
    private let db = Firestore.firestore()
    private var users = [User]()
    private var messages = [Message]()
    private var imgUrl = ""
    private let _user = "user"
    private let _message = "message"
    private let _imageMessage = "ImageMessage"
    private let _avatar = "Avatar"
    
    func fetchUserRxSwift() -> Observable<[User]> {
        return Observable.create {[weak self] observable in
            let listen = self?.db.collection(self?._user ?? "").addSnapshotListener({ querySnapShot, error in
                if error != nil {return}
                guard let data = querySnapShot?.documents else {return}
                let user = data.map({User(dict: $0.data())})
                observable.onNext(user)
            })
            return Disposables.create()
            listen?.remove()
        }
       
    }
    
    // MARK: SendMessage
    func sendMessage(with message: String, receiverUser: User, senderUser: User) {
        let autoKey = self.db.collection(_message).document().documentID
        let document = db.collection(_message)
            .document(senderUser.id)
            .collection(receiverUser.id)
            .document(autoKey)
        let data: [String: Any] = [
                "nameSender": senderUser.name,
                "avataSender":senderUser.picture,
                "receivername": receiverUser.name,
                "avatarReciverUser": receiverUser.picture,
                "text": message,
                "image": imgUrl,
                "sendId": senderUser.id,
                "receiverID": receiverUser.id,
                "time": Date().timeIntervalSince1970,
                "read": false,
                "messageID": autoKey
        ]
        document.setData(data)
        let reciverDocument = db.collection(_message)
            .document(receiverUser.id)
            .collection(senderUser.id)
            .document(autoKey)
        reciverDocument.setData(data)
    }
    
    func setImageMessage(_ image: UIImage, receiverUser: User, senderUser: User) {
        let autoKey = self.db.collection(_message).document().documentID
        let storeRef = Storage.storage().reference()
        let imageKey = NSUUID().uuidString
        let ratioImage = image.size.width / image.size.height
        guard  let image = image.jpegData(compressionQuality: 0.5) else {return}
        let imgFolder = storeRef.child(_imageMessage).child(imageKey)
        storeRef.child(_imageMessage).child(imageKey).putData(image) { [weak self] (metadat, error) in
            if error != nil { return}
            imgFolder.downloadURL { url, error in
                if error != nil {return}
                guard let url = url else {return}
                self?.imgUrl = "\(url)"
              let document =  self?.db.collection(self?._message ?? "")
                    .document(senderUser.id)
                    .collection(receiverUser.id)
                    .document(autoKey)
                
                let data = [
                    "nameSender": senderUser.name,
                    "avataSender": senderUser.picture,
                    "sendId": senderUser.id,
                    "text": "",
                    "image": self?.imgUrl as Any,
                    "receivername": receiverUser.name,
                    "receiverID": receiverUser.id,
                    "avatarReciverUser": receiverUser.picture,
                    "time": Date().timeIntervalSince1970,
                    "read": false,
                    "ratioImage": ratioImage,
                    "messageKey": autoKey
                ]
                document?.setData(data)
                
               guard let reciverdocument = self?.db.collection(self?._message ?? "")
                    .document(receiverUser.id)
                    .collection(senderUser.id)
                    .document(autoKey) else {return}
                reciverdocument.setData(data)
            }
        }
    }
    
    func changeStateReadMessage(_ senderID: String, revicerID: String , messageID: String) {
        self.db.collection(_message)
            .document(revicerID)
            .collection(senderID)
            .document(messageID)
            .updateData(["read" : true])
//        print("vuongdv", "Did changes State Read Message")
    }
    // MARK: fetchMessage
    func fetchMessageRxSwift(_ receiverUser: User, senderUser: User) -> Observable<[String: Any]> {
        return Observable.create {[weak self] observable in
           let listen =  self?.db.collection(self?._message ?? "")
                .document(senderUser.id)
                .collection(receiverUser.id)
                .addSnapshotListener { queriSnapshot, error in
                    if error != nil {return}
                    guard let data = queriSnapshot?.documentChanges else {return}
                    for doc in data {
                        if doc.type == .added || doc.type == .modified || doc.type == .modified {
                            observable.onNext(doc.document.data())
                        }
                    }
               }
            return Disposables.create()
            listen?.remove()
        }
    }
    
    func createAccount(email: String,  password: String, name: String) {
        let autoKey = self.db.collection(_user).document().documentID
        if self.imgUrl.isEmpty {
           let imgUrl = "https://firebasestorage.googleapis.com/v0/b/chatapp-9c3f7.appspot.com/o/Avatar%2FplaceholderAvatar.jpeg?alt=media&token=7d7eab97-abae-4bc9-8ed7-35569c485423"
            let data: [String: Any] = [
                "email": email,
                "password": password,
                "picture": imgUrl,
                "id": autoKey,
                "name": name,
                "isActive": false
            ]
            self.db.collection(_user).document(autoKey).setData(data)
         
        } else {
            let data: [String: Any] = [
                "email": email,
                "password": password,
                "picture": self.imgUrl,
                "id": autoKey,
                "name": name,
                "isActive": false
            ]
            self.db.collection(_user).document(autoKey).setData(data)
        }
    }
    
    func fetchAvatarUrl(_ image: UIImage) {
        let fireBaseStorage = Storage.storage().reference()
        guard let img = image.jpegData(compressionQuality: 0.5) else {return}
        let imgKey = NSUUID().uuidString
        let imgFloder = Storage.storage().reference().child(_avatar).child(imgKey)
        fireBaseStorage.child(_avatar).child(imgKey).putData(img) {[weak self] (metadata, error) in
            if error != nil  {return}
            imgFloder.downloadURL {  url, error in
                if error != nil  {return}
                guard let url = url else  { return }
                self?.imgUrl = url.absoluteString
            }
        }
    }
    
    func registerSocialMedia(_ name: String, email: String, id: String, picture: String) {
        let data: [String: Any] = [
            "name": name,
            "email": email,
            "id": id,
            "picture": picture,
            "isActive": false
        ]
        self.db.collection(_user).document(id).setData(data)
    }
    
    func changeStateActiveForUserLogin(_ currentUser: User, isActive: Bool) {
        self.db.collection(self._user).document(currentUser.id).updateData(["isActive" : isActive])
    }

    func updateAvatar(_ currentUser: User) {
        self.db.collection(self._user).document(currentUser.id).updateData(["picture" : self.imgUrl])
    }
    
    func updateName(_ currentUser: User, name: String) {
        self.db.collection(self._user).document(currentUser.id).updateData(["name" : name])
    }
    
    func updateEmail(_ currentUser: User, email: String) {
        self.db.collection(self._user).document(currentUser.id).updateData(["email" : email])
    }
    
    func updatePassword(_ currentUser: User, password: String) {
        self.db.collection(self._user).document(currentUser.id).updateData(["password" : password])
    }
    
}
