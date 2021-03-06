//
//  SlideViewerError.swift
//  SlideViewer
//
//  Created by abeyuya on 2017/12/22.
//

import Foundation

public enum SlideViewerError: Error {
    
    case invalidPDFFile
    case cannotLoadBundledResource
    case cannotDownloadFile(message: String)
    
    var message: String {
        switch self {
        case .invalidPDFFile: return "Invalid PDF file."
        case .cannotLoadBundledResource: return "Cannot load bundled resource."
        case .cannotDownloadFile(let message): return message
        }
    }
}
