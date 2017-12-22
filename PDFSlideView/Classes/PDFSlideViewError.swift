//
//  PDFSlideViewError.swift
//  PDFSlideView
//
//  Created by abeyuya on 2017/12/22.
//

import Foundation

enum PDFSlideViewError: Error {
    
    case invalidPDFFileURL
    
    var message: String {
        switch self {
        case .invalidPDFFileURL: return "Invalid PDF file url."
        }
    }
}
