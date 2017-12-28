//
//  PortraitBottomMenuView.swift
//  SlideViewer
//
//  Created by abeyuya on 2017/12/28.
//

import UIKit

final class PortraitBottomMenuView: UIView {

    @IBOutlet weak var shareButton: UIButton!
    
    internal static func initFromBundledNib() throws -> PortraitBottomMenuView {
        let podBundle = Bundle(for: SlideViewerController.classForCoder())
        
        guard let bundleURL = podBundle.url(forResource: "SlideViewer", withExtension: "bundle"),
            let bundle = Bundle(url: bundleURL) else {
                throw SlideViewerError.cannotLoadBundledResource
        }
        
        guard let topMenu = bundle.loadNibNamed(
            "PortraitBottomMenuView",
            owner: self,
            options: nil)?.first as? PortraitBottomMenuView else {
                throw SlideViewerError.cannotLoadBundledResource
        }
        
        topMenu.translatesAutoresizingMaskIntoConstraints = false
        
        return topMenu
    }
}
