//
//  ThumbnailTableViewCell.swift
//  SlideViewer
//
//  Created by abeyuya on 2017/12/23.
//

import UIKit
import ReSwift

final class ThumbnailTableViewCell: UITableViewCell {
    
    internal var index: Int? = nil
    internal var tableView: UITableView? = nil
    
    private let thumbnail: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let indicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        v.startAnimating()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        mainStore.subscribe(self) { subscription in
            subscription.select { state in
                guard let index = self.index else { return nil }
                guard index < state.slide.thumbnailImages.count else { return nil }
                return state.slide.thumbnailImages[index]
            }
        }
        
        setupImageView()
    }
    
    deinit {
        mainStore.unsubscribe(self)
    }
    
    internal override func prepareForReuse() {
        super.prepareForReuse()
        thumbnail.image = nil
    }

    internal override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension ThumbnailTableViewCell {
    
    internal func set(index: Int, tableView: UITableView) {
        self.index = index
        self.tableView = tableView
        
        if let image = mainStore.state.slide.thumbnailImages[index] {
            thumbnail.image = image
            indicator.removeFromSuperview()
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
        
        thumbnail.addSubview(indicator)
        contentView.addConstraints([
            NSLayoutConstraint(
                item: indicator,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: thumbnail,
                attribute: .centerX,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: indicator,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: thumbnail,
                attribute: .centerY,
                multiplier: 1,
                constant: 0),
        ])
    }
}

extension ThumbnailTableViewCell: StoreSubscriber {
    
    internal typealias StoreSubscriberStateType = UIImage?
    
    internal func newState(state image: StoreSubscriberStateType) {
        guard thumbnail.image == nil,
            let image = image,
            let tableView = tableView else { return }
        
        thumbnail.image = image
        indicator.removeFromSuperview()
        tableView.reloadData()
    }
}
