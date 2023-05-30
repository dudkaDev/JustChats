//
//  AuthService.swift
//  JustChats
//
//  Created by Андрей Абакумов on 11.05.2023.
//

import UIKit
import Firebase
import FirebaseAuth

protocol AuthServiceDelegate: AnyObject {
    func didReceiveError(authService: AuthService, error: Error)
    func didAuthSuccessfully(authService: AuthService, authResult: AuthDataResult)
    func didCreateUser(authService: AuthService, authResult: AuthDataResult)
    func changeInfoSuccessfully(authService: AuthService)
    func didSendResetPassword(authService: AuthService)
}

extension AuthServiceDelegate {
    func didReceiveError(authService: AuthService, error: Error) {}
    func didAuthSuccessfully(authService: AuthService, authResult: AuthDataResult) {}
    func didCreateUser(authService: AuthService, authResult: AuthDataResult) {}
    func changeInfoSuccessfully(authService: AuthService) {}
    func didSendResetPassword(authService: AuthService) {}
}

class AuthService {
    
    static let shared = AuthService()
    private let auth = Auth.auth()
    
    weak var delegate: AuthServiceDelegate?
    
    // Выход из аккаунта
    func logOut() {
        do {
            try auth.signOut()
            UIApplication.shared.keyWindow?.rootViewController = StartingViewController()
        } catch {
            
            print(error.localizedDescription)
        }
    }
    
    // Авторизация пользователя
    func login(email: String, password: String) {
        //Удаление пробелов впереди и сзади текста
        let email = email.trimSpaces()
        
        auth.signIn(withEmail: email, password: password) { authResult, error in
            switch error {
            case .none:
                guard let result = authResult else { return }
                self.delegate?.didAuthSuccessfully(authService: self, authResult: result)
            case .some(let error):
                self.delegate?.didReceiveError(authService: self, error: error)
            }
        }
    }
    
    // Регистрация пользователя
    func createUser(email: String, password: String, confirmPassword: String, name: String) {
        //Удаление пробелов впереди и сзади текста
        let email = email.trimSpaces()
        let name = name.trimSpaces()
        
        auth.createUser(withEmail: email, password: password) { authResult, error in
            switch error {
            case .none:
                guard let result = authResult else { return }
                self.delegate?.didCreateUser(authService: self, authResult: result)
                self.updateName(name: name)
            case .some(let error):
                self.delegate?.didReceiveError(authService: self, error: error)
            }
        }
    }
    
    // Проверка аутентификации
    func reAuth(oldPassword: String) {
        let currentUser = auth.currentUser
        
        guard let email = currentUser?.email else { return }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)
        
        currentUser?.reauthenticate(with: credential) { authResult, error in
            switch error {
            case .none:
                guard let result = authResult else { return }
                self.delegate?.didAuthSuccessfully(authService: self, authResult: result)
            case .some(let error):
                self.delegate?.didReceiveError(authService: self, error: error)
            }
        }
    }
    
    // Обновление пароля пользователя
    func updatePassword(password: String) {
        auth.currentUser?.updatePassword(to: password) { error in
            switch error {
            case .none:
                self.delegate?.changeInfoSuccessfully(authService: self)
            case .some(let error):
                self.delegate?.didReceiveError(authService: self, error: error)
            }
        }
    }
    
    // Обновление имени пользователя
    func updateName(name: String) {
        //Удаление пробелов впереди и сзади текста
        let name = name.trimSpaces()
        
        let changeRequest = auth.currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.commitChanges { error in
            switch error {
            case .none:
                self.delegate?.changeInfoSuccessfully(authService: self)
            case .some(let error):
                self.delegate?.didReceiveError(authService: self, error: error)
            }
        }
    }
    
    // Восстановление пароля
    func resetPassword(_ email: String) {
        //Удаление пробелов впереди и сзади текста
        let email = email.trimSpaces()
        
        auth.sendPasswordReset(withEmail: email) { error in
            switch error {
            case .none:
                self.delegate?.didSendResetPassword(authService: self)
            case .some(let error):
                self.delegate?.didReceiveError(authService: self, error: error)
            }
        }
    }
}
