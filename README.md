# SlideViewer

iOS UI library for viewing slides inspired by SlideShare iOS App.

![screenshot](https://github.com/abeyuya/SlideViewer/blob/master/doc/slideviewer.gif)

- UI is very similar to SlideShare iOS App.
- Accept date sources:
  - array of image url
  - url of pdf file
  - bundle pdf file
- Corresponds to both portrait and landscape.

# Installation

## CocoaPods

- require swift4.2

```
  pod 'SlideViewer', git: 'https://github.com/abeyuya/SlideViewer'
```

# Getting Started

## with Array of image URL

```swift
let mainImageURLs = [0, 1, 2, 3, 4, 5].map { i -> URL in
    let str = [
        "https://speakerd.s3.amazonaws.com/presentations/50021f75cf1db900020005e7/",
        "preview_slide_\(i).jpg?1362165300"
        ].joined(separator: "")

    return URL(string: str)!
}

let thumbImageURLs = [0, 1, 2, 3, 4, 5].map { i -> URL in
    let str = [
        "https://speakerd.s3.amazonaws.com/presentations/50021f75cf1db900020005e7/",
        "thumb_slide_\(i).jpg?1362165300"
        ].joined(separator: "")

    return URL(string: str)!
}

let v = SlideViewerController.setup(mainImageURLs: mainImageURLs, thumbImageURLs: thumbImageURLs)
present(v, animated: true)
```

## with URL of PDF file

```swift
let pdfURL = "https://speakerd.s3.amazonaws.com/presentations/50021f75cf1db900020005e7/speakerdeck.pdf"
let v = SlideViewerController.setup(pdfFileURL: URL(string: pdfURL)!)
present(v, animated: true, completion: nil)
```

## with Bundle PDF file

```swift
let path = Bundle.main.path(forResource: "speakerdeck", ofType: "pdf")
let url = URL(fileURLWithPath: path!)
let doc = PDFDocument(url: url)
let v = SlideViewerController.setup(pdfDocument: doc!)
present(v, animated: true)
```

All of sample codes are here.
https://github.com/abeyuya/SlideViewer/blob/master/Example/PDFSlideView/ViewController.swift

