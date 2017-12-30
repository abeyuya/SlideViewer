//
//  PortraitTopMenuView.swift
//  SlideViewer
//
//  Created by abeyuya on 2017/12/23.
//

import UIKit

public protocol PortraitTopMenu {
    var delegate: PortraitTopMenuDelegate? { get set }
}

public protocol PortraitTopMenuDelegate {
    func closeFromPortraitTopMenu() -> Void
}

open class PortraitTopMenuView: UIView, PortraitTopMenu {

    public var delegate: PortraitTopMenuDelegate? = nil
    
    @objc public func closeAction() {
        delegate?.closeFromPortraitTopMenu()
    }
}

final class DefaultPortraitTopMenuView: PortraitTopMenuView {
    
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var avatarImage: UIImageView!
    
    internal static func initFromBundledNib() throws -> DefaultPortraitTopMenuView {
        let podBundle = Bundle(for: SlideViewerController.classForCoder())
        
        guard let bundleURL = podBundle.url(forResource: "SlideViewer", withExtension: "bundle"),
            let bundle = Bundle(url: bundleURL) else {
                throw SlideViewerError.cannotLoadBundledResource
        }
        
        guard let topMenu = bundle.loadNibNamed(
            "DefaultPortraitTopMenuView",
            owner: self,
            options: nil)?.first as? DefaultPortraitTopMenuView else {
                throw SlideViewerError.cannotLoadBundledResource
        }
        
        topMenu.translatesAutoresizingMaskIntoConstraints = false
        
        topMenu.closeButton.addTarget(
            topMenu,
            action: #selector(closeAction),
            for: .touchUpInside)
        
        return topMenu
    }
    
    internal func setAvatarImage(imageURL: URL) {
        DispatchQueue.global(qos: .default).async {
            guard let data = try? Data(contentsOf: imageURL) else { return }
            let image = UIImage(data: data)
            
            DispatchQueue.main.async {
                self.avatarImage.image = image
            }
        }
    }
}
