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

        Slide.build(pdfFileURL: URL(string: pdfURL)!) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let slide):
                let vc = SlideViewerController.setup(slide: slide)
                
                DispatchQueue.main.async {
                    self.present(vc, animated: true)
                }
            }
        }
    }
    
    @IBAction func tapHttpsPDFFile(_ sender: Any) {
        let pdfURL = "https://speakerd.s3.amazonaws.com/presentations/50021f75cf1db900020005e7/speakerdeck.pdf"
        
        Slide.build(pdfFileURL: URL(string: pdfURL)!) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let slide):
                let vc = SlideViewerController.setup(slide: slide)
                
                DispatchQueue.main.async {
                    self.present(vc, animated: true)
                }
            }
        }
    }
    
    @IBAction func tapShowLocalPDFFile(_ sender: Any) {
        let path = Bundle.main.path(forResource: "speakerdeck", ofType: "pdf")
        let url = URL(fileURLWithPath: path!)
        let doc = PDFDocument(url: url)
        let slide = try! Slide(pdfDocument: doc!)
        let vc = SlideViewerController.setup(slide: slide)
        present(vc, animated: true)
    }
}

