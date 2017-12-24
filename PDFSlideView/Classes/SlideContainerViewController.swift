//
//  SlideContainerViewController.swift
//  PDFSlideView
//
//  Created by abeyuya on 2017/12/23.
//

import UIKit
import PDFKit
import ReSwift

final class SlideContainerViewController: UIPageViewController {
    
    var slide: Slide = Slide(images: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        
        let first = createSlideView(at: 0)
        setViewControllers([first], direction: .forward, animated: true, completion: nil)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainStore.subscribe(self)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SlideContainerViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    private func createSlideView(at index: Int) -> UIViewController {
        let v = SlideDisplayViewController()
        v.index = index
        v.image = slide.images[index]
        return v
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let v = viewController as? SlideDisplayViewController else { return nil }
        guard v.index != 0 else { return nil }
        
        let index = v.index - 1
        return createSlideView(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let v = viewController as? SlideDisplayViewController else { return nil }
        guard v.index < (slide.images.count - 1) else { return nil }
        
        let index = v.index + 1
        return createSlideView(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let views = pageViewController.viewControllers,
            let current = views.first as? SlideDisplayViewController else { return }
        mainStore.dispatch(changeCurrentPage(pageIndex: current.index))
    }
}

extension SlideContainerViewController: StoreSubscriber {
    
    public typealias StoreSubscriberStateType = PDFSlideViewState
    
    public func newState(state: PDFSlideViewController.StoreSubscriberStateType) {
        move(toIndex: state.currentPageIndex)
    }
    
    private func move(toIndex: Int) {
        guard let currentView = viewControllers?.first as? SlideDisplayViewController else { return }
        guard toIndex != currentView.index else { return }
        
        let nextView = createSlideView(at: toIndex)

        DispatchQueue.main.async {
            if currentView.index < toIndex {
                self.setViewControllers([nextView], direction: .forward, animated: true, completion: nil)
            } else {
                self.setViewControllers([nextView], direction: .reverse, animated: true, completion: nil)
            }
        }
    }
}
