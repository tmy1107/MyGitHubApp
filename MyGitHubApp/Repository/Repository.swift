//
//  Repository.swift
//  MyGitHubApp
//
//  Created by tangmengyue on 2024/9/12.
//

import Foundation

class Repository: Codable {
    let name: String
    let description: String?
    let htmlUrl: String // 仓库链接
    let stargazersCount: Int // 星标数量

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case htmlUrl = "html_url"
        case stargazersCount = "stargazers_count"
    }
}

struct RepositorySearchResult: Codable {
    let items: [Repository]
}
