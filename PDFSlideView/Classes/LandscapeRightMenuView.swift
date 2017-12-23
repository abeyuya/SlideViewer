//
//  LandscapeRightMenuView.swift
//  PDFSlideView
//
//  Created by abeyuya on 2017/12/23.
//

import UIKit

final class LandscapeRightMenuView: UIView {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var thumbnailButton: UIButton!
    @IBOutlet weak var pageLabel: UILabel!
    
    static func initFromBundledNib() throws -> LandscapeRightMenuView {
        let podBundle = Bundle(for: PDFSlideViewController.classForCoder())
        
        guard let bundleURL = podBundle.url(forResource: "PDFSlideView", withExtension: "bundle"),
            let bundle = Bundle(url: bundleURL) else {
                throw PDFSlideViewError.cannotLoadBundledResource
        }
        
        guard let rightMenu = bundle.loadNibNamed("LandscapeRightMenuView", owner: self, options: nil)?.first as? LandscapeRightMenuView else {
            throw PDFSlideViewError.cannotLoadBundledResource
        }
        
        rightMenu.translatesAutoresizingMaskIntoConstraints = false
        
        return rightMenu
    }
}
