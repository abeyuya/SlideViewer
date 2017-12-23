//
//  PortraitTopMenuView.swift
//  PDFSlideView
//
//  Created by abeyuya on 2017/12/23.
//

import UIKit

final class PortraitTopMenuView: UIView {
    
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var avatarImage: UIImageView!
    
    static func initFromBundledNib() throws -> PortraitTopMenuView {
        let podBundle = Bundle(for: PDFSlideViewController.classForCoder())
        
        guard let bundleURL = podBundle.url(forResource: "PDFSlideView", withExtension: "bundle"),
            let bundle = Bundle(url: bundleURL) else {
                throw PDFSlideViewError.cannotLoadBundledResource
        }
        
        guard let topMenu = bundle.loadNibNamed("PortraitTopMenuView", owner: self, options: nil)?.first as? PortraitTopMenuView else {
                throw PDFSlideViewError.cannotLoadBundledResource
        }
        
        topMenu.translatesAutoresizingMaskIntoConstraints = false
        
        return topMenu
    }
}
