//
//  PDFSlideViewController.swift
//  PDFSlideView
//
//  Created by abeyuya on 2017/12/21.
//

import UIKit
import PDFKit
import ReSwift

public final class PDFSlideViewController: UIViewController {
    private var document: PDFDocument? = nil
    
    private lazy var slideAreaView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var portraitTopMenuView: PortraitTopMenuView = {
        let topMenu = try! PortraitTopMenuView.initFromBundledNib()
        return topMenu
    }()
    
    private lazy var landscapeRightMenuView: LandscapeRightMenuView = {
        let rightMenu = try! LandscapeRightMenuView.initFromBundledNib()
        return rightMenu
    }()
    
    private lazy var thumbnailAreaView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let thumbnailAreaWidth: CGFloat = 120
    
    private lazy var thumbnailAreaViewWidthConstraint: NSLayoutConstraint = {
        return NSLayoutConstraint(
            item: thumbnailAreaView,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .width,
            multiplier: 1,
            constant: thumbnailAreaWidth)
    }()
    
    private lazy var slideContainerViewController: SlideContainerViewController = {
        let v = SlideContainerViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil)
        v.document = document
        v.view.translatesAutoresizingMaskIntoConstraints = false
        addChildViewController(v)
        slideAreaView.addSubview(v.view)
        v.didMove(toParentViewController: self)
        return v
    }()
    
    private lazy var thumbnailViewController: ThumbnailContainerViewController = {
        let v = ThumbnailContainerViewController()
        v.document = document
        v.view.translatesAutoresizingMaskIntoConstraints = false
        addChildViewController(v)
        thumbnailAreaView.addSubview(v.view)
        v.didMove(toParentViewController: self)
        return v
    }()
}

extension PDFSlideViewController {
    
    public static func setup(pdfFileURL: String) -> PDFSlideViewController {
        let url = URL(string: pdfFileURL)!
        let document = PDFDocument(url: url)

        let vc = PDFSlideViewController()
        vc.document = document
        return vc
    }
}

extension PDFSlideViewController {
    
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

extension PDFSlideViewController {
    
    private func setupView() {
        guard document != nil else {
            // TODO: show Error
            return
        }
        
        view.backgroundColor = .black

        setupPDFView()
        setupPortraitTopMenuView()
        setupLandscapeRightMenuView()
        setupThumbnailView()
        layoutView()
    }
    
