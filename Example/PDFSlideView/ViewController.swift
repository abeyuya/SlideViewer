//
//  ViewController.swift
//  PDFSlideView
//
//  Created by abeyuya on 12/21/2017.
//  Copyright (c) 2017 abeyuya. All rights reserved.
//

import UIKit
import PDFSlideView

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tapShowPDFSlideView(_ sender: Any) {
//        let pdfURL = "https://speakerd.s3.amazonaws.com/presentations/50021f75cf1db900020005e7/speakerdeck.pdf"
        let pdfURL = "http://gahp.net/wp-content/uploads/2017/09/sample.pdf"
        let vc = PDFSlideViewController.setup(pdfFileURL: pdfURL)
        present(vc, animated: true)
    }
}

