//
//  Validation.swift
//  Pluckr
//
//  Created by Susan Bailey on 7/14/25.
//

import Foundation

struct Validation {
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    static func isValidPhone(_ phone: String) -> Bool {
        let phoneRegEx = "^\\d{10,15}$" // Accepts 10-15 digits
        let phonePred = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: phone)
    }
}

