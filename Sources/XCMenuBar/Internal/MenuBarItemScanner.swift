//
//  MenuBarItemScanner.swift
//  Code Develop
//
//  Created by xcbosa on 2022/3/26.
//

import UIKit

internal class MenuBarItemScanner {
    
    internal class func getChildViewControllers(fromRootViewController rvc: UIViewController) -> [UIViewController] {
        var viewControllers = [UIViewController]()
        viewControllers.append(rvc)
        if let rvc = rvc as? MenuBarScanPolicy {
            for it in rvc.menuBarScannerGetChildControllers() {
                viewControllers.append(contentsOf: getChildViewControllers(fromRootViewController: it))
            }
        }
        return viewControllers
    }
    
    internal class func getMenus(fromRootViewController rvc: UIViewController) -> [MenuBarMenu] {
        let vcs = getChildViewControllers(fromRootViewController: rvc)
        var menus = [MenuBarMenu]()
        for it in vcs {
            if let it = it as? MenuBarItemProvider {
                for menu in it.provideAllMenuBarItems().filter({ $0.isVisible }) {
                    if let elem = menus.first(where: { $0.text == menu.text }) {
                        elem.append(menuItems: menu.items)
                    } else {
                        menus.append(menu)
                    }
                }
            }
        }
        _ = menus.map({ $0.expandSubItems() })
        return menus
    }
    
    internal class func getRightItem(fromRootViewController rvc: UIViewController) -> [MenuBarRightItem] {
        let vcs = getChildViewControllers(fromRootViewController: rvc)
        var items = [MenuBarRightItem]()
        for it in vcs {
            if let it = it as? MenuBarItemProvider {
                let item = it.provideRightItem().filter({ $0.isEnabled })
                items.append(contentsOf: item)
            }
        }
        return items.sorted(by: { $0.priority >= $1.priority })
    }
    
}
