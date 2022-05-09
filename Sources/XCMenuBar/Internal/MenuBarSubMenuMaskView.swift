//
//  MenuBarSubMenuMaskView.swift
//  Code Develop
//
//  Created by xcbosa on 2022/3/27.
//

import UIKit

internal class MenuBarSubMenuMaskView: UIView {
    
    internal weak var delegate: MenuBarSubMenuMaskViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal private(set) var subMenuView: MenuBarSubMenuView?
    internal private(set) var senderFrame: CGRect?
    
    internal func showSubMenu(_ subMenu: MenuBarMenu, senderFrame: CGRect) {
        self.removeSubMenu()
        self.senderFrame = senderFrame
        let subMenuView = MenuBarSubMenuView(effect: UIBlurEffect(style: .regular), showingMenu: subMenu)
        subMenuView.delegate = self
        self.addSubview(subMenuView)
        subMenuView.layoutIfNeeded()
        
        var alignFrame = senderFrame
        alignFrame.size = subMenuView.calculateSize()
        alignFrame.origin.y = 1
        alignFrame.origin.x = max(alignFrame.origin.x, 0)
        if alignFrame.origin.x + alignFrame.width > self.frame.width {
            // 如果以按钮左侧为矩形起点，则矩形会溢出屏幕
            alignFrame.origin.x = self.frame.width - alignFrame.width
            if alignFrame.origin.x < 0 {
                // 如果以屏幕最右侧为矩形右边，则矩形依然会溢出屏幕，将大小修正为屏幕大小
                alignFrame.origin.x = 0
                alignFrame.size.width = self.frame.width
            }
        }
        subMenuView.isScrollEnabled = alignFrame.size.height > self.frame.height
        alignFrame.size.height = min(alignFrame.size.height, self.frame.height)
        
        subMenuView.frame = alignFrame
        self.subMenuView = subMenuView
    }
    
    private func removeSubMenu() {
        if let subMenuView = subMenuView {
            subMenuView.removeFromSuperview()
            self.subMenuView = nil
        }
        self.senderFrame = nil
    }
    
    private func configureSubview() {
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let subMenuView = subMenuView {
            if subMenuView.frame.contains(point) {
                return true
            }
            if let senderFrame = senderFrame {
                let fixedFrame = CGRect(x: senderFrame.origin.x,
                                        y: -100,
                                        width: senderFrame.size.width,
                                        height: 105)
                if fixedFrame.contains(point) {
                    return true
                }
            }
            self.removeSubMenu()
            self.delegate?.maskViewDidDismiss(self)
        }
        return false
    }
    
}

extension MenuBarSubMenuMaskView: MenuBarSubMenuViewDelegate {
    
    func menuBarDismissSubMenu(_ menuBarSubMenu: MenuBarSubMenuView) {
        self.removeSubMenu()
        self.delegate?.maskViewDidDismiss(self)
    }
    
}

internal protocol MenuBarSubMenuMaskViewDelegate: NSObject {
    func maskViewDidDismiss(_ maskView: MenuBarSubMenuMaskView)
}
