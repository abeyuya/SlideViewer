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

        let pdfView = setupPDFView()
        let topMenu = setupPortraitTopMenuView()
        layoutView(pdfView: pdfView, topMenu: topMenu)
    }
    
    private func setupPDFView() -> PDFView {
        let pdfView = PDFView(frame: view.frame)
        pdfView.backgroundColor = .orange
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.usePageViewController(true, withViewOptions: nil)
        pdfView.document = document
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(pdfView)
        return pdfView
    }
    
    private func setupPortraitTopMenuView() -> PortraitTopMenuView? {
        guard let topMenu = PortraitTopMenuView.initFromBundledNib() else { return nil }
        topMenu.closeButton.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        view.addSubview(topMenu)
        return topMenu
    }
    
    private func layoutView(pdfView: PDFView, topMenu: PortraitTopMenuView?) {
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
        
        if let topMenu = topMenu {
            view.addConstraints([
                NSLayoutConstraint(
                    item: topMenu,
                    attribute: .top,
                    relatedBy: .equal,
                    toItem: safeArea,
                    attribute: .top,
                    multiplier: 1,
                    constant: 0),
                NSLayoutConstraint(
                    item: topMenu,
                    attribute: .leading,
                    relatedBy: .equal,
                    toItem: safeArea,
                    attribute: .leading,
                    multiplier: 1,
                    constant: 0),
                NSLayoutConstraint(
                    item: topMenu,
                    attribute: .trailing,
                    relatedBy: .equal,
                    toItem: safeArea,
                    attribute: .trailing,
                    multiplier: 1,
                    constant: 0),
                NSLayoutConstraint(
                    item: topMenu,
                    attribute: .height,
                    relatedBy: .equal,
                    toItem: nil,
                    attribute: .height,
                    multiplier: 1,
                    constant: 44),
                ])
        }
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
}

extension PDFSlideViewController: StoreSubscriber {
    public typealias StoreSubscriberStateType = PDFSlideViewState

    public func newState(state: PDFSlideViewController.StoreSubscriberStateType) {
        print("state update!")
        print(state)
    }
}
