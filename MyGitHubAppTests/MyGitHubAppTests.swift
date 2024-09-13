//
//  MyGitHubAppTests.swift
//  MyGitHubAppTests
//
//  Created by tangmengyue on 2024/9/11.
//

import XCTest
@testable import MyGitHubApp

final class MyGitHubAppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLogin() throws {
        let token = ""
        let expectation = self.expectation(description: "")
        let cancels = UserManager.shared.fetchUserInfo(token: token).sink { completion in
            switch completion {
            case .failure(let error):
                XCTFail()
            default:
                break
            }
        } receiveValue: { value in
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
}
