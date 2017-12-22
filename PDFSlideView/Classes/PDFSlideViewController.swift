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
        //        let safeArea = view.safeAreaLayoutGuide
        
        let pdfView = createPDFView()
        view.addSubview(pdfView)
        
        view.addConstraints([
            NSLayoutConstraint(
                item: pdfView,
                attribute: .top,
                relatedBy: .equal,
                toItem: view,
                attribute: .top,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: pdfView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: view,
                attribute: .leading,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: pdfView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: view,
                attribute: .trailing,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: pdfView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: view,
                attribute: .bottom,
                multiplier: 1,
                constant: 0),
            ])
    }
    
    private func createPDFView() -> PDFView {
        let pdfView = PDFView(frame: view.frame)
        pdfView.document = document
        pdfView.backgroundColor = .black
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.usePageViewController(true, withViewOptions: nil)
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        
        return pdfView
    }
}

extension PDFSlideViewController: StoreSubscriber {
    public typealias StoreSubscriberStateType = PDFSlideViewState

    public func newState(state: PDFSlideViewController.StoreSubscriberStateType) {
        print("state update!")
        print(state)
    }
}
