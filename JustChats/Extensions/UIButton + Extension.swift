//
//  UIButton + Extension.swift
//  JustChats
//
//  Created by Андрей Абакумов on 10.05.2023.
//

import UIKit

extension UIButton {
    
    convenience init(title: String,
                     titleColor: UIColor,
                     backgroundColor: UIColor,
                     font: UIFont?,
                     isShadow: Bool,
                     cornerRadius: CGFloat) {
        self.init(type: .system)
        
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.backgroundColor = backgroundColor
        self.titleLabel?.font = font
        self.layer.cornerRadius = cornerRadius
        
        if isShadow {
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowRadius = 4
            self.layer.shadowOpacity = 0.2
            self.layer.shadowOffset = CGSize(width: 0, height: 4)
        }
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    convenience init(image: UIImage, tintColor: UIColor) {
        self.init(type: .system)
        
        self.setImage(image, for: .normal)
        self.tintColor = tintColor
        
        translatesAutoresizingMaskIntoConstraints = false
    }
}
