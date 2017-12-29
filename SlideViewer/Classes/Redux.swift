//
//  Redux.swift
//  SlideViewer
//
//  Created by abeyuya on 2017/12/23.
//

import Foundation
import PDFKit
import ReSwift

public struct SlideViewerState: StateType {
    var currentPageIndex: Int = 0
    var isPortrait: Bool = true
    var showMenu: Bool = false
    var showThumbnail: Bool = false
    var slide: Slide = Slide()
    var moveToSlideIndex: Int? = nil
    var moveToThumbnailIndex: Int? = nil
    var thumbnailHeight: CGFloat? = nil
}

internal struct stateReset: Action {}
internal struct changeCurrentPage: Action { let pageIndex: Int }
internal struct toggleMenu: Action {}
internal struct hideMenu: Action {}
internal struct showMenu: Action {}
internal struct toggleThumbnail: Action {}
internal struct changeIsPortrait: Action { let isPortrait: Bool }
internal struct setSlideDocument: Action { let doc: PDFDocument }
internal struct setSlideInfo: Action { let info: Slide.Info }
internal struct setSlideState: Action { let state: Slide.State }
internal struct setImage: Action {
    let pageIndex: Int
    let originalImage: UIImage
    let thumbnailImage: UIImage?
}
internal struct moveToSlide: Action { let pageIndex: Int? }
internal struct moveToThumbnail: Action { let pageIndex: Int? }
internal struct setThumbnailHeight: Action { let height: CGFloat }

internal func slideViewerReducer(action: Action, state: SlideViewerState?) -> SlideViewerState {
    var state = state ?? SlideViewerState()
    print(state)
    print("--------------------------\n")
    
    switch action {
        
    case _ as stateReset:
        state = SlideViewerState()
        
    case let action as changeCurrentPage:
        state.currentPageIndex = action.pageIndex
        
    case _ as toggleMenu:
        state.showMenu = !state.showMenu
        
    case _ as hideMenu:
        state.showMenu = false
        
    case _ as showMenu:
        state.showMenu = true
        
    case _ as toggleThumbnail:
        state.showThumbnail = !state.showThumbnail
        
    case let action as changeIsPortrait:
        state.isPortrait = action.isPortrait
        
    case let action as setSlideDocument:
        state.slide.pdfDocument = action.doc
        state.slide.images = Array(repeating: nil, count: action.doc.pageCount)
        state.slide.thumbnailImages = Array(repeating: nil, count: action.doc.pageCount)
        
    case let action as setSlideInfo:
        state.slide.info = action.info
        
    case let action as setSlideState:
        state.slide.state = action.state
        
    case let action as setImage:
//        switch state.slide.state {
//        case .loading, .failure(_): break
//        case .complete:
//            state.slide.images[action.pageIndex] = action.originalImage
//            state.slide.thumbnailImages[action.pageIndex] = action.thumbnailImage
//            state.slide.state = .complete
//        }
        state.slide.images[action.pageIndex] = action.originalImage
        state.slide.thumbnailImages[action.pageIndex] = action.thumbnailImage
        state.slide.state = .complete

    case let action as moveToSlide:
        state.moveToSlideIndex = action.pageIndex
        
    case let action as moveToThumbnail:
        state.moveToThumbnailIndex = action.pageIndex
        
    case let action as setThumbnailHeight:
        state.thumbnailHeight = action.height
        
    default:
        break
    }
    
    return state
}

internal func loadImage(state: SlideViewerState, index: Int) {
//    guard case .complete(let slide) = state.slide.state else { return }
    guard index < state.slide.images.count, state.slide.images[index] == nil else { return }
    
    DispatchQueue.global(qos: .default).async {
        guard let image = loadImageFrom(state: state, index: index) else { return }
        
        let thumbnailImage = createThumbnailImage(originalImage: image)
        let thumbnailHeight = thumbnailImage?.size.height
        
        DispatchQueue.main.async {
            if state.thumbnailHeight == nil, let height = thumbnailHeight {
                mainStore.dispatch(setThumbnailHeight(height: height))
            }
            mainStore.dispatch(setImage(
                pageIndex: index,
                originalImage: image,
                thumbnailImage: thumbnailImage
            ))
        }
    }
}

//internal func fetchSlide(pdfFileURL: URL) {
//    Slide.fetch(pdfFileURL: pdfFileURL) { result in
//        DispatchQueue.main.async {
//            switch result {
//            case .loading(let progress):
//                mainStore.dispatch(setSlideState(state: .loading(progress: progress)))
//            case .failure(let error):
//                mainStore.dispatch(setSlideState(state: .failure(error: error)))
//            case .complete(let doc):
//                mainStore.dispatch(setSlideState(state: .complete)
//            }
//        }
//    }
//}

private func loadImageFrom(state: SlideViewerState, index: Int) -> UIImage? {
    
//    guard case .complete(let slide) = state.slide else { return nil }
    guard let doc = state.slide.pdfDocument else { return nil }
    return loadImageFrom(pdfDocument: doc, index: index)
}

private func loadImageFrom(pdfDocument: PDFDocument, index: Int) -> UIImage? {
    guard let page = pdfDocument.page(at: index),
        let pageRef = page.pageRef else { return nil }

    let pageRect = page.bounds(for: .mediaBox)
    let renderer = UIGraphicsImageRenderer(size: pageRect.size)
    let image = renderer.image { ctx in
        UIColor.white.set()
        ctx.fill(pageRect)
        
        ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
        ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
        
        ctx.cgContext.drawPDFPage(pageRef)
    }
    return image
}

private func createThumbnailImage(originalImage: UIImage) -> UIImage? {
    let thumbnailHeight = originalImage.size.height * (Config.shared.thumbnailViewWidth / originalImage.size.width)
    return originalImage.resize(size: CGSize(width: Config.shared.thumbnailViewWidth, height: thumbnailHeight))
}

internal let mainStore = Store<SlideViewerState>(
    reducer: slideViewerReducer,
    state: nil
)
