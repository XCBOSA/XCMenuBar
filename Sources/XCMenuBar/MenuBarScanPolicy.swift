//
//  MenuBarScanPolicy.swift
//  Code Develop
//
//  Created by xcbosa on 2022/3/26.
//

import UIKit

public protocol MenuBarScanPolicy {
    func menuBarScannerGetChildControllers() -> [UIViewController]
}

extension UISplitViewController: MenuBarScanPolicy {
    public func menuBarScannerGetChildControllers() -> [UIViewController] {
        return self.viewControllers
    }
}

extension UINavigationController: MenuBarScanPolicy {
    public func menuBarScannerGetChildControllers() -> [UIViewController] {
        return self.topViewController != nil ? [self.topViewController!] : []
    }
}
