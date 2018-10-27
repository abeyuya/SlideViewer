//
//  Config.swift
//  SlideViewer
//
//  Created by abeyuya on 2017/12/25.
//

import Foundation

public class Config {
    
    var thumbnailViewWidth: CGFloat = 120
    var portraitTopMenuHeight: CGFloat = 60
    var portraitBottomMenuHeight: CGFloat = 60
    var landscapeRightMenuWidth: CGFloat = 60

    static let shared = Config()
    private init() {}
}
