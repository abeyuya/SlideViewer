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
internal struct moveToSlide: Action { let pageIndex: Int? }
internal struct moveToThumbnail: Action { let pageIndex: Int? }

internal func slideViewerReducer(action: Action, state: SlideViewerState?) -> SlideViewerState {
    var state = state ?? SlideViewerState()

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
        if state.showThumbnail {
            state.moveToThumbnailIndex = state.currentPageIndex
        }
        
    case let action as changeIsPortrait:
        state.isPortrait = action.isPortrait
        
    case let action as setSlideDocument:
        state.slide.pdfDocument = action.doc
        state.slide.state = .complete
    
    case let action as setSlideInfo:
        state.slide.info = action.info
        
    case let action as setSlideState:
        state.slide.state = action.state
        
    case let action as moveToSlide:
        state.moveToSlideIndex = action.pageIndex
        
    case let action as moveToThumbnail:
        state.moveToThumbnailIndex = action.pageIndex
        
    default:
        break
    }
    
    return state
}

internal let mainStore = Store<SlideViewerState>(
    reducer: slideViewerReducer,
    state: nil
)
