//
//  SignUpViewcontroller.swift
//  ChatAppDemo
//
//  Created by BeeTech on 07/12/2022.
//

import UIKit
import RxSwift
import RxCocoa

protocol RegisterViewcontrollerDelegate {
    func callBackAccountResgiter(_ vc: RegisterViewcontroller, email: String, password: String)
}

class RegisterViewcontroller: UIViewController {
    static func instance(_ data: [User]) -> RegisterViewcontroller {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpScreen") as! RegisterViewcontroller
        vc.viewModel.user.append(contentsOf: data)
        return vc
    }
    
    @IBOutlet private weak var tfEmail: CustomTextField!
    @IBOutlet private weak var tfPassword: CustomTextField!
    @IBOutlet private weak var tfPhoneNumberPassword: CustomTextField!
    @IBOutlet private weak var imgAvtar: CustomImage!
    @IBOutlet private weak var btSignUp: UIButton!
    @IBOutlet private weak var tfName: CustomTextField!
    @IBOutlet private weak var lbErrorEmail: UILabel!
    @IBOutlet private weak var lbPasswordError: UILabel!
    @IBOutlet private weak var lbNameError: UILabel!
    
    var delegate: RegisterViewcontrollerDelegate?
    private var imgPicker = UIImagePickerController()
    
    private var disponeBag = DisposeBag()
    lazy private var viewModel = ResgiterPresenterView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        onBind()
    }
    //MARK: Methods
    private func setupUI() {
        setupImgAvatar()
        setupBtSigup()
        setupTextFile()
        setupLable()
    }
    
    private func onBind() {
        viewModel.nameErrorPublisher.bind(to: lbNameError.rx.text).disposed(by: disponeBag )
        lbNameError.isHidden = false
        viewModel.emailErrorPublisher.bind(to: lbErrorEmail.rx.text).disposed(by: disponeBag)
        lbErrorEmail.isHidden = false
        viewModel.passwordErrorPublisher.bind(to: lbPasswordError.rx.text).disposed(by: disponeBag)
        lbPasswordError.isHidden = false
        
        // Enable Button Sigin
        
        Observable.combineLatest(viewModel.nameErrorPublisher.map({$0 == nil})
                                 , viewModel.emailErrorPublisher.map({$0 == nil})
                                 , viewModel.passwordErrorPublisher.map({$0 == nil})).map({$0.0 && $0.1 && $0.2}).subscribe { bool in
            self.btSignUp.isEnabled = bool
        }.disposed(by: disponeBag)
        
    }
    
    private func setupLable() {
        lbNameError.isHidden = true
        lbErrorEmail.isHidden = true
        lbPasswordError.isHidden = true
        btSignUp.isEnabled = false
    }
    
    private func setupTextFile()  {
        //Name
        tfName.rx.controlEvent(.editingChanged).map {textField in
            return self.tfName.text
        }.subscribe(onNext: {text in
            self.viewModel.namePublisherSubject.onNext(text ?? "")
        }).disposed(by: disponeBag)
        
        //Email
        tfEmail.rx.controlEvent(.editingChanged).map { textField in
            return self.tfEmail.text
        }.subscribe(onNext: { text in
            self.viewModel.emailPublisherSubject.onNext(text ?? "")
        }).disposed(by: disponeBag)
        
        //Password
        tfPassword.rx.controlEvent(.editingChanged).map{textFiled in
            return self.tfPassword.text
        }.subscribe(onNext: {text in
            self.viewModel.passwordPublisherSubject.onNext(text ?? "")
        }).disposed(by: disponeBag)
    }
    
    
    
    private func setupImgAvatar() {
        imgAvtar.isUserInteractionEnabled = true
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(handelImage(_:)))
        imgAvtar.addGestureRecognizer(tapGes)
    }
    
    private func setupBtSigup() {
        btSignUp.layer.cornerRadius = 6
        btSignUp.layer.masksToBounds = true
        btSignUp.addTarget(self, action: #selector(didTapSignUp(_:)), for: .touchUpInside)
    }
    
   private func showAlertSuccess(_ title: String)  {
        let aler = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Xác nhận", style: .default) { action in
            self.delegate?.callBackAccountResgiter(self, email: self.tfEmail.text!, password: self.tfPassword.text!)
        }
        aler.addAction(action)
        present(aler, animated: true)
    }

    //MARK: Acction
    @objc private func didTapSignUp(_ sender: UIButton) {
        showAlertSuccess("Resigter Success")
        self.viewModel.createAccount(email: self.tfEmail.text!, password: self.tfPassword.text!, name: self.tfName.text!)
    }
    
    @objc private func handelImage(_ tapges: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Choose Image From", message: nil, preferredStyle: .actionSheet)
        
        let chooseImageFromLibrabriAction = UIAlertAction(title: "From Librabri", style: .default){ action in
            self.imgPicker.delegate = self
            self.imgPicker.sourceType = .photoLibrary
            self.present(self.imgPicker, animated: true)
        }
        let chooseImageFromCamera = UIAlertAction(title: "From Camera", style: .default) { action in
            self.imgPicker.delegate = self
            self.imgPicker.sourceType = .camera
            self.present(self.imgPicker, animated: true)
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(chooseImageFromLibrabriAction)
        alert.addAction(chooseImageFromCamera)
        alert.addAction(actionCancel)
        present(alert, animated: true)
    }
    
    @IBAction private func didTapbackLogin(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension RegisterViewcontroller: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.imgAvtar.image = img
        guard let img = img else { return }
        viewModel.getUrlAvatar(img)
        self.imgPicker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.imgPicker.dismiss(animated: true)
    }
}

