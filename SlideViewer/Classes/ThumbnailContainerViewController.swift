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
    
    internal lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.estimatedRowHeight = mainStore.state.thumbnailHeight ?? 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(ThumbnailTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .black
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
    
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mainStore.subscribe(self) { subscription in
            subscription.select { state in
                SubscribeState(
                    moveToThumbnailIndex: state.moveToThumbnailIndex,
                    thumbnailHeight: state.thumbnailHeight
                )
            }
        }
    }
    
    internal override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
    }
    
    internal override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ThumbnailContainerViewController: UITableViewDelegate, UITableViewDataSource {
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainStore.state.slide.thumbnailImages.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ThumbnailTableViewCell else {
            return UITableViewCell()
        }
        
        cell.set(index: indexPath.row, tableView: tableView)
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mainStore.dispatch(moveToSlide(pageIndex: indexPath.row))
        mainStore.dispatch(moveToThumbnail(pageIndex: indexPath.row))
    }
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return mainStore.state.thumbnailHeight ?? tableView.estimatedRowHeight
    }
}

internal struct SubscribeState {
    let moveToThumbnailIndex: Int?
    let thumbnailHeight: CGFloat?
}

extension ThumbnailContainerViewController: StoreSubscriber {
    internal typealias StoreSubscriberStateType = SubscribeState
 
    internal func newState(state: StoreSubscriberStateType) {
        guard tableView.numberOfRows(inSection: 0) > 0 else { return }
        
        if let index = state.moveToThumbnailIndex {
            tableView.scrollToRow(
                at: IndexPath(row: index, section: 0),
                at: .middle,
                animated: true)
            mainStore.dispatch(moveToThumbnail(pageIndex: nil))
        }
    }
}
