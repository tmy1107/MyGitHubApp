//
//  GitHubAPI.swift
//  MyGitHubApp
//
//  Created by tangmengyue on 2024/9/11.
//

import Foundation
import Combine
import UIKit

class GitHubAPI {
    static func request(urlString: String, httpMethod: String = "GET", token: String? = nil) -> AnyPublisher<Data, Error> {
        guard let url = URL.encodedURL(string: urlString) else {
            print("无效的URL")
            return Fail(error: NSError()).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        if let token = token, !token.isEmpty {
            request.addValue("token \(token)", forHTTPHeaderField: "Authorization")
        }
        return Future<Data, Error> { promise in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("网络错误: \(String(describing: error.localizedDescription))")
                    promise(.failure(error))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        // Access token 是有效的，解析用户数据
                        if let data = data {
                            promise(.success(data))
                            return
                        }
                    } else {
                        // 其他错误
                        print("服务器错误，状态码: \(httpResponse.statusCode)")
                        promise(.failure(NSError(domain: "GitHubAPI", code: httpResponse.statusCode)))
                        return
                    }
                }
                
                print("未知错误")
                promise(.failure(NSError(domain: "GitHubAPI", code: -1)))
            }
            
            task.resume()
        }.eraseToAnyPublisher()
    }
}

extension URL {
    public static func encodedURL(string: String) -> URL? {
        var url = self.init(string: string)
        if url == nil {
            if let encodedString = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                url = URL(string: encodedString)
            }
        }
        
        return url
    }
}
