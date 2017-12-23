//
//  ThumbnailTableViewCell.swift
//  PDFSlideView
//
//  Created by abeyuya on 2017/12/23.
//

import UIKit

final class ThumbnailTableViewCell: UITableViewCell {
    
    var thumbnail = UIImageView()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        addSubview(thumbnail)
        
        self.addConstraints([
            NSLayoutConstraint(
                item: thumbnail,
                attribute: .top,
                relatedBy: .equal,
                toItem: self,
                attribute: .top,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: thumbnail,
                attribute: .leading,
                relatedBy: .equal,
                toItem: self,
                attribute: .leading,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: thumbnail,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: self,
                attribute: .trailing,
                multiplier: 1,
                constant: 0),
            NSLayoutConstraint(
                item: thumbnail,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: self,
                attribute: .bottom,
                multiplier: 1,
                constant: 0),
            ])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
