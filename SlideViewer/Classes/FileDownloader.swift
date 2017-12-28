//
//  FileDownloader.swift
//  SlideViewer
//
//  Created by abeyuya on 2017/12/28.
//

import Foundation

internal final class FileDownloader: NSObject {
    
    enum DownloadResult {
        case failure(error: SlideViewerError)
        case success(url: URL)
    }
    
    static let shared = FileDownloader()
    private override init() {}
    
    private var completion: ((_ result: DownloadResult) -> Void)? = nil
    private var originURL: URL? = nil
    
    internal func download(url: URL, completion: @escaping (_ result: DownloadResult) -> Void) {
        self.completion = completion
        self.originURL = url
        
        let config = URLSessionConfiguration.default
        let session = URLSession(
            configuration: config,
            delegate: self,
            delegateQueue: OperationQueue.main)
        let task = session.downloadTask(with: url)
        task.resume()
    }
}

extension FileDownloader: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let completion = self.completion,
            let originURL = self.originURL else { return }
        
        guard let data = NSData(contentsOf: location), data.length > 0 else {
            completion(.failure(error: .invalidPDFFile))
            return
        }
        
        let tempPath = NSTemporaryDirectory() + originURL.lastPathComponent
        data.write(toFile: tempPath, atomically: true)
        
        completion(.success(url: URL(fileURLWithPath: tempPath)))
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error == nil{
            session.finishTasksAndInvalidate()
        } else {
            session.invalidateAndCancel()
        }
    }
}
