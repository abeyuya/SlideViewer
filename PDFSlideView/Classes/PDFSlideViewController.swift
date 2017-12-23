//
//  PDFSlideViewController.swift
//  PDFSlideView
//
//  Created by abeyuya on 2017/12/21.
//

import UIKit
import PDFKit
import ReSwift

let mainStore = Store<PDFSlideViewState>(
    reducer: pdfSlideViewReducer,
    state: nil
)

public final class PDFSlideViewController: UIViewController {
    private var document: PDFDocument? = nil
    
    private lazy var pdfView: PDFView = {
        let pdfView = PDFView(frame: view.frame)
        pdfView.backgroundColor = .black
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.usePageViewController(true, withViewOptions: nil)
        pdfView.document = document
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        
        return pdfView
    }()
    
    private lazy var portraitTopMenuView: PortraitTopMenuView = {
        let topMenu = try! PortraitTopMenuView.initFromBundledNib()
        return topMenu
    }()
    
    private lazy var landscapeRightMenuView: LandscapeRightMenuView = {
        let rightMenu = try! LandscapeRightMenuView.initFromBundledNib()
        return rightMenu
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.pdfViewPageChanged),
            name: .PDFViewPageChanged,
            object: nil)
        mainStore.subscribe(self)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
        layoutView()
    }
    
    private func setupPDFView() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapPDFView))
        pdfView.addGestureRecognizer(gesture)
        view.addSubview(pdfView)
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
    
    private func layoutView() {
        let safeArea = view.safeAreaLayoutGuide
        
        view.addConstraints([
            NSLayoutConstraint(
                item: pdfView,
                attribute: .top,
                relatedBy: .equal,
                toItem: safeArea,
                attribute: .top,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: pdfView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: safeArea,
                attribute: .leading,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: pdfView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: safeArea,
                attribute: .trailing,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: pdfView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: safeArea,
                attribute: .bottom,
                multiplier: 1,
                constant: 0),
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
    }
}

extension PDFSlideViewController {
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func tapPDFView() {
        mainStore.dispatch(toggleMenu())
    }
    
    @objc private func toggleThumbnailView() {
        mainStore.dispatch(toggleThumbnail())
    }
    
    @objc private func pdfViewPageChanged(notification: Notification) {
        guard let doc = document, let currentPage = pdfView.currentPage else { return }
        let index = doc.index(for: currentPage)
        mainStore.dispatch(changeCurrentPage(page: index + 1))
    }
}

extension PDFSlideViewController: StoreSubscriber {
    public typealias StoreSubscriberStateType = PDFSlideViewState

    public func newState(state: PDFSlideViewController.StoreSubscriberStateType) {
        print("state update!")
        print(state)
        
        renderMenu(state: state)
    }
    
    private func renderMenu(state: PDFSlideViewState) {
        if !state.showMenu {
            portraitTopMenuView.isHidden = true
            landscapeRightMenuView.isHidden = true
            return
        }
        
        if state.isPortrait {
            portraitTopMenuView.isHidden = false
            landscapeRightMenuView.isHidden = true
        } else {
            portraitTopMenuView.isHidden = true
            landscapeRightMenuView.isHidden = false
        }
 
        if let doc = document {
            landscapeRightMenuView.pageLabel.text = "\(state.currentPage) of \(doc.pageCount)"
        }
    }
}
