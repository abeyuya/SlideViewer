//
//  PDFSlideViewController.swift
//  PDFSlideView
//
//  Created by abeyuya on 2017/12/21.
//

import UIKit
import PDFKit

public final class PDFSlideViewController: UIViewController {
    
    private var document: PDFDocument? = nil
    
    public static func setup(pdfFileURL: String) -> PDFSlideViewController {
        let url = URL(string: pdfFileURL)!
        let document = PDFDocument(url: url)

        let vc = PDFSlideViewController()
        vc.document = document
        return vc
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let document = document else {
            // TODO: show Error
            return
        }
        
        // PDFView
        let pdfView = PDFView(frame: view.frame)
        pdfView.document = document
        pdfView.backgroundColor = .black
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.usePageViewController(true, withViewOptions: nil)
        
        view.addSubview(pdfView)
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
