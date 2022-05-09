//
//  MenuBarCell.swift
//  Code Develop
//
//  Created by xcbosa on 2022/3/26.
//

import UIKit
import FastLayout

internal class MenuBarTitleCell: UICollectionViewCell {

    internal var title: String = "" {
        didSet {
            titleLabel.text = title
            viewState.triggerViewSizeChanged(width: 0, height: 0)
        }
    }
    
    internal var image: UIImage? = nil {
        didSet {
            imageView.image = image
            viewState.triggerViewSizeChanged(width: 0, height: 0)
        }
    }
    
    internal var menuIsSelected: Bool = false {
        didSet {
            super.contentView.backgroundColor = menuIsSelected ? UIColorGrayScale(diff: 0.2, alpha: 1) : .clear
            self.layer.borderWidth = menuIsSelected ? 0.5 : 0
        }
    }
    
    internal weak var delegate: MenuBarTitleCellDelegate?
    
    private lazy var viewStateCheckerAll: FLViewStateCheckerBlock = { [self] _, _ in imageView.image != nil && (titleLabel.text ?? "").count > 0 }
    private lazy var viewStateCheckerText: FLViewStateCheckerBlock = { [self] _, _ in imageView.image == nil && (titleLabel.text ?? "").count > 0 }
    private lazy var viewStateCheckerImage: FLViewStateCheckerBlock = { [self] _, _ in imageView.image != nil && (titleLabel.text ?? "").count == 0 }
    
    fileprivate class NoIntrinsicSizeImageView: UIImageView {
        override var intrinsicContentSize: CGSize { .zero }
    }
    
    private lazy var imageView: NoIntrinsicSizeImageView = {
        let view = NoIntrinsicSizeImageView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(descriptor: UIFont.systemFont(ofSize: 15).fontDescriptor.withSymbolicTraits(.traitBold)!, size: 15)
        view.textAlignment = .center
        return view
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var viewState = FLViewStateManager()
    
    private func configureSubview() {
        self.contentView.configureSubView(imageView, titleLabel)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 7
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.systemFill.cgColor
        
        let stateAll = FLViewState(configureWithRecorder: .standard, checkerBlock: viewStateCheckerAll)
        imageView.left == contentView.leftAnchor + 10
        imageView.top == contentView.topAnchor + 5
        imageView.bottom == contentView.bottomAnchor - 5
        imageView.width == imageView.height
        titleLabel.left == imageView.right + 5
        titleLabel.top == contentView.topAnchor
        titleLabel.bottom == contentView.bottomAnchor
        titleLabel.right == contentView.rightAnchor - 5
        stateAll.finishRecorder()
        viewState.register(viewState: stateAll)
        
        let stateText = FLViewState(configureWithRecorder: .standard, checkerBlock: viewStateCheckerText)
        titleLabel.left == contentView.leftAnchor + 5
        titleLabel.right == contentView.rightAnchor - 5
        titleLabel.top == contentView.topAnchor
        titleLabel.bottom == contentView.bottomAnchor
        stateText.finishRecorder()
        viewState.register(viewState: stateText)
        
        let stateImage = FLViewState(configureWithRecorder: .standard, checkerBlock: viewStateCheckerImage)
        imageView.left == contentView.leftAnchor + 15
        imageView.top == contentView.topAnchor + 5
        imageView.bottom == contentView.bottomAnchor - 5
        imageView.width == imageView.height
        imageView.right == contentView.rightAnchor - 15
        stateImage.finishRecorder()
        viewState.register(viewState: stateImage)
        
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchUpInsideCell(_:))))
    }
    
    @objc private func touchUpInsideCell(_ any: Any) {
        delegate?.menuBarTitleCellTouchUpInside(self)
    }
    
    internal func calcSize(height: CGFloat) -> CGSize {
        let textW = ((titleLabel.text ?? "") as NSString).size(withAttributes: [NSAttributedString.Key.font : titleLabel.font!]).width + 10
        let imageW = height - 5 - 5
        if viewStateCheckerAll(0, 0) {
            return CGSize(width: 10 + imageW + 5 + textW + 5, height: height)
        }
        if viewStateCheckerText(0, 0) {
            return CGSize(width: 5 + textW + 5, height: height)
        }
        if viewStateCheckerImage(0, 0) {
            return CGSize(width: 15 + imageW + 15, height: height)
        }
        return .zero
    }
    
}

internal protocol MenuBarTitleCellDelegate: NSObject {
    func menuBarTitleCellTouchUpInside(_ cell: MenuBarTitleCell)
}
