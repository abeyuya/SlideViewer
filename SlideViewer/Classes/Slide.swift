//
//  Slide.swift
//  PDFSlideView
//
//  Created by abeyuya on 2017/12/24.
//

import Foundation
import PDFKit

public struct Slide {
    var images: [UIImage?] = []
    var thumbnailImages: [UIImage?] = []
    var pdfDocument: PDFDocument? = nil
}

extension Slide {
    
    public init(pdfDocument: PDFDocument) {
        self.pdfDocument = pdfDocument
        
        self.images = Array(repeating: nil, count: pdfDocument.pageCount)
        self.thumbnailImages = Array(repeating: nil, count: pdfDocument.pageCount)
    }
    
    public init(pdfFileURL: URL) throws {
        // TODO: https URL
        guard let document = PDFDocument(url: pdfFileURL) else {
            throw SlideViewerError.invalidPDFFile
        }
        
        self.init(pdfDocument: document)
    }
}
