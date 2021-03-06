//
//  ViewController.swift
//  PDFSlideView
//
//  Created by abeyuya on 12/21/2017.
//  Copyright (c) 2017 abeyuya. All rights reserved.
//

import UIKit
import SlideViewer
import PDFKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tapShowPDFSlideView(_ sender: Any) {
        let pdfURL = "http://gahp.net/wp-content/uploads/2017/09/sample.pdf"
        let v = SlideViewerController.setup(pdfFileURL: URL(string: pdfURL)!)
        present(v, animated: true, completion: nil)
    }
    
    @IBAction func tapHttpsPDFFile(_ sender: Any) {
        let pdfURL = "https://speakerd.s3.amazonaws.com/presentations/50021f75cf1db900020005e7/speakerdeck.pdf"
        let avatarImageURL = "https://secure.gravatar.com/avatar/066a20c2e5d3c54f7ddb10ab9d82738e?s=47"
        let title = "Introduction to SpeakerDeck"
        let author = "Speaker Deck"
        let v = SlideViewerController.setup(
            pdfFileURL: URL(string: pdfURL)!,
            avatarImageURL: URL(string: avatarImageURL)!,
            title: title,
            author: author)
        present(v, animated: true, completion: nil)
    }
    
    @IBAction func tapShowLocalPDFFile(_ sender: Any) {
        let path = Bundle.main.path(forResource: "speakerdeck", ofType: "pdf")
        let url = URL(fileURLWithPath: path!)
        let doc = PDFDocument(url: url)
        let v = SlideViewerController.setup(pdfDocument: doc!)
        present(v, animated: true)
    }
    
    @IBAction func tapShowWithCustomMenu(_ sender: Any) {
        let path = Bundle.main.path(forResource: "speakerdeck", ofType: "pdf")!
        let url = URL(fileURLWithPath: path)
        let doc = PDFDocument(url: url)!
        let v = SlideViewerController.setup(pdfDocument: doc)
        
        let right = CustomLandscapeRightMenuView.build(vc: v)
        v.landscapeRightMenuView = right

        present(v, animated: true)
    }
    
    @IBAction func tapShowPasswordFile(_ sender: Any) {
        let path = Bundle.main.path(forResource: "speakerdeck-password", ofType: "pdf")
        let url = URL(fileURLWithPath: path!)
        let doc = PDFDocument(url: url)
        let v = SlideViewerController.setup(pdfDocument: doc!)
        present(v, animated: true)
    }
    
    @IBAction func tapShowFromImageURL(_ sender: Any) {
        let mainImageURLs = [0, 1, 2, 3, 4, 5].map { i -> URL in
            let str = [
                "https://speakerd.s3.amazonaws.com/presentations/50021f75cf1db900020005e7/",
                "preview_slide_\(i).jpg?1362165300"
                ].joined(separator: "")
            
            return URL(string: str)!
        }
        
        let thumbImageURLs = [0, 1, 2, 3, 4, 5].map { i -> URL in
            let str = [
                "https://speakerd.s3.amazonaws.com/presentations/50021f75cf1db900020005e7/",
                "thumb_slide_\(i).jpg?1362165300"
                ].joined(separator: "")
            
            return URL(string: str)!
        }
 
        // Removing chache for test (Do not need to remove cache if in production code)
        URLCache.shared.removeAllCachedResponses()
        
        let v = SlideViewerController.setup(mainImageURLs: mainImageURLs, thumbImageURLs: thumbImageURLs)
        present(v, animated: true)
    }
}
