//
//  MenuBarSubMenuCell.swift
//  Code Develop
//
//  Created by xcbosa on 2022/3/27.
//

import UIKit
import FastLayout

internal class MenuBarSubMenuCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configureSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal var menuItem: MenuBarMenuItem? = nil {
        didSet {
            if let menuItem = menuItem {
                titleLabel.text = menuItem.text
                detailLabel.text = menuItem.keyInput
                titleLabel.textColor = menuItem.isEnabled ? .label : UIColorGrayScale(diff: 0.4, alpha: 1)
            }
        }
    }
    
    internal var menuIsSelected: Bool = false {
        didSet {
            contentView.backgroundColor = menuIsSelected ? .cyan.withAlphaComponent(0.25) : .clear
        }
    }
    
    internal class func calculateSize(forMenuItem menuItem: MenuBarMenuItem) -> CGSize {
        let titleS = ((menuItem.text ?? "") as NSString).size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)])
        let detailS = ((menuItem.keyInput ?? "") as NSString).size(withAttributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)])
        return CGSize(width: 10 + titleS.width + 10 + 5 + detailS.width + 10 + 10,
                      height: max(10 + titleS.height + 10, 10 + detailS.height + 10))
    }
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 15)
        return view
    }()
    
    private lazy var detailLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 15)
        view.textColor = UIColorGrayScale(diff: 0.4, alpha: 1)
        return view
    }()
    
    private func configureSubview() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        self.contentView.addSubview(titleLabel)
        titleLabel.left == self.contentView.leftAnchor + 10
        titleLabel.top == self.contentView.topAnchor + 10
        titleLabel.bottom == self.contentView.bottomAnchor - 10
        
        self.contentView.addSubview(detailLabel)
        detailLabel.left == titleLabel.right + 5
        detailLabel.top == self.contentView.topAnchor + 10
        detailLabel.bottom == self.contentView.bottomAnchor - 10
        detailLabel.right == self.contentView.rightAnchor - 10
    }
    
}
