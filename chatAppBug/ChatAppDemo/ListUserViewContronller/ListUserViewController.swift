//
//  ListUserViewController.swift
//  ChatAppDemo
//
//  Created by BeeTech on 07/12/2022.
//

import UIKit
import RxSwift
import RxCocoa

final class ListUserViewController: UIViewController {
    static func instance(_ currentUser: User) -> ListUserViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "listUserScreen") as! ListUserViewController
        vc.viewModel = ListUserViewModel(with: currentUser)
        return vc
    }
    
    @IBOutlet private weak var messageTable: UITableView!
    @IBOutlet private weak var searchUser: UITextField!
    @IBOutlet private weak var avatar: UIImageView!
    @IBOutlet private weak var btSetting: UIButton!
    @IBOutlet private weak var lbNameUser: UILabel!
    @IBOutlet private weak var imgState: UIImageView!
    @IBOutlet private weak var listUserActive: UICollectionView!
    @IBOutlet private weak var lbNewMessageNotification: UILabel!
    @IBOutlet private weak var listAllUser: UITableView!
    @IBOutlet private weak var viewUser: UIView!
    @IBOutlet private weak var btCancelSearchUser: UIButton!
    @IBOutlet private weak var listAllUserTopContrain: NSLayoutConstraint!
    @IBOutlet private weak var heightSearchUserContrains: NSLayoutConstraint!
    @IBOutlet private weak var trailingSearchUserContrains: NSLayoutConstraint!
    @IBOutlet private weak var heightCollectionViewContrains: NSLayoutConstraint!
    
    private var viewModel: ListUserViewModel!
    private var disponeBag = DisposeBag()
    lazy private var presenterCell = ListCellPresenter()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
        onBind()
    }
    private func setupData() {
        viewModel.fetchUserRxSwift()
        viewModel.fectchMessageRxSwift()
        viewModel.getImageForCurrentUser()
    }

    private func setupUI() {
        setupMessagetable()
        setupSearchUser()
        setupImageForCurrentUser()
        setupBtSetting()
        setupLbNameUser()
        setuplbNewMessageNotification()
        setupBtCacncelSearchUser()
        setuplbNewMessageNotification()
    }
    
    private func onBind() {
        setupCollectionViewRxSwift()
        setupListUserTableView()
        viewModel.imgAvatarUserPublisher.subscribe {[weak self] img in
            DispatchQueue.main.async {
                self?.avatar.image = img
            }
        }.disposed(by: disponeBag)
    }
    
    private func setupCollectionViewRxSwift() {
        //MARK: Show or hide collectionview when Have User Active
        viewModel.activeUsers.subscribe { [weak self] users in
            if let users = users.element {
                if users.count == 0 {
                    self?.heightCollectionViewContrains.constant = 0
                }else {
                    self?.heightCollectionViewContrains.constant = 128
                }
            }
        }.disposed(by: disponeBag)
        //MARK: list User ACtive
        guard let currentUser = viewModel.currentUser else {return}
        viewModel.activeUsers.bind(to: self.listUserActive.rx
            .items(cellIdentifier: "listActiveUserCell"
                   ,cellType: ListUserActiveCollectionCell.self)) { index, data, cell in
            cell.updateUI(data, text: self.searchUser.text ?? "")
        }.disposed(by: disponeBag)
         //MARK: Seclected model
        self.listUserActive.rx.modelSelected(User.self).bind { user in
            let vc = DetailViewViewController.instance(user, currentUser: currentUser)
            self.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: self.disponeBag)
        listUserActive.rx.setDelegate(self).disposed(by: disponeBag)
    }
    
    private func setupListUserTableView() {
        guard let currentUser = viewModel.currentUser else {return}
        //MARK: ListAllUser UITabeView
        listAllUser.rx.setDelegate(self).disposed(by: disponeBag)
        listAllUser.isHidden = true
        viewModel.finalUser.bind(to: self.listAllUser.rx.items(cellIdentifier: "listUsertableCell", cellType: ListAllUserTableCell.self)) { index, data, cell in
            cell.updateUI(data)
        }.disposed(by: disponeBag)
        //MARK: ModelSelected
        listAllUser.rx.modelSelected(User.self).subscribe {[weak self] user in
            let vc = DetailViewViewController.instance(user, currentUser: currentUser)
            self?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disponeBag)
        
        //MARK: MessageTableView
        messageTable.rx.setDelegate(self).disposed(by: disponeBag)
        viewModel.messageBehaviorSubject.bind(to: self.messageTable.rx.items(cellIdentifier: "messageforUserCell", cellType: MessageForUserCell.self)) { index, data, cell in
            self.viewModel.reciverUser.subscribe { users in
                if let user = users.element {
                    for user in user {
                        cell.updateUI(currentUser, message: data, reciverUser: user)
                    }
                }
            }.disposed(by: self.disponeBag)
        }.disposed(by: disponeBag)
        
        //MARK: ModelSeclected
        messageTable.rx.modelSelected(Message.self).subscribe {[weak self] mess in
            if let mess = mess.element {
                if mess.sendId == currentUser.id {
                    self?.viewModel.changesStateReadMessage()
                }
                if mess.receiverID == currentUser.id {
                    let user = User(name: mess.nameSender, id: mess.sendId, picture: mess.avataSender, email: "", password: "", isActive: false)
                    let vc = DetailViewViewController.instance(user, currentUser: currentUser)
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                
                if mess.sendId == currentUser.id {
                    let user2 = User(name: mess.receivername, id: mess.receiverID, picture: mess.avatarReciverUser, email: "", password: "", isActive: false)
                    let vc = DetailViewViewController.instance(user2, currentUser: currentUser)
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }.disposed(by: disponeBag)
    }
    
    private func setupBtCacncelSearchUser() {
        btCancelSearchUser.isHidden = true
        btCancelSearchUser.addTarget(self, action: #selector(didtapCancel(_:)), for: .touchUpInside)
    }
    
    private func setupMessagetable() {
        messageTable.separatorStyle = .none
    }
    
    private func setupSearchUser() {
        searchUser.layer.cornerRadius = 5
        searchUser.layer.masksToBounds = true
        searchUser.layer.borderWidth = 1
        searchUser.layer.borderColor = UIColor.black.cgColor
        searchUser.delegate = self
        searchUser.rx.controlEvent(.editingChanged).map {[weak self] textField in
            return self?.searchUser.text
        }.subscribe(onNext: {[weak self]text in
            self?.viewModel.searchUserPublisher.onNext(text ?? "")
        }).disposed(by: disponeBag)
    }
    
    private func setupImageForCurrentUser() {
        avatar.layer.cornerRadius = avatar.frame.height / 2
        avatar.layer.masksToBounds = true
        avatar.layer.borderWidth = 1
        avatar.layer.borderColor = UIColor.black.cgColor
        avatar.contentMode = .scaleToFill
    }
    
    private func setupLbNameUser() {
        guard let currentuser = viewModel.getcurrentUser() else { return }
        lbNameUser.text = currentuser.name
    }
    
    private func setuplbNewMessageNotification() {
        lbNewMessageNotification.isHidden = true
        lbNewMessageNotification.text = "No new message \nNew messages will show up here"
        viewModel.messageBehaviorSubject.subscribe { messages in
            if let messages = messages.element {
                if messages.count == 0 {
                    self.lbNewMessageNotification.isHidden = false
                }else {
                    self.lbNewMessageNotification.isHidden = true
                }
            }
        }.disposed(by: disponeBag)
    }
    
    private func setupBtSetting() {
        btSetting.setTitle("", for: .normal)
        btSetting.addTarget(self, action: #selector(didTapSetting(_:)), for: .touchUpInside)
    }
    //MARK: -ACtion
   
    @objc private func didTapSetting(_ sender: Any) {
       guard let user = viewModel.getcurrentUser() else {return}
        let vc = SettingViewController.instance(user)
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc private func didtapCancel(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            self.listAllUser.isHidden = true
            self.listUserActive.isHidden = false
            self.messageTable.isHidden = false
            self.viewUser.isHidden = false
            self.listAllUserTopContrain.constant = 640
            self.trailingSearchUserContrains.constant = 20
            self.heightSearchUserContrains.constant = 65
            self.btCancelSearchUser.isHidden = false
        }
        view.endEditing(true)
    }
}
// MARK: Extension TableView
extension ListUserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

// MARK: Extension collectionView
extension ListUserViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}

//MARK: Extension
extension ListUserViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === searchUser {
            UIView.animate(withDuration: 0.2) {
                self.listAllUser.isHidden = false
                self.listUserActive.isHidden = true
                self.messageTable.isHidden = true
                self.viewUser.isHidden = true
                self.listAllUserTopContrain.constant = 40
                self.trailingSearchUserContrains.constant = 100
                self.heightSearchUserContrains.constant = 5
                self.btCancelSearchUser.isHidden = false
            }
        }
        return true
    }
}
