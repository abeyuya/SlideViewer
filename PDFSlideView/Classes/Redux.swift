//
//  Redux.swift
//  PDFSlideView
//
//  Created by abeyuya on 2017/12/23.
//

import Foundation
import ReSwift

public struct PDFSlideViewState: StateType {
    var currentPageNo: Int = 1
    var isPortrait: Bool = true
    var showMenu: Bool = false
    var showThumbnail: Bool = false
}

struct changeCurrentPage: Action {
    let pageNo: Int
}
struct toggleMenu: Action {}
struct toggleThumbnail: Action {}
struct changeIsPortrait: Action {
    let isPortrait: Bool
}

func pdfSlideViewReducer(action: Action, state: PDFSlideViewState?) -> PDFSlideViewState {
    var state = state ?? PDFSlideViewState()
    
    switch action {
        
    case let action as changeCurrentPage:
        state.currentPageNo = action.pageNo
        
    case _ as toggleMenu:
        state.showMenu = !state.showMenu
        
    case _ as toggleThumbnail:
        state.showThumbnail = !state.showThumbnail
        
    case let action as changeIsPortrait:
        state.isPortrait = action.isPortrait
        
    default:
        break
    }
    
    return state
}
