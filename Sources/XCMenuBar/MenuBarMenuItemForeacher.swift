//
//  Foreacher.swift
//  Code Develop
//
//  Created by xcbosa on 2022/3/30.
//

import UIKit

public class MenuBarMenuItemForeacher<ModelTy>: MenuBarMenuItem {
    
    public init(withModelArray array: [ModelTy], modelToMenuItemClosure closure: (ModelTy) -> MenuBarMenuItem) {
        super.init(withText: nil, andAction: nil)
        super.arrayItems = array.map(closure)
    }
    
}

