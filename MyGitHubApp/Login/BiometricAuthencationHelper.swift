//
//  BiometricAuthencationHelper.swift
//  MyGitHubApp
//
//  Created by tangmengyue on 2024/9/12.
//

import LocalAuthentication
import Combine
import KeychainSwift
import UIKit

class BiometricAuthencationHelper {
    private static let keychainKey = "GitHubToken4"
    
    private static let keychain = KeychainSwift()
    
    static func bind(token: String) {
        var error: NSError?
        let context = LAContext()
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // 不支持生物认证
            return
        }
        
        guard keychain.get(keychainKey) != token else {
            return
        }
        
        let alertController = UIAlertController(title: "bind_biometric".L, message: "bind_biometric_hint".L, preferredStyle: .alert)
        let bindAction = UIAlertAction(title: "bind".L, style: .default) { _ in
            authentication(context: context, reason: "bind_biometric_reason".L) { success in
                if success {
                    // 绑定成功，保存标记以供下次登录使用
                    keychain.set(token, forKey: keychainKey)
                }
            }
        }

        let skipAction = UIAlertAction(title: "pass".L, style: .cancel) { _ in
            print("用户选择跳过绑定生物认证")
        }

        alertController.addAction(bindAction)
        alertController.addAction(skipAction)

        UIViewController.topViewController?.present(alertController, animated: true, completion: nil)
    }
    
    static func getLoginToken(completion: ((String?) -> Void)?) {
        var error: NSError?
        let context = LAContext()
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            UIViewController.showErrorTips("biometric_not_support".L)
            completion?(nil)
            return
        }
        guard let token = keychain.get(keychainKey) else {
            UIViewController.showErrorTips("token_login".L)
            completion?(nil)
            return
        }
        authentication(context: context, reason: "use_biometric_login".L) { success in
            if success {
                completion?(token)
            } else {
                completion?(nil)
            }
        }
    }
    
    private static func authentication(context: LAContext, reason: String, completion: ((Bool) -> Void)?) {
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
            DispatchQueue.main.async {
                if success {
                    print("生物认证成功")
                    completion?(true)
                } else {
                    print("生物认证失败: \(String(describing: authenticationError?.localizedDescription))")
                    completion?(false)
                }
            }
        }
    }
}
