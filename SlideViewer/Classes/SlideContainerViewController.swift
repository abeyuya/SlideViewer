//
//  SlideContainerViewController.swift
//  SlideViewer
//
//  Created by abeyuya on 2017/12/23.
//

import UIKit
import PDFKit
import ReSwift

final class SlideContainerViewController: UIPageViewController {
    
    private lazy var indicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .white)
        v.startAnimating()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var progress: UIProgressView = {
        let v = UIProgressView(progressViewStyle: .default)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var errorMessageLabel: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.numberOfLines = 0
        l.textAlignment = .center
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()


    internal override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        
        guard case .complete = mainStore.state.slide.state else {
            view.layoutCenter(subView: indicator)
            
            view.addSubview(progress)
            view.addConstraints([
                NSLayoutConstraint(
                    item: progress,
                    attribute: .top,
                    relatedBy: .equal,
                    toItem: indicator,
                    attribute: .bottom,
                    multiplier: 1,
                    constant: 20),
                NSLayoutConstraint.build(progress, attribute: .centerX, toItem: indicator),
                NSLayoutConstraint(
                    item: progress,
                    attribute: .width,
                    relatedBy: .equal,
                    toItem: nil,
                    attribute: .width,
                    multiplier: 1,
                    constant: 100),
                ])
            
            view.addSubview(errorMessageLabel)
            view.addConstraints([
                NSLayoutConstraint.build(errorMessageLabel, attribute: .centerY, toItem: view),
                NSLayoutConstraint(
                    item: errorMessageLabel,
                    attribute: .leading,
                    relatedBy: .equal,
                    toItem: view,
                    attribute: .leading,
                    multiplier: 1,
                    constant: 20),
                NSLayoutConstraint(
                    item: errorMessageLabel,
                    attribute: .trailing,
                    relatedBy: .equal,
                    toItem: view,
                    attribute: .trailing,
                    multiplier: 1,
                    constant: -20),
                ])
            return
        }
        
        let first = createSlideView(at: 0)
        setViewControllers([first], direction: .forward, animated: true, completion: nil)
    }
    
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainStore.subscribe(self) { subscription in
            subscription.select { state in
                SubscribeState(toIndex: state.moveToSlideIndex, slideState: state.slide.state)
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

extension SlideContainerViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    private func createSlideView(at index: Int) -> UIViewController {
        let v = SlideDisplayViewController(index: index)
        return v
    }
    
    internal func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let v = viewController as? SlideDisplayViewController else { return nil }
        guard v.index != 0 else { return nil }
        
        let index = v.index - 1
        return createSlideView(at: index)
    }
    
    internal func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let v = viewController as? SlideDisplayViewController,
            case .complete = mainStore.state.slide.state else { return nil }
        
        if let doc = mainStore.state.slide.pdfDocument {
            guard v.index < (doc.pageCount - 1) else { return nil }
            let index = v.index + 1
            return createSlideView(at: index)
        }
        
        if mainStore.state.slide.mainImageURLs.count > 0 {
            guard v.index < (mainStore.state.slide.mainImageURLs.count - 1) else { return nil }
            let index = v.index + 1
            return createSlideView(at: index)
        }
        
        return nil
    }
    
    internal func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let views = pageViewController.viewControllers,
            let current = views.first as? SlideDisplayViewController else { return }
        
        mainStore.dispatch(changeCurrentPage(pageIndex: current.index))
        mainStore.dispatch(moveToThumbnail(pageIndex: current.index))
    }
}

extension SlideContainerViewController: StoreSubscriber {
    
    internal struct SubscribeState {
        let toIndex: Int?
        let slideState: Slide.State
    }
    
    internal typealias StoreSubscriberStateType = SubscribeState
    
    internal func newState(state: StoreSubscriberStateType) {
        if viewControllers!.isEmpty {
            switch state.slideState {
            case .loading(let progress):
                self.progress.progress = progress
            case .failure(let error):
                renderErrorMessage(message: error.message)
            case .needPassword: break
            case .complete:
                let first = createSlideView(at: 0)
                setViewControllers([first], direction: .forward, animated: false, completion: nil)
                indicator.removeFromSuperview()
                progress.removeFromSuperview()
            }
        }
        
        if let toIndex = state.toIndex {
            move(toIndex: toIndex)
        }
    }
    
    private func move(toIndex: Int) {
        guard let currentView = viewControllers?.first as? SlideDisplayViewController else { return }
        guard toIndex != currentView.index else { return }
        let nextView = createSlideView(at: toIndex)

        if currentView.index < toIndex {
            self.setViewControllers([nextView], direction: .forward, animated: true, completion: nil)
        } else {
            self.setViewControllers([nextView], direction: .reverse, animated: true, completion: nil)
        }
        
        mainStore.dispatch(changeCurrentPage(pageIndex: toIndex))
        mainStore.dispatch(moveToSlide(pageIndex: nil))
    }
    
    private func renderErrorMessage(message: String) {
        if errorMessageLabel.isHidden {
            indicator.removeFromSuperview()
            progress.removeFromSuperview()
            errorMessageLabel.text = message
            errorMessageLabel.isHidden = false
            mainStore.dispatch(showMenu())
        }
    }
}
