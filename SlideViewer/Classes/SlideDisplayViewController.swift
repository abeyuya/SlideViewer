//
//  SlideDisplayViewController.swift
//  SlideViewer
//
//  Created by abeyuya on 2017/12/23.
//

import UIKit
import PDFKit
import ReSwift

final class SlideDisplayViewController: UIViewController {
    
    internal var index: Int

    private lazy var scrollView: UIScrollView = {
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

    private var imageView: UIImageView? = nil
    
    private let indicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(activityIndicatorStyle: .white)
        v.startAnimating()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    internal init(index: Int) {
        self.index = index
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SlideDisplayViewController {

    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layoutFill(subView: scrollView)
        view.layoutCenter(subView: indicator)
        renderImage()
    }
    
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        mainStore.subscribe(self) { subscription in
            subscription.select { state in state.slide.state }
        }
    }
    
    internal override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
    }
    
    internal override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    internal override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let imageView = imageView, let size = imageView.image?.size {
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
    
    private func renderImage() {
        guard self.imageView == nil,
            case .complete = mainStore.state.slide.state,
            let doc = mainStore.state.slide.pdfDocument,
            let page = doc.page(at: index),
            let pageRef = page.pageRef else { return }
        
        DispatchQueue.global(qos: .default).async {
            let pageRect = page.bounds(for: .mediaBox)
            let renderer = UIGraphicsImageRenderer(size: pageRect.size)
            let image = renderer.image { ctx in
                UIColor.white.set()
                ctx.fill(pageRect)
                
                ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
                ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                
                ctx.cgContext.drawPDFPage(pageRef)
            }
            
            DispatchQueue.main.async {
                self.indicator.removeFromSuperview()
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFit
                self.scrollView.addSubview(imageView)
                self.imageView = imageView
                self.view.setNeedsLayout()
            }
        }
    }
}

extension SlideDisplayViewController: UIScrollViewDelegate {

    internal func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    internal func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateScrollInset()
        
        if scrollView.zoomScale > 1.0 {
            mainStore.dispatch(hideMenu())
        } else {
            mainStore.dispatch(showMenu())
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
    
    private func zoomRectForScale(scale:CGFloat, center: CGPoint) -> CGRect {
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
        if let imageView = imageView {
            scrollView.contentInset = UIEdgeInsetsMake(
                max((scrollView.frame.height - imageView.frame.height)/2, 0),
                max((scrollView.frame.width - imageView.frame.width)/2, 0),
                0,
                0
            )
        }
    }
}

extension SlideDisplayViewController: StoreSubscriber {
    
    internal typealias StoreSubscriberStateType = Slide.State
    
    internal func newState(state: StoreSubscriberStateType) {
        guard case .complete = state else { return }
        renderImage()
    }
}
