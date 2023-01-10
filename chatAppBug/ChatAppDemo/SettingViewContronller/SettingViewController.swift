//
//  SettingViewController.swift
//  ChatAppDemo
//
//  Created by BeeTech on 15/12/2022.
//

import UIKit
import FBSDKLoginKit
import ZaloSDK

final class SettingViewController: UIViewController {
    static func instance(_ user: User) -> SettingViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "settingScreen") as! SettingViewController
        vc.presenter = SettingPresenter(with: vc, user: user)
        return vc
    }
    
    @IBOutlet private weak var tfName: UITextField!
    @IBOutlet private weak var imgAvatar: CustomImage!
    @IBOutlet private weak var tfEmail: UITextField!
    @IBOutlet private weak var tfPassword: UITextField!
    @IBOutlet private weak var btLogout: UIButton!
    @IBOutlet private weak var btUpdate: CustomButton!
    @IBOutlet private weak var btUpdateName: CustomButton!
    @IBOutlet private weak var btUpdateEmail: CustomButton!
    
  
    private let imgPickerView = UIImagePickerController()
    private var presenter: SettingPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        self.navigationItem.title = "Setting"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
        btUpdate.isHidden = true
        btUpdateName.isHidden = true
        btUpdateEmail.isHidden = true
    }
    private func setupUI() {
        setUpBtLogOut()
        showInforUser()
        setUpBtUpdate()
        setupTextField()
    }
    

    private func setUpBtLogOut() {
        btLogout.setTitle("Log Out", for: .normal)
        btLogout.addTarget(self, action: #selector(didTapLogOut(_:)), for: .touchUpInside)
    }
    
    private func setUpBtUpdate() {
        // Button Update Name
        btUpdateName.isHidden = true
        btUpdateName.setTitle("Update Name", for: .normal)
        btUpdateName.addTarget(self, action: #selector(didTapUpdate(_:)), for: .touchUpInside)
        // Button Update Email
        
        btUpdateEmail.isHidden = true
        btUpdateEmail.setTitle("Update Email", for: .normal)
        btUpdateEmail.addTarget(self, action: #selector(didTapUpdate(_:)), for: .touchUpInside)
        
        // Button Update
        btUpdate.isHidden = true
        btUpdate.setTitle("Update", for: .normal)
        btUpdate.addTarget(self, action: #selector(didTapUpdate(_:)), for: .touchUpInside)
    }
    
    private func setupTextField() {
        tfName.delegate = self
        tfEmail.delegate = self
        tfPassword.delegate = self
    }
    
    private func showInforUser() {
        guard let user = presenter.getUser() else {return}
        tfName.text = user.name
        tfEmail.text = user.email
        tfPassword.text = user.password
        ImageService.share.fetchImage(with: user.picture) { image in
            DispatchQueue.main.async {
                self.imgAvatar.image = image
            }
        }
    }
    
    // MARK: Action
    
    @objc private func didTapLogOut(_ sender: UIButton) {
        presenter.setStateUserForLogOut()
        presenter.logoutFacebook()
        presenter.logoutZalo()
        presenter.logoutGoogle()
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction private func didTapChangeAvatar(_ sender: Any) {
        btUpdate.isHidden = false
        self.imgPickerView.delegate = self
        self.imgPickerView.sourceType = .photoLibrary
        present(self.imgPickerView, animated: true)
        
    }
    
    @objc private func didTapUpdate(_ sender: UIButton) {
        if sender === btUpdateName {
            guard let name = tfName.text else {return}
            presenter.changeName(name: name)
            self.btUpdateName.isHidden = true
            return
        }
        if sender === btUpdateEmail {
            guard let email = tfEmail.text else { return }
            presenter.changeEmail(email: email)
            self.btUpdateEmail.isHidden = true
            return
        }
        if sender === btUpdate {
            guard let password = tfPassword.text else {return}
            presenter.changePassword(password: password)
            presenter.changeAvatar()
            self.btUpdate.isHidden = true
            return
        }
        
    }
}

extension SettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.imgAvatar.image = image
        guard let image = image else {return}
        presenter.fetchNewAvatarUrl(image)
        dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.btUpdate.isHidden = true
        dismiss(animated: true)
    }
}


extension SettingViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === tfName {
            btUpdateName.isHidden = false
        }else if textField === tfEmail {
            btUpdateEmail.isHidden = false
        }else if textField === tfPassword {
            btUpdate.isHidden = false
        }
        return true
    }
}

extension SettingViewController: SettingPresenterDelegate {
    
}



