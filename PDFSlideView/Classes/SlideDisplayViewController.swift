//
//  SlideDisplayViewController.swift
//  PDFSlideView
//
//  Created by abeyuya on 2017/12/23.
//

import UIKit
import PDFKit

final class SlideDisplayViewController: UIViewController {
    
    var index: Int? = nil
    var pdfPage: PDFPage? = nil
    
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.delegate = self
        v.minimumZoomScale = 1
        v.maximumZoomScale = 3
        v.backgroundColor = .black
        v.isScrollEnabled = true
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        v.isUserInteractionEnabled = true
        v.translatesAutoresizingMaskIntoConstraints = false
        
        let doubleTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(self.doubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        v.addGestureRecognizer(doubleTapGesture)
        
        return v
    }()
    
    lazy var imageView: UIImageView = {
        let pageRect = pdfPage!.bounds(for: .mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            
            ctx.cgContext.drawPDFPage(pdfPage!.pageRef!)
        }
        
        let imageView = UIImageView(image: img)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        layoutView()
    }
    
    private func layoutView() {
        view.addConstraints([
            NSLayoutConstraint(
                item: scrollView,
                attribute: .top,
                relatedBy: .equal,
                toItem: view,
                attribute: .top,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: scrollView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: view,
                attribute: .leading,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: scrollView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: view,
                attribute: .trailing,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: scrollView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: view,
                attribute: .bottom,
                multiplier: 1,
                constant: 0),
            ])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SlideDisplayViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateScrollInset()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let size = imageView.image?.size {
            let wrate = scrollView.frame.width / size.width
            let hrate = scrollView.frame.height / size.height
            let rate = min(wrate, hrate, 1)
            imageView.frame.size = CGSize(width: size.width * rate, height: size.height * rate)
            
            scrollView.contentSize = imageView.frame.size
            updateScrollInset()
        }
    }
}

extension SlideDisplayViewController {
    
    @objc func doubleTap(gesture: UITapGestureRecognizer) -> Void {
        if (self.scrollView.zoomScale < self.scrollView.maximumZoomScale) {
            let newScale = self.scrollView.zoomScale * 3
            let zoomRect = self.zoomRectForScale(scale: newScale, center: gesture.location(in: gesture.view))
            self.scrollView.zoom(to: zoomRect, animated: true)
        } else {
            self.scrollView.setZoomScale(1.0, animated: true)
        }
    }
    
    func zoomRectForScale(scale:CGFloat, center: CGPoint) -> CGRect{
        let size = CGSize(
            width: self.scrollView.frame.size.width / scale,
            height: self.scrollView.frame.size.height / scale
        )
        return CGRect(
            origin: CGPoint(
                x: center.x - size.width / 2.0,
                y: center.y - size.height / 2.0
            ),
            size: size
        )
    }

    private func updateScrollInset() {
        scrollView.contentInset = UIEdgeInsetsMake(
            max((scrollView.frame.height - imageView.frame.height)/2, 0),
            max((scrollView.frame.width - imageView.frame.width)/2, 0),
            0,
            0
        )
    }
}
