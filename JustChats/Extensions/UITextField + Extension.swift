//
//  UITextField + Extension.swift
//  JustChats
//
//  Created by Андрей Абакумов on 10.05.2023.
//

import UIKit

extension UITextField {
    
    convenience init(placeHolder: String) {
        self.init()
        
        self.placeholder = placeHolder
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 4)
        
        borderStyle = .roundedRect
        clearButtonMode = .always
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    convenience init(passwordPlaceHolder: String) {
        self.init()
        
        self.placeholder = passwordPlaceHolder
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 4)
        
        textContentType = .oneTimeCode
        isSecureTextEntry = true
        
        borderStyle = .roundedRect
        clearButtonMode = .always
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    convenience init(emailPlaceHolder: String) {
        self.init()
        
        self.placeholder = emailPlaceHolder
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 4)
        
        autocapitalizationType = .none
        textContentType = .emailAddress
        keyboardType = .emailAddress
        
        borderStyle = .roundedRect
        clearButtonMode = .always
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func showPasswordButton() {
        let button = UIButton(type: .custom)
        let image = UIImage(systemName: "eye.fill")
        button.tintColor = .black
        button.setImage(image, for: .normal)
        button.contentMode = .center
        button.sizeToFit()
        
        self.rightView = UIView(frame: CGRect(x: self.frame.size.width - 24, y: 0, width: button.frame.width + 8, height: button.frame.height))
        self.rightView?.addSubview(button)
        self.rightViewMode = .always
        
        button.addTarget(self, action: #selector(self.togglePasswordSecure), for: .touchUpInside)
    }
    
    @objc func togglePasswordSecure(_ sender: UIButton) {
        self.isSecureTextEntry.toggle()
        var image: UIImage?
        if self.isSecureTextEntry {
            image = UIImage(systemName: "eye.fill")
        } else {
            image = UIImage(systemName: "eye.slash.fill")
        }
        
        sender.setImage(image, for: .normal)
    }
    
    func becomeGreen() {
        UIView.animate(withDuration: 0.25, delay: 0) {
            self.layer.shadowColor = UIColor.systemGreen.cgColor
            self.layer.shadowOpacity = 0.5
        }
    }
    
    func becomeRed() {
        UIView.animate(withDuration: 0.25, delay: 0) {
            self.layer.shadowColor = UIColor.systemRed.cgColor
            self.layer.shadowOpacity = 0.5
        }
    }
    
    func resetShadow() {
        UIView.animate(withDuration: 0.25, delay: 0) {
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOpacity = 0.2
        }
    }
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.25
        animation.values = [0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
        
        becomeRed()
    }
}
