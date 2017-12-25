//
//  SlideViewerError.swift
//  PDFSlideView
//
//  Created by abeyuya on 2017/12/22.
//

import Foundation

enum SlideViewerError: Error {
    
    case invalidPDFFile
    case cannotLoadBundledResource
    
    var message: String {
        switch self {
        case .invalidPDFFile: return "Invalid PDF file."
        case .cannotLoadBundledResource: return "Cannot load bundled resource."
        }
    }
}
