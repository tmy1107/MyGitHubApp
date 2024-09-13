//
//  RepositoryListView.swift
//  MyGitHubApp
//
//  Created by tangmengyue on 2024/9/12.
//

import Foundation
import UIKit
import Combine

class RepositoryTableView: UITableView {
    private var cancellables = [AnyCancellable]()
    
    init(viewModel: RepositoryViewModel) {
        super.init(frame: .zero, style: UITableView.Style.plain)
        
        delegate = viewModel
        dataSource = viewModel
        
        viewModel.$repositories.receive(on: DispatchQueue.main).sink { [weak self] user in
            self?.reloadData()
        }.store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
