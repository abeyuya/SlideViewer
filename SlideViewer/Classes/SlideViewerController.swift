//
//  SlideViewerController.swift
//  SlideViewer
//
//  Created by abeyuya on 2017/12/21.
//

import UIKit
import PDFKit
import ReSwift

public final class SlideViewerController: UIViewController {
    
    private lazy var slideAreaView: UIView = {
        let v = UIView()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapSlideView))
        v.addGestureRecognizer(gesture)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var portraitTopMenuView: PortraitTopMenuView = {
        let v = try! PortraitTopMenuView.initFromBundledNib()
        v.closeButton.addTarget(
            self,
            action: #selector(self.close),
            for: .touchUpInside)
        return v
    }()
    
    private lazy var portraitBottomMenuView: PortraitBottomMenuView = {
        let v = try! PortraitBottomMenuView.initFromBundledNib()
        v.shareButton.addTarget(
            self,
            action: #selector(self.showShareSelect),
            for: .touchUpInside)
        return v
    }()
    
    private lazy var landscapeRightMenuView: LandscapeRightMenuView = {
        let v = try! LandscapeRightMenuView.initFromBundledNib()
        v.closeButton.addTarget(
            self,
            action: #selector(self.close),
            for: .touchUpInside)
        v.thumbnailButton.addTarget(
            self,
            action: #selector(self.toggleThumbnailView),
            for: .touchUpInside)
        v.shareButton.addTarget(
            self,
            action: #selector(self.showShareSelect),
            for: .touchUpInside)
        return v
    }()
    
    private lazy var thumbnailAreaView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var thumbnailAreaViewWidthConstraint: NSLayoutConstraint = {
        return NSLayoutConstraint(
            item: thumbnailAreaView,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .width,
            multiplier: 1,
            constant: Config.shared.thumbnailViewWidth)
    }()
    
    private lazy var slideContainerViewController: SlideContainerViewController = {
        let v = SlideContainerViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil)
        v.view.translatesAutoresizingMaskIntoConstraints = false
        addChildViewController(v)
        slideAreaView.addSubview(v.view)
        v.didMove(toParentViewController: self)
        return v
    }()
    
    private lazy var thumbnailViewController: ThumbnailContainerViewController = {
        let v = ThumbnailContainerViewController()
        v.view.translatesAutoresizingMaskIntoConstraints = false
        addChildViewController(v)
        thumbnailAreaView.addSubview(v.view)
        v.didMove(toParentViewController: self)
        return v
    }()
    
    private let portraitPageLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 15)
        v.textColor = .white
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var shareSelectSheet: UIAlertController = {
        let v = UIAlertController(
            title: "Share",
            message: "",
            preferredStyle: .actionSheet)
        
        let currentPageAsImage = UIAlertAction(
            title: "Current Page as Image",
            style: .default) { actin in
                self.shareCurrentPageAsImage()
        }

        let asPDF = UIAlertAction(
            title: "This Slide as PDF",
            style: .default) { actin in
                self.shareSlideAsPDF()
        }

        let cancel = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil)
        
        v.addAction(currentPageAsImage)
        v.addAction(asPDF)
        v.addAction(cancel)

        return v
    }()
}

extension SlideViewerController {
    
    public static func setup(slide: Slide) -> SlideViewerController {
        mainStore.dispatch(stateReset())
        mainStore.dispatch(setSlide(slide: slide))
        let v = SlideViewerController()
        return v
    }
}

extension SlideViewerController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        mainStore.dispatch(changeIsPortrait(isPortrait: UIDevice.current.orientation.isPortrait))
        setupView()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainStore.subscribe(self)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        mainStore.dispatch(changeIsPortrait(isPortrait: UIDevice.current.orientation.isPortrait))
    }
}

extension SlideViewerController {
    
