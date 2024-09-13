//
//  UserManager.swift
//  MyGitHubApp
//
//  Created by tangmengyue on 2024/9/12.
//

import Foundation
import Combine
import UIKit

class User: Codable {
    let login: String
    let id: Int
    let avatarUrl: String?
    let name: String?
    
    var token: String?

    enum CodingKeys: String, CodingKey {
        case login
        case id
        case avatarUrl = "avatar_url"
        case name
    }
}

class UserManager {
    static let shared = UserManager()
    
    @Published private(set) var user: User?
    
    private init() {}
    
    func fetchUserInfo(token: String) -> AnyPublisher<User, Error> {
        GitHubAPI.request(urlString: "https://api.github.com/user", token: token)
            .receive(on: DispatchQueue.main)
            .flatMap({ data in
                do {
                    let decoder = JSONDecoder()
                    let user = try decoder.decode(User.self, from: data)
                    user.token = token
                    self.user = user // 存储用户信息
                    return Just.init(user).setFailureType(to: Error.self).eraseToAnyPublisher()
                } catch {
                    print("JSON 解析失败: \(error)")
                    return Fail(error: NSError()).eraseToAnyPublisher()
                }
            })
            .eraseToAnyPublisher()
    }
    
    func logout() {
        user = nil
    }
}
