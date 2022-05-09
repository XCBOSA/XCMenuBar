//
//  UIKeyCommandWrapper.swift
//  Code Develop
//
//  Created by xcbosa on 2022/3/29.
//

import UIKit

extension UIKeyCommand {
    
    internal class func keyInfoFrom(keyString string: String) -> (UIKeyModifierFlags, String) {
        let cmds = string.split(separator: "+").map({ $0.description.trimmingCharacters(in: .whitespacesAndNewlines) })
        var modifierFlags: UIKeyModifierFlags = []
        var strings = ""
        for cmd in cmds {
            switch cmd {
            case "Command":
                modifierFlags.insert(.command)
                break
            case "Control": fallthrough
            case "Ctrl":
                modifierFlags.insert(.control)
                break
            case "Shift":
                modifierFlags.insert(.shift)
                break
            default:
                strings += cmd
                break
            }
        }
        return (modifierFlags, strings.keyInputCode)
    }
    
    internal func compareTo(menuItem: MenuBarMenuItem) -> Bool {
        if self.title != menuItem.text {
            return false
        }
        let (modifierFlags, string) = Self.keyInfoFrom(keyString: menuItem.keyInput ?? "")
        if self.modifierFlags != modifierFlags {
            return false
        }
        if self.input != string {
            return false
        }
        return true
    }
    
}
