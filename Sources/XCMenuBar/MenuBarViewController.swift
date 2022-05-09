//
//  MenuBarViewController.swift
//  Code Develop
//
//  Created by xcbosa on 2022/3/26.
//

import UIKit
import FastLayout

public class MenuBarViewController: UIViewController, UICollectionViewDelegate {
    
    public private(set) var viewController: UIViewController
    
    public private(set) var displayMenus = [MenuBarMenu]()
    
    public private(set) var selectedMenuTitle: String?
    
    public private(set) var highlightedMenuTitle: String?
    
    public var enableRightItems: Bool = true
    
    private func titleNeedHighlight(_ title: String?) -> Bool {
        selectedMenuTitle == title || highlightedMenuTitle == title
    }
    
    private lazy var menuArea: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: TabGroupLayout(coder: NSCoder())!)
        view.register(MenuBarTitleCell.self, forCellWithReuseIdentifier: "MenuBarTitleCell")
        view.backgroundColor = .clear
        view.allowsSelection = false
        view.delegate = self
        view.dataSource = self
        view.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        return view
    }()
    
    private lazy var rightButton: MenuBarTitleCell = {
        let cell = MenuBarTitleCell(frame: .zero)
        cell.isHidden = true
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onRightButtonClicked(_:))))
        return cell
    }()
    
    private lazy var menuBottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    private lazy var maskArea: MenuBarSubMenuMaskView = {
        let view = MenuBarSubMenuMaskView(frame: .zero)
        view.delegate = self
        view.isHidden = true
        return view
    }()
    
    public init(rootViewController: UIViewController) {
        self.viewController = rootViewController
        super.init(nibName: nil, bundle: nil)
        self.configureSubviews()
        self.startObserve()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var menuAreaRightToRightButtonLeftConstraint: NSLayoutConstraint!
    private var menuAreaRightToSuperViewRightConstraint: NSLayoutConstraint!
    
    private var rightButtonAction: (() -> Void)?
    
    private func setRightButton(enabled: Bool, withImage image: UIImage? = nil, andAction action: (() -> Void)? = nil) {
        rightButtonAction = action
        rightButton.image = image
        rightButton.isHidden = !enabled
        menuAreaRightToRightButtonLeftConstraint.isActive = enabled
        menuAreaRightToSuperViewRightConstraint.isActive = !enabled
    }
    
    private func configureSubviews() {
        self.view.backgroundColor = UIColorGrayScale(diff: 0.1, alpha: 1)
        
        self.addChild(viewController)
        self.view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        
        self.view.addSubview(rightButton)
        rightButton.top == self.view.safeAreaLayoutGuide.topAnchor + 1
        rightButton.right == self.view.rightAnchor - 5
        rightButton.width == 50
        rightButton.height == 35
        
        self.view.addSubview(menuArea)
        menuArea.left == self.view.leftAnchor
        menuArea.top == self.view.safeAreaLayoutGuide.topAnchor
        menuAreaRightToRightButtonLeftConstraint = menuArea.right == self.rightButton.leftAnchor
        menuAreaRightToSuperViewRightConstraint = menuArea.right == self.view.rightAnchor
        menuArea.height == 37
        
        self.view.addSubview(menuBottomLine)
        menuBottomLine.left == self.view.leftAnchor
        menuBottomLine.top == menuArea.bottom
        menuBottomLine.right == self.view.rightAnchor
        menuBottomLine.height == 0.5
        
        self.view.addSubview(maskArea)
        maskArea.left == self.view.leftAnchor
        maskArea.right == self.view.rightAnchor
        maskArea.top == menuBottomLine.bottomAnchor
        maskArea.bottom == self.view.bottomAnchor
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.topAnchor == self.menuBottomLine.bottomAnchor
        viewController.view.leftAnchor == self.view.leftAnchor
        viewController.view.rightAnchor == self.view.rightAnchor
        viewController.view.bottomAnchor == self.view.bottomAnchor
        
        setRightButton(enabled: false)
    }
    
    private func compareMenuTitles(_ last: [MenuBarMenu], _ current: [MenuBarMenu]) -> Bool {
        if last.count != current.count { return false }
        for i in 0..<last.count {
            let lastI = last[i]
            let currentI = current[i]
            if lastI.text != currentI.text { return false }
            if lastI.image != currentI.image { return false }
        }
        return true
    }
    
    private func startObserve() {
        var lastDisplayMenus = [MenuBarMenu]()
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) {
            [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            self.displayMenus = MenuBarItemScanner.getMenus(fromRootViewController: self.viewController)
            if !self.compareMenuTitles(lastDisplayMenus, self.displayMenus) {
                self.menuArea.reloadData()
            }
            lastDisplayMenus = self.displayMenus
            self.loadOrUpdateKeyBinds(self.displayMenus)
            if self.enableRightItems {
                if let item = MenuBarItemScanner.getRightItem(fromRootViewController: self.viewController).first {
                    self.setRightButton(enabled: true, withImage: item.image, andAction: item.action)
                } else {
                    self.setRightButton(enabled: false)
                }
            } else {
                self.setRightButton(enabled: false)
            }
        }
    }
    
    @objc private func onRightButtonClicked(_ any: Any) {
        rightButton.menuIsSelected = true
        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) {
            [weak self] timer in
            timer.invalidate()
            self?.rightButton.menuIsSelected = false
            self?.rightButtonAction?()
        }
    }
    
    private func loadOrUpdateKeyBinds(_ menus: [MenuBarMenu]) {
        for menu in menus {
            for menuItem in menu.items.filter({ $0.isEnabled }) {
                // 查找菜单里有的但是keyCommands里没有的
                if let detailText = menuItem.keyInput {
                    var shouldAdd = false
                    if let keyCommands = self.keyCommands {
                        if !keyCommands.contains(where: { $0.compareTo(menuItem: menuItem) }) {
                            shouldAdd = true
                        } else {
                            shouldAdd = false
                        }
                    } else {
                        shouldAdd = true
                    }
                    if shouldAdd {
                        let keyInfo = UIKeyCommand.keyInfoFrom(keyString: detailText)
                        self.addKeyCommand(UIKeyCommand(title: menuItem.text ?? "",
                                                        image: nil,
                                                        action: #selector(onKeyBindsReceiveEvents(_:)),
                                                        input: keyInfo.1,
                                                        modifierFlags: keyInfo.0,
                                                        propertyList: nil,
                                                        alternates: [],
                                                        discoverabilityTitle: nil,
                                                        attributes: [], state: .on))
                    }
                }
            }
        }
        if let copiedKeyCommands = self.keyCommands {
            for keyCommand in copiedKeyCommands {
                // 查找keyCommands里有的但是菜单里没有的
                var founded = false
                for menu in menus {
                    var breakMenuIteration = false
                    for menuItem in menu.items.filter({ $0.isEnabled }) {
                        if menuItem.keyInput != nil {
                            if keyCommand.compareTo(menuItem: menuItem) {
                                founded = true
                                breakMenuIteration = true
                                break
                            }
                        }
                    }
                    if breakMenuIteration { break }
                }
                if !founded {
                    self.removeKeyCommand(keyCommand)
                }
            }
        }
    }
    
    @objc private func onKeyBindsReceiveEvents(_ keyCommand: UIKeyCommand) {
        for menu in self.displayMenus {
            if let selectedMenu = menu.items.first(where: { keyCommand.compareTo(menuItem: $0) }) {
                highlightedMenuTitle = menu.text
                menuArea.reloadData()
                Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) {
                    [weak self] timer in
                    timer.invalidate()
                    self?.highlightedMenuTitle = nil
                    self?.menuArea.reloadData()
                }
                selectedMenu.actionSource = .keyboard
                selectedMenu.action?()
            }
        }
    }
    
    private var sizeTestCell = MenuBarTitleCell()
    
}

