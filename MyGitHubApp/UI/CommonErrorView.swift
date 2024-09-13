//
//  CommonErrorView.swift
//  MyGitHubApp
//
//  Created by tangmengyue on 2024/9/13.
//

import Foundation
import UIKit

class CommonErrorView: UIView {
    private let hintLabel = UILabel()
    private(set) lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("retry".L, for: .normal)
        button.addTarget(self, action: #selector(retryButtonClicked), for: .touchUpInside)
        return button
    }()
    private let retryBlock: (()->Void)
    
    init(retryBlock: @escaping (()->Void)) {
        self.retryBlock = retryBlock
        super.init(frame: .zero)
        
        backgroundColor = .clear
        
        hintLabel.text = "network_retry".L
        hintLabel.textAlignment = .center
        hintLabel.font = UIFont.systemFont(ofSize: 16)
        addSubview(hintLabel)
        addSubview(retryButton)
        
        hintLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        retryButton.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func retryButtonClicked() {
        retryBlock()
    }
}
