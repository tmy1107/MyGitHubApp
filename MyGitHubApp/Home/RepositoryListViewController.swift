//
//  RepositoryListViewController.swift
//  MyGitHubApp
//
//  Created by tangmengyue on 2024/9/11.
//

import UIKit
import SnapKit
import Foundation
import Combine

class RepositoryListViewController: UIViewController {
    private let viewModel = RepositoryViewModel()
    private lazy var tableView = RepositoryTableView(viewModel: viewModel)
    
    private lazy var loginHintView = LoginHintView()
    private lazy var errorView = CommonErrorView { [weak self] in
        if let user = UserManager.shared.user {
            self?.fetchRepositories(with: user)
        }
    }
    
    private let searchBarView = UIView()
    private let searchTextField = UITextField()
    private let searchButton = UIButton()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private var cancellables = [AnyCancellable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "repository".L

        setupTableView()
        setupSearchBar()
        
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        setupLayout()
        
        bindData()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupSearchBar() {
        view.addSubview(searchBarView)
        
        searchTextField.placeholder = "search_repository".L
        searchTextField.borderStyle = .roundedRect
        searchBarView.addSubview(searchTextField)
        
        searchButton.setTitle("search".L, for: .normal)
        searchButton.backgroundColor = .systemBlue
        searchButton.layer.cornerRadius = 5
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        searchBarView.addSubview(searchButton)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        headerView.backgroundColor = .systemBackground
        let headerLabel = UILabel(frame: CGRect(x: 16, y: 0, width: view.frame.width - 32, height: 50))
        headerLabel.text = "personal_repository".L
        headerLabel.font = UIFont.boldSystemFont(ofSize: 24)
        headerLabel.textAlignment = .left // 左对齐
        headerView.addSubview(headerLabel)
        tableView.tableHeaderView = headerView
    }
    
    private func setupLayout() {
        searchBarView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(40)
        }
        searchButton.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(16)
        }
        searchTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.right.equalTo(searchButton.snp.left).offset(-16)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBarView.snp.bottom).offset(10)
            make.left.bottom.right.equalTo(view.safeAreaLayoutGuide)
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func bindData() {
        UserManager.shared.$user
            .sink { [weak self] user in
            guard let self else { return }
            if let user {
                self.loginHintView.removeFromSuperview()
                self.fetchRepositories(with: user)
            } else {
                view.insertSubview(self.loginHintView, belowSubview: self.searchBarView)
                self.loginHintView.snp.remakeConstraints { make in
                    make.edges.equalToSuperview()
                }
                self.viewModel.repositories.removeAll()
            }
        }.store(in: &cancellables)
    }
    
    @objc private func searchButtonTapped() {
        guard let keyword = searchTextField.text, !keyword.isEmpty else {
            return
        }

        let searchVC = SearchResultViewController(searchKeyword: keyword)
        navigationController?.pushViewController(searchVC, animated: true)
        searchTextField.text = ""
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}

extension RepositoryListViewController {
    func fetchRepositories(with user: User) {
        errorView.removeFromSuperview()
        activityIndicator.startAnimating()
        GitHubAPI.request(urlString: "https://api.github.com/user/repos", token: user.token)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.activityIndicator.stopAnimating()
                switch completion {
                case .failure(_):
                    self.view.insertSubview(self.errorView, belowSubview: self.searchBarView)
                    self.errorView.snp.remakeConstraints { make in
                        make.edges.equalToSuperview()
                    }
                    break
                default:
                    break
                }
            } receiveValue: { [weak self] data in
                do {
                    let repositories = try JSONDecoder().decode([Repository].self, from: data)
                    DispatchQueue.main.async {
                        self?.viewModel.repositories = repositories
                    }
                } catch {
                    print("Failed to decode repositories: \(error.localizedDescription)")
                }
            }.store(in: &cancellables)
    }
}
