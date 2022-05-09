//
//  MenuBarSubMenu.swift
//  Code Develop
//
//  Created by xcbosa on 2022/3/27.
//

import UIKit
import FastLayout

internal class MenuBarSubMenuView: UIVisualEffectView {
    
    internal init(effect: UIVisualEffect?, showingMenu: MenuBarMenu) {
        self.showingMenu = showingMenu
        super.init(effect: effect)
        self.configureSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal var showingMenu: MenuBarMenu!
    
    internal weak var delegate: MenuBarSubMenuViewDelegate?
    
    internal func calculateSize() -> CGSize {
        let sizes = showingMenu.items.map({ MenuBarSubMenuCell.calculateSize(forMenuItem: $0) })
        var width: CGFloat = 0
        var height: CGFloat = 0
        for it in sizes {
            width = max(width, it.width)
            height += it.height
        }
        if sizes.count > 1 {
            height += (CGFloat(sizes.count - 1) * CGFloat(0.5))
        }
        height += 1
        return CGSize(width: width, height: height)
    }
    
    internal var isScrollEnabled: Bool {
        get { tableView.isScrollEnabled }
        set { tableView.isScrollEnabled = newValue }
    }
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.dataSource = self
        view.delegate = self
        view.backgroundColor = .clear
        view.layoutMargins = .zero
        view.separatorColor = UIColorGrayScale(diff: 0.4, alpha: 1)
        view.register(MenuBarSubMenuCell.self, forCellReuseIdentifier: "MenuBarSubMenuCell")
        return view
    }()
    
    private func configureSubview() {
        self.contentView.backgroundColor = UIColorGrayScale(diff: 1, alpha: 0.1)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 7
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor(dynamicProvider: {
            $0.userInterfaceStyle == .dark ?
                UIColorGrayScale(diff: 0.3, alpha: 1) : UIColorGrayScale(diff: 0.2, alpha: 1)
        }).cgColor
        
        self.contentView.addSubview(tableView)
        tableView.left == self.contentView.leftAnchor
        tableView.right == self.contentView.rightAnchor
        tableView.top == self.contentView.topAnchor
        tableView.bottom == self.contentView.bottomAnchor
        
        self.contentView.isUserInteractionEnabled = true
    }
    
}

extension MenuBarSubMenuView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showingMenu.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuBarSubMenuCell", for: indexPath) as? MenuBarSubMenuCell else {
            return UITableViewCell(style: .default, reuseIdentifier: nil)
        }
        cell.menuItem = showingMenu.items[indexPath.row]
        if indexPath.row == showingMenu.items.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: self.bounds.size.width, bottom: 0, right: 0)
        } else {
            if cell.menuItem?.hasSeparatorLine ?? false {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            } else {
                cell.separatorInset = UIEdgeInsets(top: 0, left: self.bounds.size.width, bottom: 0, right: 0)
            }
        }
        return cell
    }
    
}

extension MenuBarSubMenuView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        self.showingMenu.items[indexPath.row].isEnabled ? indexPath : nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showingMenu.items[indexPath.row].actionSource = .clickMenu
        self.showingMenu.items[indexPath.row].action?()
        self.delegate?.menuBarDismissSubMenu(self)
    }
    
}

internal protocol MenuBarSubMenuViewDelegate: NSObject {
    func menuBarDismissSubMenu(_ menuBarSubMenu: MenuBarSubMenuView)
}
