//
//  LandscapeRightMenuView.swift
//  SlideViewer
//
//  Created by abeyuya on 2017/12/23.
//

import UIKit

public protocol LandscapeRightMenu {
    func update(currentPageIndex: Int?, pageCount: Int?) -> Void
    var delegate: LandscapeRightMenuDelegate? { get set }
}

public protocol LandscapeRightMenuDelegate {
    func closeFromLandscapeRightMenu() -> Void
    func toggleThumbnailAction() -> Void
    func showShareSelctFromLandscapeRightMenu() -> Void
}

open class LandscapeRightMenuView: UIView, LandscapeRightMenu {

    public var delegate: LandscapeRightMenuDelegate? = nil

    open func update(currentPageIndex: Int?, pageCount: Int?) {
        fatalError("Need to override this method")
    }
    
    @objc public func closeAction() {
        delegate?.closeFromLandscapeRightMenu()
    }
    
    @objc public func toggleThumbnailAction() {
        delegate?.toggleThumbnailAction()
    }
    
    @objc public func showShareSelectAction() {
        delegate?.showShareSelctFromLandscapeRightMenu()
    }
}

internal final class DefaultLandscapeRightMenuView: LandscapeRightMenuView {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var thumbnailButton: UIButton!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    internal static func initFromBundledNib() throws -> DefaultLandscapeRightMenuView {
        let podBundle = Bundle(for: SlideViewerController.classForCoder())
        
        guard let bundleURL = podBundle.url(forResource: "SlideViewer", withExtension: "bundle"),
            let bundle = Bundle(url: bundleURL) else {
                throw SlideViewerError.cannotLoadBundledResource
        }
        
        guard let rightMenu = bundle.loadNibNamed(
            "DefaultLandscapeRightMenuView",
            owner: self,
            options: nil)?.first as? DefaultLandscapeRightMenuView else {
                throw SlideViewerError.cannotLoadBundledResource
        }
        
        rightMenu.closeButton.addTarget(
            rightMenu,
            action: #selector(closeAction),
            for: .touchUpInside)
        rightMenu.thumbnailButton.addTarget(
            rightMenu,
            action: #selector(toggleThumbnailAction),
            for: .touchUpInside)
        rightMenu.shareButton.addTarget(
            rightMenu,
            action: #selector(showShareSelectAction),
            for: .touchUpInside)

        rightMenu.translatesAutoresizingMaskIntoConstraints = false
        
        return rightMenu
    }
    
    override func update(currentPageIndex: Int? = nil, pageCount: Int? = nil) {
        if let c = currentPageIndex, let p = pageCount {
            pageLabel.text = "\(c + 1) of \(p)"
        } else {
            pageLabel.text = ""
        }
    }
}
