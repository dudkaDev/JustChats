//
//  SetupProfileViewController.swift
//  JustChats
//
//  Created by Андрей Абакумов on 15.05.2023.
//

import UIKit
import FirebaseAuth

class SetupProfileViewController: UIViewController {
    
    private var stackView = UIStackView()
    
    private let waitingView = WaitingView()
    private let currentUser = Auth.auth().currentUser
    private var canShowSuccesses = false
    private let newNameTextField = UITextField(placeHolder: "Новое имя")
    private let newPasswordTextField = UITextField(passwordPlaceHolder: "Новый пароль")
    private let confirmNewPasswordTextField = UITextField(passwordPlaceHolder: "Подтвердите пароль")
    private let oldPasswordTextField = UITextField(passwordPlaceHolder: "Старый пароль")
    
    private let setupProfileLabel: UILabel = {
        let text = UILabel()
        text.text = "Настройка профиля"
        text.textColor = .black
        text.font = .boldSystemFont(ofSize: 40)
        text.numberOfLines = 2
        text.textAlignment = .center
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    private let passwordInfoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "questionmark.circle.fill"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let saveButton = UIButton(
        title: "Save",
        titleColor: .white,
        backgroundColor: .black,
        font: .systemFont(ofSize: 20),
        isShadow: false,
        cornerRadius: 10
    )
    
    private let closeButton = UIButton(
        image: UIImage(systemName: "xmark.circle.fill")!,
        tintColor: .black
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardObserves()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard let oldPassword = oldPasswordTextField.text else { return }
        waitingView.isWaiting(true)
        
        AuthService.shared.reAuth(oldPassword: oldPassword)
        canShowSuccesses = true
    }
    
    @objc private func passwordInfoButtonTapped() {
        let controller = PasswordDescriptionViewController()
        controller.modalPresentationStyle = .popover
        controller.preferredContentSize = CGSize(width: 260, height: 130)
        
        guard let presentationVC = controller.popoverPresentationController else { return }
        presentationVC.delegate = self
        presentationVC.sourceView = passwordInfoButton
        presentationVC.permittedArrowDirections = .down
        presentationVC.sourceRect = CGRect(x: passwordInfoButton.bounds.midX,
                                           y: passwordInfoButton.bounds.minY,
                                           width: 0,
                                           height: 0)
        
        present(controller, animated: true)
    }
    
    //MARK: - Проверка ввода полей textFields
    @objc func textFieldDidChange() {
        guard let newName = newNameTextField.text,
              let newPassword = newPasswordTextField.text,
              let confirmNewPassword = confirmNewPasswordTextField.text,
              let oldPassword = oldPasswordTextField.text else { return }
        
        if newPassword.isEmpty ||
            confirmNewPassword.isEmpty ||
            oldPassword.isEmpty ||
            !newPassword.isValidPassword() ||
            newPassword != confirmNewPassword
        {
            saveButton.isEnabled = false
            changeSaveButtonColor()
        } else {
            saveButton.isEnabled = true
            changeSaveButtonColor()
        }
        
        if newName.isEmpty {
            newNameTextField.resetShadow()
        } else {
            newNameTextField.becomeGreen()
        }
        
        if newPassword.isEmpty {
            newPasswordTextField.resetShadow()
        } else if newPassword.isValidPassword() {
            newPasswordTextField.becomeGreen()
        } else {
            newPasswordTextField.becomeRed()
        }
        
        if confirmNewPassword.isEmpty {
            confirmNewPasswordTextField.resetShadow()
        } else if confirmNewPassword == newPassword {
            confirmNewPasswordTextField.becomeGreen()
        } else {
            confirmNewPasswordTextField.becomeRed()
        }
    }
}

//MARK: - Private methods

extension SetupProfileViewController {
    
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        view.addSubview(setupProfileLabel)
        
        newNameTextField.text = currentUser?.displayName
        view.addSubview(newNameTextField)
        
        newPasswordTextField.showPasswordButton()
        view.addSubview(newPasswordTextField)
        
        confirmNewPasswordTextField.showPasswordButton()
        view.addSubview(confirmNewPasswordTextField)
        
