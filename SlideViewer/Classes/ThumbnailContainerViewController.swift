//
//  ThumbnailContainerViewController.swift
//  SlideViewer
//
//  Created by abeyuya on 2017/12/24.
//

import UIKit
import PDFKit
import ReSwift

final class ThumbnailContainerViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.estimatedRowHeight = 500
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(ThumbnailTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
}

extension ThumbnailContainerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        layoutView()
    }
    
    private func layoutView() {
        view.addConstraints([
            NSLayoutConstraint(
                item: tableView,
                attribute: .top,
                relatedBy: .equal,
                toItem: view,
                attribute: .top,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: tableView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: view,
                attribute: .leading,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: tableView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: view,
                attribute: .trailing,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: tableView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: view,
                attribute: .bottom,
                multiplier: 1,
                constant: 0),
            ])
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainStore.subscribe(self) { subscription in
            subscription.select { state in state.currentPageIndex }
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ThumbnailContainerViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainStore.state.slide.thumbnailImages.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ThumbnailTableViewCell else {
            return UITableViewCell()
        }
        
        cell.set(index: indexPath.row, tableView: tableView)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mainStore.dispatch(selectThumbnail(pageIndex: indexPath.row))
    }
}

extension ThumbnailContainerViewController: StoreSubscriber {
    public typealias StoreSubscriberStateType = Int
 
    public func newState(state currentPageIndex: StoreSubscriberStateType) {
        guard tableView.numberOfRows(inSection: 0) > 0 else { return }
        print("index: \(currentPageIndex)")
        tableView.scrollToRow(
            at: IndexPath(row: currentPageIndex, section: 0),
            at: .middle,
            animated: true)
    }
}
