//
//  WaitingView.swift
//  JustChats
//
//  Created by Андрей Абакумов on 23.05.2023.
//

import UIKit

class WaitingView: UIView {
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func isWaiting(_ status: Bool) {
        var alpha: CGFloat = 0
        
        if status {
            alpha = 0.5
        } else {
            alpha = 0
        }
        UIView.animate(withDuration: 0.25) {
            self.alpha = alpha
        }
    }
    
    private func configure() {
        backgroundColor = .white
        alpha = 0.5
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(spinner)
        spinner.startAnimating()
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
