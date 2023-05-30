//
//  StartingViewController.swift
//  JustChats
//
//  Created by Андрей Абакумов on 10.05.2023.
//

import UIKit

class StartingViewController: UIViewController {
    
    private let logo: UILabel = {
        let text = UILabel()
        text.text = "Just Chat"
        text.textColor = .black
        text.font = .boldSystemFont(ofSize: 60)
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    private let signUpButton = UIButton(
        title: "Регистрация",
        titleColor: .black,
        backgroundColor: .white,
        font: .systemFont(ofSize: 20),
        isShadow: true,
        cornerRadius: 10
    )
    
    private let logInButton = UIButton(
        title: "Вход",
        titleColor: .white,
        backgroundColor: .black,
        font: .systemFont(ofSize: 20),
        isShadow: false,
        cornerRadius: 10
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setConstraints()
    }
    
    private func setupView() {

        navigationController?.navigationBar.tintColor = .black
        
        view.backgroundColor = .white
        
        view.addSubview(logo)
        view.addSubview(signUpButton)
        signUpButton.addTarget(self,
                               action: #selector(signUpButtonTapped),
                               for: .touchUpInside)
        
        view.addSubview(logInButton)
        logInButton.addTarget(self,
                              action: #selector(logInButtonTapped),
                              for: .touchUpInside)
    }
    
    @objc private func signUpButtonTapped() {
        let signUpVC = SignUpViewController()
        present(signUpVC, animated: true)
    }
    
    @objc private func logInButtonTapped() {
        let logInVc = LogInViewController()
        present(logInVc, animated: true)
    }
}

//MARK: - Set Constraints

extension StartingViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 84),
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            signUpButton.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 220),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 44),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -44),
            signUpButton.heightAnchor.constraint(equalToConstant: 44),
            
            logInButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 16),
            logInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 44),
            logInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -44),
            logInButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}

//MARK: - PreviewProvider

import SwiftUI

struct StartingViewControllerProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let viewController = StartingViewController()
        
        func makeUIViewController(context: Context) -> some UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
        }
    }
}
