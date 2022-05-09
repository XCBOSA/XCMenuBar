//
//  MenuBarItemProvider.swift
//  Code Develop
//
//  Created by xcbosa on 2022/3/26.
//

import UIKit

public protocol MenuBarItemProvider: UIViewController {
    func provideMenuBarItems() -> [MenuBarMenu]
    func provideExtraMenuBarItems() -> [MenuBarMenu]
    func provideExtraExtraMenuBarItems() -> [MenuBarMenu]
    func provideRightItem() -> [MenuBarRightItem]
}

extension MenuBarItemProvider {
    
    func provideExtraMenuBarItems() -> [MenuBarMenu] { [] }
    
    func provideExtraExtraMenuBarItems() -> [MenuBarMenu] { [] }
    
    func provideRightItem() -> [MenuBarRightItem] { [] }
    
    internal func provideAllMenuBarItems() -> [MenuBarMenu] {
        var items = [MenuBarMenu]()
        items.append(contentsOf: self.provideMenuBarItems())
        items.append(contentsOf: self.provideExtraMenuBarItems())
        items.append(contentsOf: self.provideExtraExtraMenuBarItems())
        return items
    }
    
}
