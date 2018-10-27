//
//  NSLayoutConstraint+Extension.swift
//  SlideViewer
//
//  Created by abeyuya on 2017/12/28.
//

import Foundation

internal extension NSLayoutConstraint {
    
    internal static func build(
        _ fromItem: UIView,
        attribute fromAttribute: NSLayoutConstraint.Attribute,
        toItem: Any?,
        attribute toAttribute: NSLayoutConstraint.Attribute? = nil) -> NSLayoutConstraint {
        return NSLayoutConstraint(
            item: fromItem,
            attribute: fromAttribute,
            relatedBy: .equal,
            toItem: toItem,
            attribute: toAttribute ?? fromAttribute,
            multiplier: 1,
            constant: 0)
    }
}
