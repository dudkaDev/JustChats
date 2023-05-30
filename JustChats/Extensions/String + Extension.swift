//
//  String + Extension.swift
//  JustChats
//
//  Created by Андрей Абакумов on 22.05.2023.
//

import UIKit

extension String {
    
    func trimSpaces() -> String {
        let trimmedString = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedString
    }
    
    func isValidEmail() -> Bool {
        let firstPart = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
        let serverPart = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
        let emailRegex = firstPart + "@" + serverPart + "[A-Za-z]{2,8}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        return emailPredicate.evaluate(with: self)
    }
    
    func isValidPassword() -> Bool {
//          - одна заглавная буква
//          - одна цифра
//          - одна строчная буква
//          - один символ
//          - длина не менее 8 символов
            let passwordRegex = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&<>*~:`-]).{8,}$"
            let passwordCheck = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
            return passwordCheck.evaluate(with: self)
        }
}
