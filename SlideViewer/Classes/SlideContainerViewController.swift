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
        let v = UIActivityIndicatorView(activityIndicatorStyle: .white)
        v.startAnimating()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        
        guard case .complete(_) = mainStore.state.slide else {
            view.layoutCenter(subView: indicator)
            return
        }
        
        let first = createSlideView(at: 0)
        setViewControllers([first], direction: .forward, animated: true, completion: nil)
    }
    
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainStore.subscribe(self) { subscription in
            subscription.select { state in
                SubscribeState(toIndex: state.moveToSlideIndex, slide: state.slide)
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
        guard let v = viewController as? SlideDisplayViewController else { return nil }
        guard case .complete(let slide) = mainStore.state.slide else { return nil }
        guard v.index < (slide.images.count - 1) else { return nil }
        
        let index = v.index + 1
        return createSlideView(at: index)
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
        let slide: Slide.State
    }
    
    internal typealias StoreSubscriberStateType = SubscribeState
    
    internal func newState(state: StoreSubscriberStateType) {
        if viewControllers!.isEmpty, case .complete(_) = state.slide {
            let first = createSlideView(at: 0)
            setViewControllers([first], direction: .forward, animated: false, completion: nil)
            indicator.removeFromSuperview()
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
}