extension MenuBarViewController: MenuBarTitleCellDelegate {
    
    func menuBarTitleCellTouchUpInside(_ cell: MenuBarTitleCell) {
        selectedMenuTitle = cell.title
        self.menuArea.reloadData()
        self.maskArea.isHidden = false
        if let menu = self.displayMenus.first(where: { ($0.text ?? "") == cell.title }) {
            self.maskArea.showSubMenu(menu, senderFrame: CGRect(x: cell.frame.origin.x - menuArea.contentOffset.x,
                                                                y: cell.frame.origin.y - menuArea.contentOffset.y,
                                                                width: cell.frame.width,
                                                                height: cell.frame.height))
        }
    }
    
}

extension MenuBarViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        sizeTestCell.contentView.translatesAutoresizingMaskIntoConstraints = false
        sizeTestCell.title = displayMenus[indexPath.row].text ?? ""
        sizeTestCell.image = displayMenus[indexPath.row].image
        return sizeTestCell.calcSize(height: 35)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayMenus.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuBarTitleCell", for: indexPath) as? MenuBarTitleCell else {
            return UICollectionViewCell(frame: .zero)
        }
        cell.delegate = self
        cell.title = displayMenus[indexPath.row].text ?? ""
        cell.image = displayMenus[indexPath.row].image
        cell.menuIsSelected = self.titleNeedHighlight(cell.title)
        return cell
    }
    
}

extension MenuBarViewController: MenuBarSubMenuMaskViewDelegate {
    
    func maskViewDidDismiss(_ maskView: MenuBarSubMenuMaskView) {
        maskView.isHidden = true
        (self.menuArea.visibleCells as! [MenuBarTitleCell])
            .first(where: { $0.menuIsSelected == true })?.menuIsSelected = false
        self.selectedMenuTitle = nil
    }
    
}

extension String {
    public static var arrowUp = "↑"
    public static var arrowDown = "↓"
    public static var arrowLeft = "←"
    public static var arrowRight = "→"
    
    public var keyInputCode: String {
        self.replacingOccurrences(of: Self.arrowUp, with: UIKeyCommand.inputUpArrow)
            .replacingOccurrences(of: Self.arrowDown, with: UIKeyCommand.inputDownArrow)
            .replacingOccurrences(of: Self.arrowLeft, with: UIKeyCommand.inputLeftArrow)
            .replacingOccurrences(of: Self.arrowRight, with: UIKeyCommand.inputRightArrow)
    }
}

func UIColorGrayScale(diff: CGFloat, alpha: CGFloat) -> UIColor {
    return UIColor { $0.userInterfaceStyle == .dark ? UIColor(white: diff, alpha: alpha) : UIColor(white: 1 - diff, alpha: alpha) }
}
