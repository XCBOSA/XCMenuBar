//
//  MenuBarItem.swift
//  Code Develop
//
//  Created by xcbosa on 2022/3/26.
//

import UIKit

public class MenuBarMenu {
    
    public var text: String?
    public var image: UIImage?
    public var items = [MenuBarMenuItem]()
    public var isVisible: Bool = true
    
    /// 构造菜单主项
    /// - Parameters:
    ///   - text: 文本
    ///   - items: 子项
    public init(withText text: String?, items: [MenuBarMenuItem] = []) {
        self.text = text
        self.items = items
    }
    
    /// 构造菜单主项
    /// - Parameters:
    ///   - text: 文本
    ///   - image: 图片
    ///   - items: 子项
    public init(withText text: String?, andImage image: UIImage?, items: [MenuBarMenuItem] = []) {
        self.text = text
        self.image = image
        self.items = items
    }
    
    /// 构造菜单主项，只能有一个仅包含图片的菜单主项，因为会通过比较菜单主项的文本合并主项，所有没有文本的菜单主项都将被合并
    /// - Parameters:
    ///   - image: 图片
    ///   - items: 子项
    public init(withImage image: UIImage?, items: [MenuBarMenuItem] = []) {
        self.image = image
        self.items = items
    }
    
    public func append(menuItem: MenuBarMenuItem) {
        self.items.append(menuItem)
    }
    
    public func append(menuItems: [MenuBarMenuItem]) {
        self.items.append(contentsOf: menuItems)
    }
    
    // MARK: - Develop Feature Zone
    internal func expandSubItems() {
        let copied = items
        items.removeAll()
        for it in copied {
            items.append(contentsOf: it.listItems())
        }
    }
    
    public func visibleIf(_ bool: Bool) -> Self {
        self.isVisible = bool
        return self
    }
    
    public func visibleIf(closureReturnBool closure: () -> Bool) -> Self {
        self.isVisible = closure()
        return self
    }
    
    public func visibleIf(closureWithSelf closure: (Self) -> Bool) -> Self {
        self.isVisible = closure(self)
        return self
    }
    
}

public enum MenuBarMenuItemActionSource {
    case clickMenu
    case keyboard
}

public class MenuBarMenuItem {
    
    public var text: String?
    public var keyInput: String?
    public var isEnabled: Bool = true
    public var hasSeparatorLine: Bool = false
    public internal(set) var actionSource: MenuBarMenuItemActionSource = .clickMenu
    public var action: (() -> Void)?
    
    /// 构造菜单子项
    /// - Parameters:
    ///   - text: 菜单文本
    ///   - action: 点击执行的代码块
    public init(withText text: String?, andAction action: (() -> Void)? = nil) {
        self.text = text
        self.action = action
    }
    
    /// 构造菜单子项
    /// - Parameters:
    ///   - text: 菜单文本
    ///   - bindKey: 快捷键表达式
    ///   - action: 点击执行的代码块
    public init(withText text: String?, bindKey: String?, andAction action: (() -> Void)? = nil) {
        self.text = text
        self.keyInput = bindKey
        self.action = action
    }
    
    public convenience init(withTextAsset asset: String, andAction action: (() -> Void)? = nil) {
        self.init(withText: NSLocalizedString(asset, comment: ""), andAction: action)
    }
    
    public convenience init(withTextAsset asset: String, bindKey: String?, andAction action: (() -> Void)? = nil) {
        self.init(withText: NSLocalizedString(asset, comment: ""), bindKey: bindKey, andAction: action)
    }
    
    /// 菜单子项可用条件
    /// - Parameter bool: 菜单子项是否可用
    /// - Returns: 自身
    public func enableIf(_ bool: Bool) -> Self {
        self.isEnabled = bool
        return self
    }
    
    /// 菜单子项可用条件
    /// - Parameter closure: 返回菜单子项是否可用的表达式
    /// - Returns: 自身
    public func enableIf(closureReturnBool closure: () -> Bool) -> Self {
        self.isEnabled = closure()
        return self
    }
    
    public func enableIf(closureWithSelf closure: (Self) -> Bool) -> Self {
        self.isEnabled = closure(self)
        return self
    }
    
    /// 为此菜单子项底部添加分割线
    /// - Returns: 自身
    public func andSeparatorLine() -> MenuBarMenuItem {
        self.hasSeparatorLine = true
        return self
    }
    
    public func andAction(_ action: @escaping (MenuBarMenuItem) -> Void) -> MenuBarMenuItem {
        self.action = {
            action(self)
        }
        return self
    }
    
    // MARK: - Develop Feature Zone
    internal var arrayItems: [MenuBarMenuItem]?
    internal func listItems() -> [MenuBarMenuItem] {
        if let arrayItems = arrayItems {
            return arrayItems
        } else {
            return [self]
        }
    }
    
}

public class MenuBarRightItem {
    
    public var image: UIImage?
    public var isEnabled: Bool = true
    public var action: (() -> Void)?
    public var priority: Int = 0
    
    public init(withImage image: UIImage?, andAction action: (() -> Void)? = nil) {
        self.image = image
        self.action = action
    }
    
    /// 菜单子项可用条件
    /// - Parameter bool: 菜单子项是否可用
    /// - Returns: 自身
    public func enableIf(_ bool: Bool) -> Self {
        self.isEnabled = bool
        return self
    }
    
    /// 菜单子项可用条件
    /// - Parameter closure: 返回菜单子项是否可用的表达式
    /// - Returns: 自身
    public func enableIf(closureReturnBool closure: () -> Bool) -> Self {
        self.isEnabled = closure()
        return self
    }
    
    public func enableIf(closureWithSelf closure: (Self) -> Bool) -> Self {
        self.isEnabled = closure(self)
        return self
    }
    
    public func with(priority: Int) -> Self {
        self.priority = priority
        return self
    }
    
}

