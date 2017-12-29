//
//  FileDownloader.swift
//  SlideViewer
//
//  Created by abeyuya on 2017/12/28.
//

import Foundation

internal final class FileDownloader: NSObject {
    
    enum DownloadResult {
        case loading(progress: Float)
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
    
    private func resetRequestInfo() {
        self.completion = nil
        self.originURL = nil
    }
}

extension FileDownloader: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let completion = self.completion,
            let originURL = self.originURL else {
                resetRequestInfo()
                return
        }
        
        resetRequestInfo()
        
        guard let data = NSData(contentsOf: location), data.length > 0 else {
            return completion(.failure(error: .invalidPDFFile))
        }
        
        let tempPath = NSTemporaryDirectory() + originURL.lastPathComponent
        data.write(toFile: tempPath, atomically: true)
        
        completion(.success(url: URL(fileURLWithPath: tempPath)))
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            if let completion = self.completion {
                resetRequestInfo()
                completion(.failure(error: .cannotDownloadFile(message: error.localizedDescription)))
            }
            
            session.invalidateAndCancel()
            return
        }
        
        session.finishTasksAndInvalidate()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        if let completion = self.completion {
            completion(.loading(progress: progress))
        }
    }
}
