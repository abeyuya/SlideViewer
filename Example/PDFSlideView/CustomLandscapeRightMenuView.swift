//
//  CustomLandscapeRightMenuView.swift
//  SlideViewer_Example
//
//  Created by abeyuya on 2017/12/30.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import Foundation
import SlideViewer

class CustomLandscapeRightMenuView: LandscapeRightMenuView {
    
    @IBOutlet weak var customButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var thumbButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var label: UILabel!
    
    static func build(vc: SlideViewerController) -> CustomLandscapeRightMenuView {
        let v = Bundle.main.loadNibNamed(
            "CustomLandscapeRightMenuView",
            owner: nil,
            options: nil)?.first as! CustomLandscapeRightMenuView
        v.translatesAutoresizingMaskIntoConstraints = false
        v.delegate = vc

        v.closeButton.addTarget(v, action: #selector(closeAction), for: .touchUpInside)
        v.shareButton.addTarget(v, action: #selector(showShareSelectAction), for: .touchUpInside)
        v.thumbButton.addTarget(v, action: #selector(toggleThumbnailAction), for: .touchUpInside)
        v.customButton.addTarget(v, action: #selector(tapCustomButton), for: .touchUpInside)
        
        return v
    }
    
    @objc func tapCustomButton() {
        guard let vc = delegate as? UIViewController else { return }
        
        let v = UIAlertController(
            title: "You tap custom button!",
            message: "you can implement your logic",
            preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        v.addAction(ok)
        vc.present(v, animated: true, completion: nil)
    }
    
    override func update(currentPageIndex: Int?, pageCount: Int?) {
        if let c = currentPageIndex, let p = pageCount {
            label.text = "\(c + 1) / \(p)"
        }
    }
}