    private func setupPDFView() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapSlideView))
        slideAreaView.addGestureRecognizer(gesture)
        view.addSubview(slideAreaView)
    }
    
    private func setupPortraitTopMenuView() {
        portraitTopMenuView.closeButton.addTarget(
            self,
            action: #selector(self.close),
            for: .touchUpInside)
        
        view.addSubview(portraitTopMenuView)
    }
    
    private func setupLandscapeRightMenuView() {
        landscapeRightMenuView.closeButton.addTarget(
            self,
            action: #selector(self.close),
            for: .touchUpInside)
        landscapeRightMenuView.thumbnailButton.addTarget(
            self,
            action: #selector(self.toggleThumbnailView),
            for: .touchUpInside)
        
        view.addSubview(landscapeRightMenuView)
    }
    
    private func setupThumbnailView() {
        view.addSubview(thumbnailAreaView)
    }
    
    private func layoutView() {
        let safeArea = view.safeAreaLayoutGuide
        
        view.addConstraints([
            NSLayoutConstraint(
                item: thumbnailAreaView,
                attribute: .top,
                relatedBy: .equal,
                toItem: safeArea,
                attribute: .top,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: thumbnailAreaView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: safeArea,
                attribute: .leading,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: thumbnailAreaView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: slideAreaView,
                attribute: .leading,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: thumbnailAreaView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: safeArea,
                attribute: .bottom,
                multiplier: 1,
                constant: 0),
            ])
        
        view.addConstraints([
            NSLayoutConstraint(
                item: slideAreaView,
                attribute: .top,
                relatedBy: .equal,
                toItem: safeArea,
                attribute: .top,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: slideAreaView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: safeArea,
                attribute: .trailing,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: slideAreaView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: safeArea,
                attribute: .bottom,
                multiplier: 1,
                constant: 0),
            thumbnailAreaViewWidthConstraint
            ])
        
        view.addConstraints([
            NSLayoutConstraint(
                item: portraitTopMenuView,
                attribute: .top,
                relatedBy: .equal,
                toItem: safeArea,
                attribute: .top,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: portraitTopMenuView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: safeArea,
                attribute: .leading,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: portraitTopMenuView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: safeArea,
                attribute: .trailing,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: portraitTopMenuView,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .height,
                multiplier: 1,
                constant: 60),
            ])
        
        view.addConstraints([
            NSLayoutConstraint(
                item: landscapeRightMenuView,
                attribute: .top,
                relatedBy: .equal,
                toItem: safeArea,
                attribute: .top,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: landscapeRightMenuView,
                attribute: .width,
                relatedBy: .equal,
                toItem: nil,
                attribute: .width,
                multiplier: 1,
                constant: 60),
            NSLayoutConstraint(
                item: landscapeRightMenuView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: safeArea,
                attribute: .trailing,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: landscapeRightMenuView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: safeArea,
                attribute: .bottom,
                multiplier: 1,
                constant: 0),
            ])
        
        view.addConstraints([
            NSLayoutConstraint(
                item: slideContainerViewController.view,
                attribute: .top,
                relatedBy: .equal,
                toItem: slideAreaView,
                attribute: .top,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: slideContainerViewController.view,
                attribute: .leading,
                relatedBy: .equal,
                toItem: slideAreaView,
                attribute: .leading,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: slideContainerViewController.view,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: slideAreaView,
                attribute: .trailing,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: slideContainerViewController.view,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: slideAreaView,
                attribute: .bottom,
                multiplier: 1,
                constant: 0),
            ])
        
        view.addConstraints([
            NSLayoutConstraint(
                item: thumbnailViewController.view,
                attribute: .top,
                relatedBy: .equal,
                toItem: thumbnailAreaView,
                attribute: .top,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: thumbnailViewController.view,
                attribute: .leading,
                relatedBy: .equal,
                toItem: thumbnailAreaView,
                attribute: .leading,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: thumbnailViewController.view,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: thumbnailAreaView,
                attribute: .trailing,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: thumbnailViewController.view,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: thumbnailAreaView,
                attribute: .bottom,
                multiplier: 1,
                constant: 0),
            ])
    }
}

extension PDFSlideViewController {
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func tapSlideView() {
        mainStore.dispatch(toggleMenu())
    }
    
    @objc private func toggleThumbnailView() {
        mainStore.dispatch(toggleThumbnail())
    }
}

extension PDFSlideViewController: StoreSubscriber {
    public typealias StoreSubscriberStateType = PDFSlideViewState

    public func newState(state: PDFSlideViewController.StoreSubscriberStateType) {
        print("state update!")
        print(state)
        
        renderMenu(state: state)
        renderThumbnailView(state: state)
    }
    
    private func renderMenu(state: PDFSlideViewState) {
        guard let document = document else { return }
        
        guard state.showMenu else {
            portraitTopMenuView.isHidden = true
            landscapeRightMenuView.isHidden = true
            return
        }
        
        guard state.isPortrait else {
            portraitTopMenuView.isHidden = true
            landscapeRightMenuView.isHidden = false
            landscapeRightMenuView.pageLabel.text = "\(state.currentPageIndex + 1) of \(document.pageCount)"
            return
        }
        
        portraitTopMenuView.isHidden = false
        landscapeRightMenuView.isHidden = true
    }
    
    private func renderThumbnailView(state: PDFSlideViewState) {
        guard state.isPortrait == false else {
            thumbnailAreaViewWidthConstraint.constant = 0
            return
        }
        
        guard state.showThumbnail else {
            thumbnailAreaViewWidthConstraint.constant = 0
            return
        }
        
        thumbnailAreaViewWidthConstraint.constant = thumbnailAreaWidth
    }
}
