//
//  ProfileViewController.swift
//  MyGitHubApp
//
//  Created by tangmengyue on 2024/9/12.
//

import UIKit
import SnapKit
import SDWebImage
import Combine

class ProfileViewController: UIViewController {
    private let avatarImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let userIdLabel = UILabel()
    private let logoutButton = UIButton(type: .system)
    
    private lazy var loginHintView = LoginHintView()
    
    private var cancellables = [AnyCancellable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "my".L
        
        setupUI()
        setupLayout()
        bindData()
    }
    
    private func setupUI() {
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 50
        avatarImageView.clipsToBounds = true
        view.addSubview(avatarImageView)

        usernameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        usernameLabel.textAlignment = .center
        view.addSubview(usernameLabel)

        userIdLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        userIdLabel.textAlignment = .center
        userIdLabel.textColor = .gray
        view.addSubview(userIdLabel)
        
        logoutButton.setTitle("logout".L, for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        logoutButton.setTitleColor(.systemRed, for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        view.addSubview(logoutButton)
    }
    
    private func setupLayout() {
        avatarImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        userIdLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }
        logoutButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(88)
            make.centerX.equalToSuperview()
        }
    }
    
    @objc private func logoutButtonTapped() {
        UserManager.shared.logout()
    }
}

private extension ProfileViewController {
    func bindData() {
        updateUserProfile(with: UserManager.shared.user)
        UserManager.shared.$user.sink { [weak self] user in
            self?.updateUserProfile(with: user)
        }.store(in: &cancellables)
    }
    
    func updateUserProfile(with user: User?) {
        if let user = user {
            usernameLabel.text = user.login
            userIdLabel.text = "user".L + "ID: \(user.id)"
            if let avatarUrlString = user.avatarUrl, let avatarUrl = URL(string: avatarUrlString) {
                avatarImageView.sd_setImage(with: avatarUrl, placeholderImage: UIImage(systemName: "person.circle"))
            }
            loginHintView.removeFromSuperview()
            logoutButton.isHidden = false
        } else {
            usernameLabel.text = "not_login".L
            userIdLabel.text = "user".L + "ID: N/A"
            avatarImageView.image = UIImage(systemName: "person.circle")
            view.addSubview(loginHintView)
            loginHintView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
            logoutButton.isHidden = true
        }
    }
}
