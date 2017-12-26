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
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        
        let first = createSlideView(at: 0)
        setViewControllers([first], direction: .forward, animated: true, completion: nil)
    }
    
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainStore.subscribe(self) { subscription in
            subscription.select { state in state.moveToSlideIndex }
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
        let v = SlideDisplayViewController()
        v.index = index
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
        guard v.index < (mainStore.state.slide.images.count - 1) else { return nil }
        
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
    
    internal typealias StoreSubscriberStateType = Int?
    
    internal func newState(state toIndex: StoreSubscriberStateType) {
        guard let toIndex = toIndex else { return }
        move(toIndex: toIndex)
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
