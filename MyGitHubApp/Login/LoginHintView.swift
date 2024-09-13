//
//  LoginHintView.swift
//  MyGitHubApp
//
//  Created by tangmengyue on 2024/9/12.
//

import UIKit

class LoginHintView: UIView {
    private let hintLabel = UILabel()
    private(set) lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("login".L, for: .normal)
        button.addTarget(self, action: #selector(loginButtonClicked), for: .touchUpInside)
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .clear
        
        hintLabel.text = "login_hint".L
        hintLabel.textAlignment = .center
        hintLabel.font = UIFont.systemFont(ofSize: 16)
        addSubview(hintLabel)
        addSubview(loginButton)
        
        hintLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func loginButtonClicked() {
        let loginVC = LoginViewController()
        let loginVCNav = UINavigationController(rootViewController: loginVC)
        UIViewController.topViewController?.present(loginVCNav, animated: true)
    }
}
