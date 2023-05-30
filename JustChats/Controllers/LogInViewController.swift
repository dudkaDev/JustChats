//
//  LogInViewController.swift
//  JustChats
//
//  Created by Андрей Абакумов on 10.05.2023.
//

import UIKit
import Firebase

class LogInViewController: UIViewController {
    
    private var stackView = UIStackView()
    
    private let waitingView = WaitingView()
    
    private let emailTextField = UITextField(emailPlaceHolder: "Email")
    private let passwordTextField = UITextField(passwordPlaceHolder: "Password")
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let logInLabel: UILabel = {
        let text = UILabel()
        text.text = "Вход"
        text.textColor = .black
        text.font = .boldSystemFont(ofSize: 40)
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    private let logInButton = UIButton(
        title: "Войти",
        titleColor: .white,
        backgroundColor: .black,
        font: .systemFont(ofSize: 20),
        isShadow: false,
        cornerRadius: 10
    )
    
    lazy private var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Забыли пароль?", for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy private var closeButton = UIButton(
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
    
    @objc private func logInButtonTapped() {
        waitingView.isWaiting(true)
        
        emailTextField.resetShadow()
        passwordTextField.resetShadow()
        
        guard let email = emailTextField.text,
                let password = passwordTextField.text else { return }
        
        AuthService.shared.login(email: email, password: password)
    }
    
    @objc private func forgotPasswordButtonTapped() {
        let resetPasswordVC = ResetPasswordViewController()
        present(resetPasswordVC, animated: true)
    }
}

//MARK: - Private methods

extension LogInViewController {
    
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        view.addSubview(logInLabel)
        view.addSubview(emailTextField)
        
        passwordTextField.showPasswordButton()
        view.addSubview(passwordTextField)
        
        view.addSubview(logInButton)
        logInButton.addTarget(self, action: #selector(logInButtonTapped), for: .touchUpInside)
        
        view.addSubview(forgotPasswordButton)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonTapped), for: .touchUpInside)
        
        logInLabel.textAlignment = .center
        forgotPasswordButton.contentHorizontalAlignment = .trailing
        stackView = UIStackView(arrangedSubviews: [logInLabel,
                                                   emailTextField,
                                                   passwordTextField,
                                                   forgotPasswordButton,
                                                   logInButton],
                                axis: .vertical,
                                spacing: 12)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        AuthService.shared.delegate = self
        
        waitingView.alpha = 0
        view.addSubview(waitingView)
    }
}

//MARK: - AuthServiceDelegate

extension LogInViewController: AuthServiceDelegate {
    
    func didAuthSuccessfully(authService: AuthService, authResult: AuthDataResult) {
        waitingView.isWaiting(false)
        
        let chatViewController = ChatViewController()

        let navController = UINavigationController(rootViewController: chatViewController)
        navController.modalPresentationStyle = .fullScreen

        self.present(navController, animated: true) {
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
        }
    }
    
    func didReceiveError(authService: AuthService, error: Error) {
        waitingView.isWaiting(false)
        
        let error = error as NSError
        let errorAuthCode = AuthErrorCode(_nsError: error)
        let errorCode = errorAuthCode.code
        
        switch errorCode {
        case .invalidEmail:
            emailTextField.shake()
            passwordTextField.text = ""
            showAlert(with: "Некорректный email", and: "")
        case .userNotFound:
            emailTextField.shake()
            passwordTextField.text = ""
            showAlert(with: "Пользователь с таким email не найден.", and: "")
        case .networkError:
            showAlert(with: "Ошибка соединения с интернетом", and: "")
        case .wrongPassword:
            passwordTextField.shake()
        default: break
        }
    }
}

//MARK: - Keyboard methods

extension LogInViewController {
    
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

        if emailTextField.isEditing || passwordTextField.isEditing {
            let keyboardHeight = keyboardSize.height

            self.view.frame.origin.y = -keyboardHeight / 3
        }
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
}

//MARK: - Set Constraints

extension LogInViewController {
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 44),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -44),

            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            logInButton.heightAnchor.constraint(equalToConstant: 44),
            
            waitingView.topAnchor.constraint(equalTo: view.topAnchor),
            waitingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            waitingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            waitingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

//MARK: - PreviewProvider

import SwiftUI

struct LogInViewControllerProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let viewController = LogInViewController()
        
        func makeUIViewController(context: Context) -> some UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
        }
    }
}
