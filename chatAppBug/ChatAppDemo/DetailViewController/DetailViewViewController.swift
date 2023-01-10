//
//  DetailViewViewController.swift
//  ChatAppDemo
//
//  Created by mr.root on 12/7/22.
//

import UIKit
import RxSwift
import RxCocoa

final class DetailViewViewController: UIViewController {
    static func instance(_ data: User, currentUser: User) -> DetailViewViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailScreen") as! DetailViewViewController
        vc.viewModel = DetailViewModel( data: data, currentUser: currentUser)
        return vc
    }
    
    @IBOutlet private weak var image: UIImageView!
    @IBOutlet private weak var tvMessage: UITextView!
    @IBOutlet private weak var btSendMessage: UIButton!
    @IBOutlet private weak var convertiontable: UITableView!
    @IBOutlet private weak var goBack: UIButton!
    @IBOutlet private weak var imgUser: UIImageView!
    @IBOutlet private weak var lbState: UILabel!
    @IBOutlet private weak var lbNameUser: UILabel!
    @IBOutlet private weak var imgStateUser: CustomImage!
    @IBOutlet private weak var heightTextViewContrains: NSLayoutConstraint!
    @IBOutlet private weak var bottomTfMessageContrains: NSLayoutConstraint!
    @IBOutlet private weak var bottomImageContrains: NSLayoutConstraint!
    @IBOutlet private weak var bottomSenImageContrains: NSLayoutConstraint!
    @IBOutlet weak var bottomTableView: NSLayoutConstraint!
    
    private let bag = DisposeBag()
    private var imgPicker = UIImagePickerController()
    private var viewModel: DetailViewModel!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindTableView()
        self.viewModel.fetchMessage()
    }
   
    private func setupUI() {
        setupMessageTextField()
        setupImage()
        setupBtSend()
        setupConvertionTable()
        setupGoBackButton()
        showStateReciverUser()
        keyBoardObserver()
    }
    
     private func keyBoardObserver() {
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func showStateReciverUser() {
        viewModel.fetchStateUser()
    }
   
    private func setupGoBackButton() {
        goBack.setTitle("", for: .normal)
        goBack.addTarget(self, action: #selector(didTapBackListScreen(_:)), for: .touchUpInside)
    }
    
    private func setupConvertionTable() {
        convertiontable.separatorStyle = .none
        convertiontable.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        let imgCell = UINib(nibName: "ImgCell", bundle: nil)
        convertiontable.register(imgCell, forCellReuseIdentifier: "imgCell")
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleViewEndEditing(_:)))
        convertiontable.addGestureRecognizer(gesture)
        
        let messageCell = UINib(nibName: "MessageCell", bundle: nil)
        convertiontable.register(messageCell, forCellReuseIdentifier: "messageCell")
        
        let reciverUser = UINib(nibName: "ReciverUserCell", bundle: nil)
        convertiontable.register(reciverUser, forCellReuseIdentifier: "reciverUser")
    }
    
    private func bindTableView() {
        //MARK: UItableView
        let currentUser = viewModel.getCurrentUser()
        convertiontable.rx.setDelegate(self).disposed(by: bag)
        
        viewModel.messageBehaviorSubject.bind(to: self.convertiontable.self.rx.items) { tableview, index, data in
            if data.text.isEmpty {
                let cell = self.convertiontable.dequeueReusableCell(withIdentifier: "imgCell") as! ImgCell
                cell.updateUI(data, currentUser: currentUser)
                return cell
            }
            
            if data.sendId == currentUser?.id {
                let cell = self.convertiontable.dequeueReusableCell(withIdentifier: "messageCell") as! MessageCell
                cell.updateUI(data)
                return cell
            } else {
                let cell = self.convertiontable.dequeueReusableCell(withIdentifier: "reciverUser") as! ReciverUserCell
                cell.updateUI(data)
                self.scrollToBottom()
                return cell
            }
           
        }
        .disposed(by: bag)
        //MARK: ShowUser, stateActive
        viewModel.stateUserPublisher.subscribe {[weak self] users in
            if let users = users.element {
                users.forEach { user in
                    self?.lbNameUser.text  = user.name
                    self?.lbState.text = user.isActive ? "Active now" : "Not active"
                    self?.imgStateUser.tintColor = user.isActive ? .systemGreen : .systemGray
                }
            }
        }.disposed(by: bag)
        viewModel.imageUserPublisher.subscribe {[weak self] image in
            if let image = image {
                DispatchQueue.main.async {
                    self?.imgUser.image = image
                }
            }
        }.disposed(by: bag)
    }
    
    private func setupMessageTextField() {
        tvMessage.delegate = self
        tvMessage.layer.cornerRadius = 6
        tvMessage.layer.masksToBounds = true
        tvMessage.isScrollEnabled = true
    }
    
    private func setupImage() {
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseImage(_:))))
        image.isUserInteractionEnabled = true
    }
    
    private func setupBtSend() {
        btSendMessage.setTitle(" ", for: .normal)
        btSendMessage.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        btSendMessage.addTarget(self, action: #selector(didTapSend(_:)), for: .touchUpInside)
    }
    
    private func sendMessage() {
        guard let message = tvMessage.text else {return}
        if message.isEmpty {
            viewModel.sendLikeSymbols()
            view.endEditing(true)
            return
        }
        viewModel.sendMessage(with: message)
        tvMessage.text = ""
        btSendMessage.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        heightTextViewContrains.constant = 33
        view.layoutIfNeeded()
        self.scrollToBottom()
    }
    
    private func scrollToBottom() {
        DispatchQueue.main.async {
            if self.viewModel.getNumberOfMessage() < 1 { return }
            let indexPath = IndexPath(row: self.viewModel.getNumberOfMessage() - 1, section: 0)
            self.convertiontable.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    //MARK: -Acction
    @objc private func didTapSend(_ sender: UIButton) {
        self.sendMessage()
    }
    
    @objc private func chooseImage(_ tapGes: UITapGestureRecognizer) {
        self.imgPicker.delegate = self
        self.imgPicker.sourceType = .photoLibrary
        present(self.imgPicker, animated: true)
    }
    
    @objc private func didTapBackListScreen(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleViewEndEditing(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
//MARK: -Extension UIImagePickerControllerDelegate
extension DetailViewViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        guard let image = image else { return }
        self.viewModel.sendImageMessage(with: image)
        self.imgPicker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.imgPicker.dismiss(animated: true)
    }
}
//MARK: -Extension UitableView
extension DetailViewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = viewModel.getMessage(indexPath.row)
        if message.text.isEmpty {
            return 280 / (message.ratioImage)
        } else {
            return UITableView.automaticDimension
        }
    }
}
//MARK: Extension UItextFiled
extension DetailViewViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.sendMessage()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        btSendMessage.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
    }
}
extension DetailViewViewController {
    @objc func keyboardWillShow(_ sender: NSNotification) {
        let keyboardframe = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]! as! NSValue).cgRectValue.height
        self.bottomTfMessageContrains.constant = keyboardframe + 10
        self.bottomImageContrains.constant = keyboardframe + 10
        self.bottomSenImageContrains.constant = keyboardframe + 10
        self.scrollToBottom()
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(_ sender: NSNotification) {
        self.bottomTfMessageContrains.constant = 20
        self.bottomImageContrains.constant = 20
        self.bottomSenImageContrains.constant = 20
        self.scrollToBottom()
        self.view.layoutIfNeeded()
    }
}

extension DetailViewViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: view.frame.width, height: .infinity)
        let esimatedSize = textView.sizeThatFits(size)
        guard let message = tvMessage.text else {return }
        if tvMessage.contentSize.height < 120 {
            heightTextViewContrains.constant = esimatedSize.height
        } else {
            heightTextViewContrains.constant = 100
        }
        if message.isEmpty {
            btSendMessage.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)

        } else {
            btSendMessage.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        }
        self.scrollToBottom()
        self.view.layoutIfNeeded()
    }
}
