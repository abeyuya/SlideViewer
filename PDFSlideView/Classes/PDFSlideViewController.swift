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
    
    private lazy var thumbnailTableView: UITableView = {
        let tableView = UITableView()
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(ThumbnailTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    private let thumbnailWidth: CGFloat = 120
    
    private lazy var thumbnailTableViewWidth: NSLayoutConstraint = {
        return NSLayoutConstraint(
            item: thumbnailTableView,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .width,
            multiplier: 1,
            constant: thumbnailWidth)
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
        setupThumbnailTableView()
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
    
    private func setupThumbnailTableView() {
        view.addSubview(thumbnailTableView)
    }
    
    private func layoutView() {
        let safeArea = view.safeAreaLayoutGuide
        
        view.addConstraints([
            NSLayoutConstraint(
                item: thumbnailTableView,
                attribute: .top,
                relatedBy: .equal,
                toItem: safeArea,
                attribute: .top,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: thumbnailTableView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: safeArea,
                attribute: .leading,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: thumbnailTableView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: pdfView,
                attribute: .leading,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: thumbnailTableView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: safeArea,
                attribute: .bottom,
                multiplier: 1,
                constant: 0),
            ])
        
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
            thumbnailTableViewWidth
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
            landscapeRightMenuView.pageLabel.text = "\(state.currentPage) of \(document.pageCount)"
            return
        }
        
        portraitTopMenuView.isHidden = false
        landscapeRightMenuView.isHidden = true
    }
    
    private func renderThumbnailView(state: PDFSlideViewState) {
        guard state.isPortrait == false else {
            thumbnailTableViewWidth.constant = 0
            return
        }
        
        guard state.showThumbnail else {
            thumbnailTableViewWidth.constant = 0
            return
        }
        
        thumbnailTableViewWidth.constant = thumbnailWidth
    }
}

extension PDFSlideViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return document?.pageCount ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ThumbnailTableViewCell else {
            return UITableViewCell()
        }
        
        guard let doc = document, let pdf = doc.page(at: indexPath.row) else { return UITableViewCell() }
        let thumbImage = pdf.thumbnail(of: CGSize(width: cell.frame.size.width, height: cell.frame.size.height), for: .artBox)
        cell.thumbnail.image = thumbImage
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
