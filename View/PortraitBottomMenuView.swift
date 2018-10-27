//
//  PortraitBottomMenuView.swift
//  SlideViewer
//
//  Created by abeyuya on 2017/12/28.
//

import UIKit

public protocol PortraitBottomMenu {
    var delegate: PortraitBottomMenuDelegate? { get set }
}

public protocol PortraitBottomMenuDelegate {
    func showShareSelctFromPortraitBottomMenu() -> Void
}

open class PortraitBottomMenuView: UIView, PortraitBottomMenu {
    
    public var delegate: PortraitBottomMenuDelegate? = nil
    
    @objc public func showShareSelectAction() {
        delegate?.showShareSelctFromPortraitBottomMenu()
    }
}

final class DefaultPortraitBottomMenuView: PortraitBottomMenuView {

    @IBOutlet weak var shareButton: UIButton!
    
    internal static func initFromBundledNib() throws -> DefaultPortraitBottomMenuView {
        let podBundle = Bundle(for: SlideViewerController.classForCoder())
        
        guard let bundleURL = podBundle.url(forResource: "SlideViewer", withExtension: "bundle"),
            let bundle = Bundle(url: bundleURL) else {
                throw SlideViewerError.cannotLoadBundledResource
        }
        
        guard let bottomMenu = bundle.loadNibNamed(
            "DefaultPortraitBottomMenuView",
            owner: self,
            options: nil)?.first as? DefaultPortraitBottomMenuView else {
                throw SlideViewerError.cannotLoadBundledResource
        }
        
        bottomMenu.shareButton.addTarget(
            bottomMenu,
            action: #selector(showShareSelectAction),
            for: .touchUpInside)

        bottomMenu.translatesAutoresizingMaskIntoConstraints = false
        
        return bottomMenu
    }
}
