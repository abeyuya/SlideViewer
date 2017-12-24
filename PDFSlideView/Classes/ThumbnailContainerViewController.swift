//
//  ThumbnailContainerViewController.swift
//  PDFSlideView
//
//  Created by abeyuya on 2017/12/24.
//

import UIKit
import PDFKit

final class ThumbnailContainerViewController: UIViewController {
    
//    private lazy var thumbnailImages: [UIImage?] = {
//        return Array(repeating: nil, count: slide.images.count)
//    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(ThumbnailTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()

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
        
        if let thumbnailImage = mainStore.state.slide.thumbnailImages[indexPath.row] {
            cell.thumbnail.image = thumbnailImage
        } else {
//            let thumbnailImage = createThumbnailImage(at: indexPath.row)
//            cell.thumbnail.image = thumbnailImage
//            mainStore.state.slide.thumbnailImages.insert(thumbnailImage, at: indexPath.row)
        }

        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mainStore.dispatch(changeCurrentPage(pageIndex: indexPath.row))
    }
}

extension ThumbnailContainerViewController {
    
//    private func createThumbnailImage(at index: Int) -> UIImage? {
//        guard let originalImage = slide.images[index] else { return nil }
//        let thumbnailHeight = originalImage.size.height * (Config.shared.thumbnailViewWidth / originalImage.size.width)
//        return originalImage.resize(size: CGSize(width: Config.shared.thumbnailViewWidth, height: thumbnailHeight))
//    }
}

extension UIImage {
    func resize(size _size: CGSize) -> UIImage? {
        let widthRatio = _size.width / size.width
        let heightRatio = _size.height / size.height
        let ratio = widthRatio < heightRatio ? widthRatio : heightRatio
        
        let resizedSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}