    private func setupView() {
        view.backgroundColor = .black
        let safeArea = view.safeAreaLayoutGuide
        
        view.addSubview(slideAreaView)
        view.addSubview(thumbnailAreaView)
        
        view.addConstraints([
            NSLayoutConstraint.build(thumbnailAreaView, attribute: .top, toItem: safeArea),
            NSLayoutConstraint.build(thumbnailAreaView, attribute: .leading, toItem: safeArea),
            NSLayoutConstraint.build(thumbnailAreaView, attribute: .trailing, toItem: slideAreaView, attribute: .leading),
            NSLayoutConstraint.build(thumbnailAreaView, attribute: .bottom, toItem: safeArea),
            thumbnailAreaViewWidthConstraint,
            ])
        
        view.addConstraints([
            NSLayoutConstraint.build(slideAreaView, attribute: .top, toItem: safeArea),
            NSLayoutConstraint.build(slideAreaView, attribute: .trailing, toItem: safeArea),
            NSLayoutConstraint.build(slideAreaView, attribute: .bottom, toItem: safeArea),
            ])
        
        view.addSubview(portraitTopMenuView)
        view.addConstraints([
            NSLayoutConstraint.build(portraitTopMenuView, attribute: .top, toItem: safeArea),
            NSLayoutConstraint.build(portraitTopMenuView, attribute: .leading, toItem: safeArea),
            NSLayoutConstraint.build(portraitTopMenuView, attribute: .trailing, toItem: safeArea),
            NSLayoutConstraint(
                item: portraitTopMenuView,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .height,
                multiplier: 1,
                constant: Config.shared.portraitTopMenuHeight),
            ])
        
        view.addSubview(portraitBottomMenuView)
        view.addConstraints([
            NSLayoutConstraint.build(portraitBottomMenuView, attribute: .bottom, toItem: safeArea),
            NSLayoutConstraint.build(portraitBottomMenuView, attribute: .leading, toItem: safeArea),
            NSLayoutConstraint.build(portraitBottomMenuView, attribute: .trailing, toItem: safeArea),
            NSLayoutConstraint(
                item: portraitBottomMenuView,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .height,
                multiplier: 1,
                constant: Config.shared.portraitBottomMenuHeight),
            ])
        
        view.addSubview(portraitPageLabel)
        view.addConstraints([
            NSLayoutConstraint(
                item: portraitPageLabel,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: portraitBottomMenuView,
                attribute: .top,
                multiplier: 1,
                constant: -5),
            NSLayoutConstraint.build(portraitPageLabel, attribute: .centerX, toItem: portraitBottomMenuView)
            ])
        
        view.addSubview(landscapeRightMenuView)
        view.addConstraints([
            NSLayoutConstraint.build(landscapeRightMenuView, attribute: .top, toItem: safeArea),
            NSLayoutConstraint(
                item: landscapeRightMenuView,
                attribute: .width,
                relatedBy: .equal,
                toItem: nil,
                attribute: .width,
                multiplier: 1,
                constant: Config.shared.landscapeRightMenuWidth),
            NSLayoutConstraint.build(landscapeRightMenuView, attribute: .trailing, toItem: safeArea),
            NSLayoutConstraint.build(landscapeRightMenuView, attribute: .bottom, toItem: safeArea),
            ])
        
        slideAreaView.layoutFill(subView: slideContainerViewController.view)
        thumbnailAreaView.layoutFill(subView: thumbnailViewController.view)
    }
}

extension SlideViewerController {
    
    @objc func close() {
        mainStore.dispatch(stateReset())
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func tapSlideView() {
        mainStore.dispatch(toggleMenu())
    }
    
    @objc private func toggleThumbnailView() {
        mainStore.dispatch(toggleThumbnail())
    }
    
    @objc private func showShareSelect() {
        present(shareSelectSheet, animated: true, completion: nil)
    }
    
    private func shareCurrentPageAsImage() {
        guard mainStore.state.currentPageIndex < mainStore.state.slide.images.count,
            let image = mainStore.state.slide.images[mainStore.state.currentPageIndex] else {
                // TODO: show error
                return
        }

        let v = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.present(v, animated: true, completion: nil)
    }
    
    private func shareSlideAsPDF() {
        guard let doc = mainStore.state.slide.pdfDocument, let url = doc.documentURL else { return }

        let v = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        self.present(v, animated: true, completion: nil)
    }
}

extension SlideViewerController: StoreSubscriber {
    public typealias StoreSubscriberStateType = SlideViewerState

    public func newState(state: SlideViewerController.StoreSubscriberStateType) {
        renderMenu(state: state)
        renderThumbnailView(state: state)
    }
    
    private func renderMenu(state: SlideViewerState) {
        guard state.showMenu else {
            portraitTopMenuView.isHidden = true
            portraitBottomMenuView.isHidden = true
            portraitPageLabel.isHidden = true
            landscapeRightMenuView.isHidden = true
            return
        }
        
        if state.isPortrait {
            renderPortraitMenu(state: state)
        } else {
            renderLandspaceMenu(state: state)
        }
    }
    
    private func renderPortraitMenu(state: SlideViewerState) {
        portraitTopMenuView.isHidden = false
        portraitBottomMenuView.isHidden = false
        portraitPageLabel.isHidden = false
        portraitPageLabel.text = "\(state.currentPageIndex + 1) of \(state.slide.images.count)"
        landscapeRightMenuView.isHidden = true
    }
    
    private func renderLandspaceMenu(state: SlideViewerState) {
        portraitTopMenuView.isHidden = true
        portraitBottomMenuView.isHidden = true
        portraitPageLabel.isHidden = true
        landscapeRightMenuView.isHidden = false
        landscapeRightMenuView.pageLabel.text = "\(state.currentPageIndex + 1) of \(state.slide.images.count)"
    }
    
    private func renderThumbnailView(state: SlideViewerState) {
        guard state.isPortrait == false else {
            thumbnailAreaViewWidthConstraint.constant = 0
            return
        }
        
        guard state.showThumbnail else {
            thumbnailAreaViewWidthConstraint.constant = 0
            return
        }
        
        thumbnailAreaViewWidthConstraint.constant = Config.shared.thumbnailViewWidth
    }
}
