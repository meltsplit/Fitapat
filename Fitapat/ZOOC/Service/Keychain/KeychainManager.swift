//
//  KeychainManager.swift
//  ZOOC
//
//  Created by 장석우 on 4/11/24.
//

import Foundation
import Security

enum KeychainKey: String {
    case username
}
struct KeychainManager {
    
    #if DEBUG
        static let serviceName = "Fitapat_DEV"
    #else
        static let serviceName = "Fitapat"
    #endif

    static func saveUsername(_ username: String?) {
        guard let usernameData = username?.data(using: .utf8) else {
            print("Failed to convert username to data.")
            return
        }

        // Keychain query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: KeychainKey.username.rawValue,
            kSecValueData as String: usernameData
        ]

        // Delete any existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            print("Failed to save username to keychain. Status: \(status)")
            return
        }
        print("Username saved to keychain.")
    }
    
    static func readUsername() -> String? {
        // Keychain query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: KeychainKey.username.rawValue,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            print("Failed to read username from keychain. Status: \(status)")
            return nil
        }

        guard let username = String(data: data, encoding: .utf8) else {
            print("Failed to convert data to username.")
            return nil
        }

        print("Username read from keychain.")
        return username
    }

}
