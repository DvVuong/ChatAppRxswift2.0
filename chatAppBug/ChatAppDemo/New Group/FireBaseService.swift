//
//  FirebaseService.swift
//  ChatAppDemo
//
//  Created by BeeTech on 16/12/2022.
//
import Firebase
import FirebaseFirestore
import RxSwift

class FirebaseService {
    
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
    
    func fetchUser(_ completed: @escaping ([User]) -> Void) {
        self.users.removeAll()
        db.collection(_user).addSnapshotListener {[weak self] (querySnapshot, error) in
            if error != nil {return}
            guard let querySnapshot = querySnapshot?.documentChanges else { return }
            self?.users.removeAll()
            querySnapshot.forEach { doc in
                if doc.type == .added || doc.type == .modified  {
                    let value = User(dict: doc.document.data())
                    self?.users.append(value)
                }
            }
            completed(self?.users ?? [])
        }
    }
    
    // MARK: fetchMessage
    func fetchMessageRxSwift(_ receiverUser: User, senderUser: User) -> Observable<[String: Any]> {
        return Observable.create {[weak self] observable in
            let listen = self?.db.collection(self?._message ?? "")
                .document(senderUser.id)
                .collection(receiverUser.id)
                .addSnapshotListener { queriSnapshot, error in
                    if error != nil {return}
                    guard let data = queriSnapshot?.documentChanges else {return}
                    data.forEach { doc in
                        if doc.type == .added || doc.type == .removed {
                            let value = doc.document.data()
                            observable.onNext(value)
                        }
                    }
                }
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
            .document()
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
                "messageKey": autoKey
        ]
        document.setData(data)
        let reciverDocument = db.collection(_message)
            .document(receiverUser.id)
            .collection(senderUser.id)
            .document()
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
                    .document()
                
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
                    .document() else {return}
                
                reciverdocument.setData(data)
            }
        }
        
    }
    
    func changeStateReadMessage(_ senderUser: User, revicerUser: User) {
        self.db.collection(_message)
            .document(senderUser.id)
            .collection(revicerUser.id)
            .whereField("read", isEqualTo: false)
            .getDocuments { querydata, error in
                if error != nil {return}
                guard let doc = querydata?.documents else { return }
                doc.forEach { [weak self] doc in
                    let value = Message(dict: doc.data())
                    if value.receiverID == revicerUser.id || value.receiverID == senderUser.id {
                        self?.db.collection(self!._message)
                            .document(senderUser.id)
                            .collection(revicerUser.id)
                            .document()
                            .updateData(["read" : true])
                    }
                }
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
            self.db.collection("user").document(autoKey).setData(data)
         
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
    
    func changeStateActiveForUser(_ currentUser: User) {
        self.db.collection(_user)
        self.db.collection(self._user).document(currentUser.id).updateData(["isActive" : true])
    }
    
    func changeStateInActiveForUser(_ currentUser: User) {
        self.db.collection(_user)
        self.db.collection(self._user).document(currentUser.id).updateData(["isActive" : false])
    }
    
    func updateAvatar(_ currentUser: User) {
        self.db.collection(_user)
        self.db.collection(self._user).document(currentUser.id).updateData(["avatar" : self.imgUrl])
    }
    
    func updateName(_ currentUser: User, name: String) {
        self.db.collection(_user)
        self.db.collection(self._user).document(currentUser.id).updateData(["name" : name])
    }
    
    func updateEmail(_ currentUser: User, email: String) {
        self.db.collection(_user)
        self.db.collection(self._user).document(currentUser.id).updateData(["email" : email])
    }
    
    func updatePassword(_ currentUser: User, password: String) {
        self.db.collection(_user)
        self.db.collection(self._user).document(currentUser.id).updateData(["password" : password])
    }
    
}
