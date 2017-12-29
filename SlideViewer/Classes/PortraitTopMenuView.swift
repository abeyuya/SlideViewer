//
//  PortraitTopMenuView.swift
//  SlideViewer
//
//  Created by abeyuya on 2017/12/23.
//

import UIKit

final class PortraitTopMenuView: UIView {
    
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var avatarImage: UIImageView!
    
    internal static func initFromBundledNib() throws -> PortraitTopMenuView {
        let podBundle = Bundle(for: SlideViewerController.classForCoder())
        
        guard let bundleURL = podBundle.url(forResource: "SlideViewer", withExtension: "bundle"),
            let bundle = Bundle(url: bundleURL) else {
                throw SlideViewerError.cannotLoadBundledResource
        }
        
        guard let topMenu = bundle.loadNibNamed(
            "PortraitTopMenuView",
            owner: self,
            options: nil)?.first as? PortraitTopMenuView else {
                throw SlideViewerError.cannotLoadBundledResource
        }
        
        topMenu.translatesAutoresizingMaskIntoConstraints = false
        
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
