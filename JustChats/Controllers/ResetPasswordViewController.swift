//
//  ResetPasswordViewController.swift
//  JustChats
//
//  Created by Андрей Абакумов on 11.05.2023.
//

import UIKit
import Firebase

class ResetPasswordViewController: UIViewController {

    private var stackView = UIStackView()
    
    private let waitingView = WaitingView()
    private let emailTextField = UITextField(emailPlaceHolder: "Email")
    
    private let resetLabel: UILabel = {
        let text = UILabel()
        text.text = "Восстановление пароля"
        text.textColor = .black
        text.font = .boldSystemFont(ofSize: 36)
        text.numberOfLines = 2
        text.textAlignment = .center
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    private let resetButton = UIButton(
        title: "Восстановить",
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
    
    @objc private func resetButtonTapped() {
        waitingView.isWaiting(true)
        
        emailTextField.resetShadow()
        
        guard let email = emailTextField.text else { return }
        AuthService.shared.resetPassword(email)
    }
}

//MARK: - Private methods

extension ResetPasswordViewController {
    
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        view.addSubview(resetLabel)
        view.addSubview(emailTextField)
        
        view.addSubview(resetButton)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        
        waitingView.alpha = 0
        view.addSubview(waitingView)
        
        resetLabel.textAlignment = .center
        stackView = UIStackView(arrangedSubviews: [resetLabel,
                                                   emailTextField,
                                                   resetButton],
                                axis: .vertical,
                                spacing: 12)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        AuthService.shared.delegate = self
    }
}

//MARK: - Keyboard methods

extension ResetPasswordViewController {
    
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
        if emailTextField.isEditing {
            let keyboardHeight = keyboardSize.height
            self.view.frame.origin.y = -keyboardHeight / 3
        }
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
}

//MARK: - AuthServiceDelegate

extension ResetPasswordViewController: AuthServiceDelegate {
    
    func didSendResetPassword(authService: AuthService) {
        waitingView.isWaiting(false)
        
        showAlertAndDismiss(with: "Успешно", and: "Email для сброса пароля отправлен")
        emailTextField.text = ""
    }
    
    func didReceiveError(authService: AuthService, error: Error) {
        waitingView.isWaiting(false)
        
        let error = error as NSError
        let errorAuthCode = AuthErrorCode(_nsError: error)
        let errorCode = errorAuthCode.code
        
        switch errorCode {
        case .invalidEmail:
            emailTextField.shake()
            showAlert(with: "Некорректный email", and: "")
        case .userNotFound:
            emailTextField.shake()
            showAlert(with: "Пользователь с таким email не найден.", and: "")
        case .networkError:
            showAlert(with: "Ошибка соединения с интернетом", and: "")
        default: print(error)
        }
    }
}

//MARK: - Set Constraints

extension ResetPasswordViewController {
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 44),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -44),

            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            resetButton.heightAnchor.constraint(equalToConstant: 44),
            
            waitingView.topAnchor.constraint(equalTo: view.topAnchor),
            waitingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            waitingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            waitingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

//MARK: - PreviewProvider

import SwiftUI

struct ResetPasswordViewControllerProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let viewController = ResetPasswordViewController()
        
        func makeUIViewController(context: Context) -> some UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
        }
    }
}
