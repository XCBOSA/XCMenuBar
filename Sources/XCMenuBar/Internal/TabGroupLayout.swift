//
//  TabGroupLayout.swift
//  Code Develop
//
//  Created by xcbosa on 2021/5/2.
//

import UIKit

class TabGroupLayout: UICollectionViewFlowLayout {
    
    public var itemAttributes: [UICollectionViewLayoutAttributes]?
    
    required init?(coder: NSCoder) {
        super.init()
        self.scrollDirection = .horizontal;
        self.minimumInteritemSpacing = 1;
        self.minimumLineSpacing = 1;
        self.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func prepare() {
        super.prepare()
        if self.collectionView == nil { return }
        if self.collectionView!.delegate == nil { return }
        let itemCount = self.collectionView?.numberOfItems(inSection: 0)
        if itemCount == nil { return }
        self.itemAttributes = [UICollectionViewLayoutAttributes]()
        for _ in 0..<itemCount! {
            self.itemAttributes?.append(UICollectionViewLayoutAttributes())
        }
        var xOffset = self.sectionInset.left
        var yOffset = self.sectionInset.top
        var xNextOffset = self.sectionInset.left
        for idx in 0..<itemCount! {
            let indexPath = IndexPath(item: idx, section: 0)
            let itemSize = (self.collectionView!.delegate as! UICollectionViewDelegateFlowLayout).collectionView!(collectionView!, layout: self, sizeForItemAt: indexPath
            )
            xNextOffset += self.minimumInteritemSpacing + itemSize.width
            if xNextOffset > self.collectionView!.bounds.size.width - self.sectionInset.right {
                xOffset = self.sectionInset.left
                xNextOffset = self.sectionInset.left + self.minimumInteritemSpacing + itemSize.width
                yOffset += itemSize.height + self.minimumLineSpacing
            }
            else {
                xOffset = xNextOffset - (self.minimumInteritemSpacing + itemSize.width)
            }
            let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            layoutAttributes.frame = CGRect(x: xOffset, y: yOffset, width: itemSize.width, height: itemSize.height)
            itemAttributes!.append(layoutAttributes)
        }
    }
    
}
