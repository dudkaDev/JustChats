//
//  PasswordDescriptionViewController.swift
//  JustChats
//
//  Created by Андрей Абакумов on 12.05.2023.
//

import UIKit

class PasswordDescriptionViewController: UIViewController {

    private let passwordDescription: UILabel = {
        let label = UILabel()
        label.text =
        """
        - одна заглавная буква
        - одна цифра
        - одна строчная буква
        - один символ
        - длина не менее 8 символов
        """
        label.textColor = . black
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setConstraints()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(passwordDescription)
    }

    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            passwordDescription.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            passwordDescription.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4)
        ])
    }
}
