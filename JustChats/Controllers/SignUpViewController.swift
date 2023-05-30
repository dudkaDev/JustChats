//
//  SignUpViewController.swift
//  JustChats
//
//  Created by Андрей Абакумов on 10.05.2023.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    private var stackView = UIStackView()
    
    private let waitingView = WaitingView()
    private let nameTextField = UITextField(placeHolder: "Имя")
    private let emailTextField = UITextField(emailPlaceHolder: "Email")
    private let passwordTextField = UITextField(passwordPlaceHolder: "Пароль")
    private let confirmPasswordTextField = UITextField(passwordPlaceHolder: "Подтвердите пароль")
    
    private let signUpLabel: UILabel = {
        let label = UILabel()
        label.text = "Регистрация"
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 40)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let createAccountButton = UIButton(
        title: "Создать аккаунт",
        titleColor: .white,
        backgroundColor: .black,
        font: .systemFont(ofSize: 20),
        isShadow: false,
        cornerRadius: 10
    )
    
    private let passwordInfoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "questionmark.circle.fill"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
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
    
    @objc private func createAccountButtonTapped() {
        waitingView.isWaiting(true)
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text,
              let name = nameTextField.text else { return }
        
        AuthService.shared.createUser(
            email: email,
            password: password,
            confirmPassword: confirmPassword,
            name: name
        )
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
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text,
              let name = nameTextField.text else { return }
        
        if name.isEmpty ||
            email.isEmpty ||
            password.isEmpty ||
            confirmPassword.isEmpty ||
            !email.isValidEmail() ||
            !password.isValidPassword() ||
            password != confirmPassword
        {
            createAccountButton.isEnabled = false
            changeCreateAccountButtonColor()
        } else {
            createAccountButton.isEnabled = true
            changeCreateAccountButtonColor()
        }
        
        if name.isEmpty {
            nameTextField.resetShadow()
        } else {
            nameTextField.becomeGreen()
        }
        
        if email.isEmpty {
            emailTextField.resetShadow()
        } else if email.isValidEmail() {
            emailTextField.becomeGreen()
        } else {
            emailTextField.becomeRed()
        }
        
        if password.isEmpty {
            passwordTextField.resetShadow()
        } else if password.isValidPassword() {
            passwordTextField.becomeGreen()
        } else {
            passwordTextField.becomeRed()
        }
        
        if confirmPassword.isEmpty {
            confirmPasswordTextField.resetShadow()
        } else if confirmPassword == password {
            confirmPasswordTextField.becomeGreen()
        } else {
            confirmPasswordTextField.becomeRed()
        }
    }
}

//MARK: - Private methods

extension SignUpViewController {
    
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        view.addSubview(signUpLabel)
        view.addSubview(nameTextField)
        view.addSubview(emailTextField)
        
        passwordTextField.showPasswordButton()
        view.addSubview(passwordTextField)
        
        confirmPasswordTextField.showPasswordButton()
        view.addSubview(confirmPasswordTextField)
        
        view.addSubview(createAccountButton)
        createAccountButton.addTarget(self, action: #selector(createAccountButtonTapped), for: .touchUpInside)
        
        view.addSubview(passwordInfoButton)
        passwordInfoButton.addTarget(self, action: #selector(passwordInfoButtonTapped), for: .touchUpInside)
        
        signUpLabel.textAlignment = .center
        stackView = UIStackView(arrangedSubviews: [signUpLabel,
                                                   nameTextField,
                                                   emailTextField,
                                                   passwordTextField,
                                                   confirmPasswordTextField,
                                                   createAccountButton],
                                axis: .vertical,
                                spacing: 12)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        AuthService.shared.delegate = self
        
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        
        createAccountButton.isEnabled = false
        changeCreateAccountButtonColor()
        
        waitingView.alpha = 0
        view.addSubview(waitingView)
    }
    
    private func changeCreateAccountButtonColor() {
        if createAccountButton.isEnabled {
            createAccountButton.backgroundColor = .black
        } else {
            createAccountButton.backgroundColor = .lightGray
        }
    }
}

//MARK: - Keyboard methods

extension SignUpViewController {
    
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
        if nameTextField.isEditing ||
            emailTextField.isEditing ||
            passwordTextField.isEditing ||
            confirmPasswordTextField.isEditing {
            
            let keyboardHeight = keyboardSize.height
            self.view.frame.origin.y = -keyboardHeight / 3
        }
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
}

//MARK: - AuthServiceDelegate

extension SignUpViewController: AuthServiceDelegate {
    
    func didReceiveError(authService: AuthService, error: Error) {
        waitingView.isWaiting(false)
        
        let error = error as NSError
        let errorAuthCode = AuthErrorCode(_nsError: error)
        let errorCode = errorAuthCode.code
        
        switch errorCode {
        case .emailAlreadyInUse:
            emailTextField.shake()
            showAlert(with: "Такой email уже используется", and: "")
        case .invalidEmail:
            emailTextField.shake()
            showAlert(with: "Некорректный email", and: "")
        case .networkError:
            showAlert(with: "Ошибка соединения с интернетом", and: "")
        default: break
        }
    }
    
    func didCreateUser(authService: AuthService, authResult: AuthDataResult) {
        waitingView.isWaiting(false)
        
        let chatViewController = ChatViewController()
        let navController = UINavigationController(rootViewController: chatViewController)
        navController.modalPresentationStyle = .fullScreen

        present(navController, animated: true) {
            self.nameTextField.text = ""
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
            self.confirmPasswordTextField.text = ""
            
            self.nameTextField.resetShadow()
            self.emailTextField.resetShadow()
            self.passwordTextField.resetShadow()
            self.confirmPasswordTextField.resetShadow()
        }
    }
}

//MARK: - UIPopoverPresentationControllerDelegate

extension SignUpViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}

//MARK: - Set Constraints

extension SignUpViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 44),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -44),
            
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 44),
            createAccountButton.heightAnchor.constraint(equalToConstant: 44),
            
            passwordInfoButton.centerYAnchor.constraint(equalTo: passwordTextField.centerYAnchor),
            passwordInfoButton.leadingAnchor.constraint(equalTo: passwordTextField.trailingAnchor, constant: 4),
            
            waitingView.topAnchor.constraint(equalTo: view.topAnchor),
            waitingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            waitingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            waitingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

//MARK: - PreviewProvider

import SwiftUI

struct SignUpViewControllerProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let viewController = SignUpViewController()
        
        func makeUIViewController(context: Context) -> some UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
        }
    }
}
