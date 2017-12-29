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
        case complete
    }
    
    internal struct Info {
        var avatarImageURL: URL? = nil
        var title: String = ""
        var author: String = ""
    }

    var state: State = .loading(progress: 0)
    var images: [UIImage?] = []
    var thumbnailImages: [UIImage?] = []
    var pdfDocument: PDFDocument? = nil
    var info = Info()
}

extension Slide {
    
    internal enum FetchResult {
        case loading(progress: Float)
        case failure(error: SlideViewerError)
        case complete(pdfDocument: PDFDocument)
    }

    internal init(pdfDocument: PDFDocument, avatarImageURL: URL? = nil, title: String? = nil, author: String? = nil) {
        self.pdfDocument = pdfDocument
        if let avatarImageURL = avatarImageURL { self.info.avatarImageURL = avatarImageURL }
        if let title = title { self.info.title = title }
        if let author = author { self.info.author = author }
        
        self.images = Array(repeating: nil, count: pdfDocument.pageCount)
        self.thumbnailImages = Array(repeating: nil, count: pdfDocument.pageCount)
    }
    
    internal static func fetch(pdfFileURL: URL, completion: @escaping (FetchResult) -> Void) {
        guard pdfFileURL.absoluteString.hasPrefix("https") == false else {
            FileDownloader.shared.download(url: pdfFileURL) { result in
                switch result {
                case .loading(let progress):
                    return completion(.loading(progress: progress))
                case .failure(let error):
                    return completion(.failure(error: error))
                case .success(let url):
                    guard let doc = PDFDocument(url: url) else {
                        return completion(.failure(error: .invalidPDFFile))
                    }
//                    let slide = Slide(pdfDocument: document)
                    return completion(.complete(pdfDocument: doc))
                }
            }
            
            return
        }
        
        DispatchQueue.global(qos: .default).async {
            let doc = PDFDocument(url: pdfFileURL)!
//            let slide = Slide(pdfDocument: doc)
            completion(.complete(pdfDocument: doc))
        }
    }
}
