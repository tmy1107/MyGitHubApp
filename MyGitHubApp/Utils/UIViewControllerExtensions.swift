//
//  UIViewControllerExtensions.swift
//  MyGitHubApp
//
//  Created by tangmengyue on 2024/9/12.
//

import Foundation
import UIKit

extension UIViewController {
    static var topViewController: UIViewController? {
        var _window: UIWindow? = UIApplication.shared.delegate?.window ?? nil
        if _window?.isKind(of: UIView.self) != true {
            _window = UIApplication.shared.keyWindow
        }
        let _topView = _window?.subviews.last
        guard let topVc = topViewController(forResponder: _topView) else {
            return nil
        }
        if let navVc = topVc as? UINavigationController {
            return navVc.topViewController
        }
        return topVc
    }
    
    static func topViewController(forResponder responder: UIResponder?) -> UIViewController? {
        var _responder = responder
        while _responder != nil {
            if let vc = _responder as? UIViewController {
                var _viewController: UIViewController? = vc
                while (_viewController?.parent != nil &&
                    _viewController?.parent != _viewController?.navigationController &&
                    _viewController?.parent != _viewController?.tabBarController) {
                        _viewController = _viewController?.parent
                }
                return _viewController
            }
            _responder = _responder?.next
        }
        
        if _responder == nil, let _window = UIApplication.shared.delegate?.window, let rootVc = _window?.rootViewController {
            _responder = rootVc
        }

        var viewController = _responder as? UIViewController
        while viewController?.presentedViewController != nil, viewController?.presentedViewController?.isBeingDismissed != true {
            viewController = viewController?.presentedViewController
        }
        return viewController
    }
}

extension UIViewController {
    static func showErrorTips(_ title: String) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "confirm".L, style: .default, handler: nil)
        alertController.addAction(okAction)

        // 弹出提示框
        topViewController?.present(alertController, animated: true, completion: nil)
    }
}