        oldPasswordTextField.showPasswordButton()
        view.addSubview(oldPasswordTextField)
        
        view.addSubview(passwordInfoButton)
        passwordInfoButton.addTarget(self, action: #selector(passwordInfoButtonTapped), for: .touchUpInside)
        
        view.addSubview(saveButton)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        setupProfileLabel.textAlignment = .center
        stackView = UIStackView(arrangedSubviews: [setupProfileLabel,
                                                   newNameTextField,
                                                   newPasswordTextField,
                                                   confirmNewPasswordTextField,
                                                   oldPasswordTextField,
                                                   saveButton],
                                axis: .vertical,
                                spacing: 12)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        AuthService.shared.delegate = self
        
        newNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        newPasswordTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        confirmNewPasswordTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        oldPasswordTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        
        saveButton.isEnabled = false
        changeSaveButtonColor()
        
        waitingView.alpha = 0
        view.addSubview(waitingView)
    }
    
    private func changeSaveButtonColor() {
        if saveButton.isEnabled {
            saveButton.backgroundColor = .black
        } else {
            saveButton.backgroundColor = .lightGray
        }
    }
}

//MARK: - UIPopoverPresentationControllerDelegate

extension SetupProfileViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}

//MARK: - Keyboard methods

extension SetupProfileViewController {
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func removeKeyboardObserves() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        if newNameTextField.isEditing ||
            newPasswordTextField.isEditing ||
            confirmNewPasswordTextField.isEditing ||
            oldPasswordTextField.isEditing {
            
            let keyboardHeight = keyboardSize.height
            self.view.frame.origin.y = -keyboardHeight / 3
        }
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
}

//MARK: - AuthServiceDelegate

extension SetupProfileViewController: AuthServiceDelegate {
    
    func didAuthSuccessfully(authService: AuthService, authResult: AuthDataResult) {
        guard let name = newNameTextField.text else { return }
        AuthService.shared.updateName(name: name)
        
        if newPasswordTextField.text != nil, let password = newPasswordTextField.text {
            AuthService.shared.updatePassword(password: password)
        }
    }
    
    func changeInfoSuccessfully(authService: AuthService) {
        if canShowSuccesses {
            canShowSuccesses = false
            
            waitingView.isWaiting(false)
            
            showAlertAndDismiss(with: "Успешно", and: "Информация пользователя изменена")
            
            newNameTextField.resetShadow()
            newPasswordTextField.resetShadow()
            confirmNewPasswordTextField.resetShadow()
            oldPasswordTextField.resetShadow()
        }
    }
    
    func didReceiveError(authService: AuthService, error: Error) {
        waitingView.isWaiting(false)
        
        let error = error as NSError
        let errorAuthCode = AuthErrorCode(_nsError: error)
        let errorCode = errorAuthCode.code
        
        switch errorCode {
        case .networkError:
            showAlert(with: "Плохое соединение с интернетов", and: "")
        case .wrongPassword:
            oldPasswordTextField.shake()
        default: break
        }
    }
}

//MARK: - Set Constraints

extension SetupProfileViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 44),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -44),

            newNameTextField.heightAnchor.constraint(equalToConstant: 44),
            newPasswordTextField.heightAnchor.constraint(equalToConstant: 44),
            confirmNewPasswordTextField.heightAnchor.constraint(equalToConstant: 44),
            oldPasswordTextField.heightAnchor.constraint(equalToConstant: 44),
            saveButton.heightAnchor.constraint(equalToConstant: 44),
            
            passwordInfoButton.centerYAnchor.constraint(equalTo: newPasswordTextField.centerYAnchor),
            passwordInfoButton.leadingAnchor.constraint(equalTo: newPasswordTextField.trailingAnchor, constant: 4),
            
            waitingView.topAnchor.constraint(equalTo: view.topAnchor),
            waitingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            waitingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            waitingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

//MARK: - PreviewProvider

import SwiftUI

struct SetupProfileViewControllerProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }

    struct ContainerView: UIViewControllerRepresentable {

        let viewController = SetupProfileViewController()

        func makeUIViewController(context: Context) -> some UIViewController {
            return viewController
        }

        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

        }
    }
}
