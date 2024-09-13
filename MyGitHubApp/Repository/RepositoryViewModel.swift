//
//  RepositoryViewModel.swift
//  MyGitHubApp
//
//  Created by tangmengyue on 2024/9/12.
//

import Foundation
import Combine
import UIKit

class RepositoryViewModel: NSObject {
    @Published var repositories: [Repository] = []
}

extension RepositoryViewModel: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryCell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "RepositoryCell")
        }
        guard let cell = cell else {
            return UITableViewCell()
        }
        
        let repository = repositories[indexPath.row]
        cell.textLabel?.text = repository.name
        cell.detailTextLabel?.text = "⭐️ \(repository.stargazersCount)"
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repository = repositories[indexPath.row]
        if let url = URL(string: repository.htmlUrl) {
            UIApplication.shared.open(url)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
