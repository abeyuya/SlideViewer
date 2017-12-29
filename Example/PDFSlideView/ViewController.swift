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
        let v = SlideViewerController.setup(pdfFileURL: URL(string: pdfURL)!)
        present(v, animated: true, completion: nil)
    }
    
    @IBAction func tapShowLocalPDFFile(_ sender: Any) {
        let path = Bundle.main.path(forResource: "speakerdeck", ofType: "pdf")
        let url = URL(fileURLWithPath: path!)
        let doc = PDFDocument(url: url)
        let v = SlideViewerController.setup(pdfDocument: doc!)
        present(v, animated: true)
    }
}

