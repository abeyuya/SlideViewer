//
//  Slide.swift
//  SlideViewer
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
    
    public enum SetupResult {
        case failure(error: SlideViewerError)
        case success(slide: Slide)
    }
    
    public init(pdfDocument: PDFDocument) {
        self.pdfDocument = pdfDocument
        
        self.images = Array(repeating: nil, count: pdfDocument.pageCount)
        self.thumbnailImages = Array(repeating: nil, count: pdfDocument.pageCount)
    }
    
    public static func build(pdfFileURL: URL, completion: @escaping (SetupResult) -> Void) {
        guard pdfFileURL.absoluteString.hasPrefix("https") == false else {
            FileDownloader.shared.download(url: pdfFileURL) { result in
                switch result {
                case .failure(let error):
                    return completion(.failure(error: error))
                case .success(let url):
                    guard let document = PDFDocument(url: url) else {
                        return completion(.failure(error: .invalidPDFFile))
                    }
                    let slide = Slide(pdfDocument: document)
                    return completion(.success(slide: slide))
                }
            }
            
            return
        }
        
        let doc = PDFDocument(url: pdfFileURL)!
        let slide = Slide(pdfDocument: doc)
        completion(.success(slide: slide))
    }
}
