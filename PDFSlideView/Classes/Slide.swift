//
//  Slide.swift
//  PDFSlideView
//
//  Created by abeyuya on 2017/12/24.
//

import Foundation
import PDFKit

public struct Slide {
    var images: [UIImage?]
}

extension Slide {
    
    public init(pdfDocument: PDFDocument) {
        let pages: [PDFPage?] = Array(0..<pdfDocument.pageCount).map({ i in
            return pdfDocument.page(at: i)
        })
        
        self.images = pages.map({ page in
            guard let page = page else { return nil }
            let pageRect = page.bounds(for: .mediaBox)
            let renderer = UIGraphicsImageRenderer(size: pageRect.size)
            let img = renderer.image { ctx in
                UIColor.white.set()
                ctx.fill(pageRect)
                
                ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
                ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                
                ctx.cgContext.drawPDFPage(page.pageRef!)
            }
            return img
        })
    }
    
    public init(pdfFileURL: URL) throws {
        // TODO: https URL
        guard let document = PDFDocument(url: pdfFileURL) else {
            throw PDFSlideViewError.invalidPDFFile
        }
        
        self.init(pdfDocument: document)
    }
}
