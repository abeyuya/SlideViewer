//
//  LandscapeRightMenuView.swift
//  SlideViewer
//
//  Created by abeyuya on 2017/12/23.
//

import UIKit

final class LandscapeRightMenuView: UIView {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var thumbnailButton: UIButton!
    @IBOutlet weak var pageLabel: UILabel!
    
    internal static func initFromBundledNib() throws -> LandscapeRightMenuView {
        let podBundle = Bundle(for: SlideViewerController.classForCoder())
        
        guard let bundleURL = podBundle.url(forResource: "SlideViewer", withExtension: "bundle"),
            let bundle = Bundle(url: bundleURL) else {
                throw SlideViewerError.cannotLoadBundledResource
        }
        
        guard let rightMenu = bundle.loadNibNamed(
            "LandscapeRightMenuView",
            owner: self,
            options: nil)?.first as? LandscapeRightMenuView else {
                throw SlideViewerError.cannotLoadBundledResource
        }
        
        rightMenu.translatesAutoresizingMaskIntoConstraints = false
        
        return rightMenu
    }
}
