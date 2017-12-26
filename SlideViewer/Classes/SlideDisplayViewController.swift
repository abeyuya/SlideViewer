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
    
    internal var index: Int = 0

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
        let v = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        v.startAnimating()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
}

extension SlideDisplayViewController {

    internal override func viewDidLoad() {
        super.viewDidLoad()
        layoutView()
        
        if let image = mainStore.state.slide.images[index] {
            setImageView(image: image)
        } else {
            loadImage(state: mainStore.state, index: index)
        }
    }
    
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainStore.subscribe(self) { subscription in
            subscription.select { state in state.slide.images[self.index] }
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
    
    private func setImageView(image: UIImage) {
        indicator.removeFromSuperview()
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)
        self.imageView = imageView
        self.view.setNeedsLayout()
    }

    private func layoutView() {
        view.addSubview(scrollView)
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
        
        view.addSubview(indicator)
        view.addConstraints([
            NSLayoutConstraint(
                item: indicator,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: view,
                attribute: .centerX,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: indicator,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: view,
                attribute: .centerY,
                multiplier: 1,
                constant: 0),
            ])
    }
}

extension SlideDisplayViewController: UIScrollViewDelegate {

    internal func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    internal func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateScrollInset()
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
    
    internal typealias StoreSubscriberStateType = UIImage?
    
    internal func newState(state loadedImage: StoreSubscriberStateType) {
        guard self.imageView == nil else { return }
        guard let loadedImage = loadedImage else { return }
        self.setImageView(image: loadedImage)
    }
}
