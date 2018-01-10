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
        case needPassword(pdfDocument: PDFDocument)
    }
    
    internal struct Info {
        var avatarImageURL: URL? = nil
        var title: String = ""
        var author: String = ""
    }

    var state: State = .loading(progress: 0)
    var pdfDocument: PDFDocument? = nil
    var info = Info()
}

extension Slide {
    
    internal enum FetchResult {
        case loading(progress: Float)
        case failure(error: SlideViewerError)
        case complete(pdfDocument: PDFDocument)
        case needPassword(pdfDocument: PDFDocument)
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
                    guard doc.isEncrypted == false else {
                        return completion(.needPassword(pdfDocument: doc))
                    }
                    
                    return completion(.complete(pdfDocument: doc))
                }
            }
            
            return
        }
        
        DispatchQueue.global(qos: .default).async {
            let doc = PDFDocument(url: pdfFileURL)!
            completion(.complete(pdfDocument: doc))
        }
    }
}
