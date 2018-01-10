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
        v.layer.borderColor = UIColor(
            red: 19/255.0,
            green: 114/255.0,
            blue: 1.0,
            alpha: 1.0).cgColor
        return v
    }()
    
    private let indicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        v.startAnimating()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.5).cgColor
        ]
        return gradient
    }()
    
    private let numberLabel: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 15)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let separator: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        mainStore.subscribe(self) { subscription in
            subscription.select { state in
                let thumbnailImage: UIImage? = {
                    guard case .complete = state.slide.state,
                        let index = self.index else { return nil }
                    return nil // TODO: thumnail create
                }()
                
                return SubscribeState(
                    thumbnailImage: thumbnailImage,
                    currentPageIndex: state.currentPageIndex
                )
            }
        }
        
        setupView()
    }
    
    deinit {
        mainStore.unsubscribe(self)
    }

    internal override func layoutSubviews() {
        super.layoutSubviews()
        
        if gradient.frame.size.width == 0 {
            gradient.frame = self.bounds
        }
    }

    internal override func prepareForReuse() {
        super.prepareForReuse()
        thumbnail.image = nil
        renderFrame(show: false)
    }

    internal override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension ThumbnailTableViewCell {
 
    private func setupView() {
        contentView.addSubview(thumbnail)
        contentView.addSubview(separator)
        
        contentView.addConstraints([
            NSLayoutConstraint.build(thumbnail, attribute: .top, toItem: contentView),
            NSLayoutConstraint.build(thumbnail, attribute: .leading, toItem: contentView),
            NSLayoutConstraint.build(thumbnail, attribute: .trailing, toItem: contentView),
            NSLayoutConstraint.build(thumbnail, attribute: .bottom, toItem: separator, attribute: .top),
            ])
        
        contentView.addConstraints([
            NSLayoutConstraint.build(separator, attribute: .leading, toItem: contentView),
            NSLayoutConstraint.build(separator, attribute: .trailing, toItem: contentView),
            NSLayoutConstraint.build(separator, attribute: .bottom, toItem: contentView),
            NSLayoutConstraint(
                item: separator,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .height,
                multiplier: 1,
                constant: 5)
            ])

        thumbnail.layer.insertSublayer(gradient, at: 0)
        
        thumbnail.addSubview(numberLabel)
        contentView.addConstraints([
            NSLayoutConstraint(
                item: numberLabel,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: thumbnail,
                attribute: .trailing,
                multiplier: 1,
                constant: -5),
            NSLayoutConstraint(
                item: numberLabel,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: thumbnail,
                attribute: .bottom,
                multiplier: 1,
                constant: -5),
            ])
        
        thumbnail.layoutCenter(subView: indicator)
    }
    
    internal func set(index: Int, tableView: UITableView) {
        self.index = index
        self.tableView = tableView
        numberLabel.text = "\(index + 1)"
        
        guard case .complete = mainStore.state.slide.state else {
//            loadImage(state: mainStore.state, index: index)
            return
        }

//        thumbnail.image = image
        indicator.removeFromSuperview()
        renderFrame(show: index == mainStore.state.currentPageIndex)
    }
    
    private func renderFrame(show: Bool) {
        if show {
            thumbnail.layer.borderWidth = 3
        } else {
            thumbnail.layer.borderWidth = 0
        }
    }
}


extension ThumbnailTableViewCell: StoreSubscriber {
    
    internal struct SubscribeState {
        let thumbnailImage: UIImage?
        let currentPageIndex: Int
    }
    
    internal typealias StoreSubscriberStateType = SubscribeState
    
    internal func newState(state: StoreSubscriberStateType) {
        guard let index = self.index else { return }
        
        renderFrame(show: index == state.currentPageIndex)
        
        if thumbnail.image == nil,
            let image = state.thumbnailImage,
            let tableView = tableView {
            thumbnail.image = image
            indicator.removeFromSuperview()
            tableView.reloadRows(
                at: [IndexPath(row: index, section: 0)],
                with: .automatic)
        }
    }
}
