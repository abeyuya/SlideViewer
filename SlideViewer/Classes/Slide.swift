//
//  Slide.swift
//  SlideViewer
//
//  Created by abeyuya on 2017/12/24.
//

import Foundation
import PDFKit

internal struct Slide {
    
    internal enum State {
        case loading(progress: Float)
        case failure(error: SlideViewerError)
        case complete(slide: Slide)
    }

    var images: [UIImage?] = []
    var thumbnailImages: [UIImage?] = []
    var pdfDocument: PDFDocument? = nil
}

extension Slide {

    internal init(pdfDocument: PDFDocument) {
        self.pdfDocument = pdfDocument
        
        self.images = Array(repeating: nil, count: pdfDocument.pageCount)
        self.thumbnailImages = Array(repeating: nil, count: pdfDocument.pageCount)
    }
    
    internal static func fetch(pdfFileURL: URL, completion: @escaping (State) -> Void) {
        guard pdfFileURL.absoluteString.hasPrefix("https") == false else {
            FileDownloader.shared.download(url: pdfFileURL) { result in
                switch result {
                case .loading(let progress):
                    return completion(.loading(progress: progress))
                case .failure(let error):
                    return completion(.failure(error: error))
                case .success(let url):
                    guard let document = PDFDocument(url: url) else {
                        return completion(.failure(error: .invalidPDFFile))
                    }
                    let slide = Slide(pdfDocument: document)
                    return completion(.complete(slide: slide))
                }
            }
            
            return
        }
        
        DispatchQueue.global(qos: .default).async {
            let doc = PDFDocument(url: pdfFileURL)!
            let slide = Slide(pdfDocument: doc)
            completion(.complete(slide: slide))
        }
    }
}
