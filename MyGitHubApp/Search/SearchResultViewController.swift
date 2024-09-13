//
//  SearchResultViewController.swift
//  MyGitHubApp
//
//  Created by tangmengyue on 2024/9/12.
//

import Foundation
import UIKit
import Combine

class SearchResultViewController: UIViewController {
    private let viewModel = RepositoryViewModel()
    private lazy var tableView = RepositoryTableView(viewModel: viewModel)
    private lazy var errorView = CommonErrorView { [weak self] in
        guard let self else { return }
        self.searchRepositories(keyword: self.searchKeyword)
    }
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    let searchKeyword: String
    
    private var cancellables = [AnyCancellable]()
    
    init(searchKeyword: String) {
        self.searchKeyword = searchKeyword
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "search_result".L + ": \(searchKeyword)"

        setupTableView()
        
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        searchRepositories(keyword: searchKeyword)
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    // 搜索 GitHub 仓库
    private func searchRepositories(keyword: String) {
        errorView.removeFromSuperview()
        activityIndicator.startAnimating()
        GitHubAPI.request(urlString: "https://api.github.com/search/repositories?q=\(keyword)", token: UserManager.shared.user?.token)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.activityIndicator.stopAnimating()
                switch completion {
                case .failure(_):
                    self.view.addSubview(self.errorView)
                    self.errorView.snp.remakeConstraints { make in
                        make.edges.equalTo(self.tableView)
                    }
                default:
                    break
                }
            } receiveValue: { data in
                do {
                    let searchResult = try JSONDecoder().decode(RepositorySearchResult.self, from: data)
                    DispatchQueue.main.async {
                        self.viewModel.repositories = searchResult.items
                    }
                } catch {
                    print("Failed to decode search results: \(error.localizedDescription)")
                }
            }.store(in: &cancellables)
    }
}

