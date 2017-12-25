//
//  ThumbnailTableViewCell.swift
//  PDFSlideView
//
//  Created by abeyuya on 2017/12/23.
//

import UIKit
import ReSwift

final class ThumbnailTableViewCell: UITableViewCell {
    
    var index: Int? = nil
    var thumbnail: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    var tableView: UITableView? = nil

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        mainStore.subscribe(self)
        setupImageView()
    }
    
    deinit {
        mainStore.unsubscribe(self)
    }
    
    override func prepareForReuse() {
        // TODO: show loading indicator
        thumbnail.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension ThumbnailTableViewCell {
    
    func set(index: Int, tableView: UITableView) {
        self.index = index
        self.tableView = tableView
        
        if let image = mainStore.state.slide.thumbnailImages[index] {
            thumbnail.image = image
        } else {
            loadImage(state: mainStore.state, index: index)
        }
    }
    
    private func setupImageView() {
        contentView.addSubview(thumbnail)
        
        contentView.addConstraints([
            NSLayoutConstraint(
                item: thumbnail,
                attribute: .top,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .top,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: thumbnail,
                attribute: .leading,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .leading,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: thumbnail,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .trailing,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: thumbnail,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .bottom,
                multiplier: 1,
                constant: 0),
            ])
    }
}

extension ThumbnailTableViewCell: StoreSubscriber {
    
    public typealias StoreSubscriberStateType = SlideViewerState
    
    public func newState(state: StoreSubscriberStateType) {
        guard let index = index,
            let tableView = tableView,
            thumbnail.image == nil else { return }
        
        if let image = state.slide.thumbnailImages[index] {
            thumbnail.image = image
            tableView.reloadData()
        }
    }
}
