//
//  Validation.swift
//  Pluckr
//
//  Created by Susan Bailey on 7/14/25.
//

import Foundation
import SwiftUI

struct Validation {
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func isValidPhone(_ phone: String) -> Bool {
        // Remove all non-digit characters for validation
        let digitsOnly = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        let phoneRegEx = "^\\d{10,15}$" // Accepts 10-15 digits
        let phonePred = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: digitsOnly)
    }
    
    // MARK: - Phone Number Formatting
    
    /// Formats a phone number string with parentheses and dashes
    /// Input: "1234567890" -> Output: "(123) 456-7890"
    static func formatPhoneNumber(_ phone: String) -> String {
        // Remove all non-digit characters
        let digitsOnly = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        // Don't format if less than 7 digits
        if digitsOnly.count < 7 {
            return phone
        }
        
        // Format based on length
        switch digitsOnly.count {
        case 7:
            // Format as XXX-XXXX
            let areaCode = String(digitsOnly.prefix(3))
            let number = String(digitsOnly.suffix(4))
            return "\(areaCode)-\(number)"
            
        case 10:
            // Format as (XXX) XXX-XXXX
            let areaCode = String(digitsOnly.prefix(3))
            let prefix = String(digitsOnly.dropFirst(3).prefix(3))
            let number = String(digitsOnly.suffix(4))
            return "(\(areaCode)) \(prefix)-\(number)"
            
        case 11:
            // Format as +X (XXX) XXX-XXXX (assuming first digit is country code)
            let countryCode = String(digitsOnly.prefix(1))
            let areaCode = String(digitsOnly.dropFirst(1).prefix(3))
            let prefix = String(digitsOnly.dropFirst(4).prefix(3))
            let number = String(digitsOnly.suffix(4))
            return "+\(countryCode) (\(areaCode)) \(prefix)-\(number)"
            
        default:
            // For other lengths, just add dashes every 3-4 digits
            var formatted = ""
            var index = 0
            
            for digit in digitsOnly {
                if index == 3 && digitsOnly.count >= 7 {
                    formatted += "-"
                } else if index == 6 && digitsOnly.count >= 10 {
                    formatted += "-"
                } else if index == 10 && digitsOnly.count >= 11 {
                    formatted += "-"
                }
                formatted += String(digit)
                index += 1
            }
            
            return formatted
        }
    }
    
    /// Removes all formatting from a phone number, returning only digits
    static func unformatPhoneNumber(_ phone: String) -> String {
        return phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
    }
    
    /// Formats phone number as user types, maintaining cursor position
    static func formatPhoneNumberAsTyped(_ phone: String) -> String {
        // If the user is in the middle of typing, don't format yet
        let digitsOnly = unformatPhoneNumber(phone)
        
        // Only format if we have enough digits
        if digitsOnly.count >= 7 {
            return formatPhoneNumber(phone)
        }
        
        // For partial numbers, just return as is
        return phone
    }
}

// MARK: - Phone Number TextField Modifier

struct PhoneNumberTextFieldModifier: ViewModifier {
    @Binding var text: String
    
    func body(content: Content) -> some View {
        content
            .onChange(of: text) { newValue in
                // Only format if the user is typing (not programmatically setting)
                let digitsOnly = Validation.unformatPhoneNumber(newValue)
                
                // Don't format if less than 7 digits to avoid premature formatting
                if digitsOnly.count >= 7 {
                    let formatted = Validation.formatPhoneNumber(newValue)
                    if formatted != newValue {
                        text = formatted
                    }
                }
            }
    }
}

extension View {
    /// Applies phone number formatting to a TextField
    func phoneNumberFormatting(text: Binding<String>) -> some View {
        self.modifier(PhoneNumberTextFieldModifier(text: text))
    }
}

