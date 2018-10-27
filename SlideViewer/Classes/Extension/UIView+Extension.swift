//
//  UIView+Extension.swift
//  SlideViewer
//
//  Created by abeyuya on 2017/12/28.
//

import UIKit

internal extension UIView {
    
    internal func layoutFill(subView: UIView) {
        addSubview(subView)
        addConstraints([
            NSLayoutConstraint.build(subView, attribute: .top, toItem: self),
            NSLayoutConstraint.build(subView, attribute: .leading, toItem: self),
            NSLayoutConstraint.build(subView, attribute: .trailing, toItem: self),
            NSLayoutConstraint.build(subView, attribute: .bottom, toItem: self),
            ])
    }
    
    internal func layoutCenter(subView: UIView) {
        addSubview(subView)
        addConstraints([
            NSLayoutConstraint.build(subView, attribute: .centerX, toItem: self),
            NSLayoutConstraint.build(subView, attribute: .centerY, toItem: self),
        ])
    }
}
