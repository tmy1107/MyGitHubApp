//
//  LoginViewController.swift
//  MyGitHubApp
//
//  Created by tangmengyue on 2024/9/11.
//

import UIKit
import LocalAuthentication
import Combine

class LoginViewController: UIViewController {
    private let instructionLabel = UILabel()
    private let tokenTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let biometricLoginButton = UIButton(type: .system)
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private var cancellables = [AnyCancellable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupLayout()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupUI() {
        instructionLabel.text = "input_token".L
        instructionLabel.textAlignment = .center
        instructionLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(instructionLabel)
        
        tokenTextField.borderStyle = .roundedRect
        view.addSubview(tokenTextField)
        
        loginButton.setTitle("login".L, for: .normal)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        view.addSubview(loginButton)
        
        biometricLoginButton.setTitle("biometric_login".L, for: .normal)
        biometricLoginButton.addTarget(self, action: #selector(biometricLoginButtonTapped), for: .touchUpInside)
        view.addSubview(biometricLoginButton)
        
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    private func setupLayout() {
        instructionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-120)
            make.left.right.equalToSuperview().inset(40)
        }
        tokenTextField.snp.makeConstraints { make in
            make.top.equalTo(instructionLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(40)
        }
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(tokenTextField.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        biometricLoginButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    @objc func dismissKeyboard() {
        // 关闭键盘
        view.endEditing(true)
    }
    
    @objc private func loginButtonTapped() {
        guard let token = tokenTextField.text, !token.isEmpty else {
            UIViewController.showErrorTips("token_not_empty".L)
            return
        }
        login(with: token)
    }
    
    @objc private func biometricLoginButtonTapped() {
        BiometricAuthencationHelper.getLoginToken { [weak self] token in
            if let token {
                self?.login(with: token)
            }
        }
    }
    
    private func login(with token: String) {
        activityIndicator.startAnimating()
        UserManager.shared.fetchUserInfo(token: token)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.activityIndicator.stopAnimating()
                switch completion {
                case .finished:
                    print("登录成功")
                    self?.dismiss(animated: true)
                    BiometricAuthencationHelper.bind(token: token)
                case .failure(let error):
                    print("登录失败")
                    if (error as NSError).code == 401 {
                        // Access token 无效
                        UIViewController.showErrorTips("invalid_token".L)
                    } else {
                        UIViewController.showErrorTips("login_error")
                    }
                }
            } receiveValue: { _ in
                
            }.store(in: &cancellables)
    }
}

