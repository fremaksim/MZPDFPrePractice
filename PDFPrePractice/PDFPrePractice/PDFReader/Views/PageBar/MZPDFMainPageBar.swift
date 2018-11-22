//
//  MZPDFMainPageBar.swift
//  PDFPrePractice
//
//  Created by mozhe on 2018/11/20.
//  Copyright © 2018 mozhe. All rights reserved.
//

import UIKit
//  Inspired by https://github.com/vfr/Reader

protocol MZPDFMainPageBarDelegate: class {
    func gotoPage(_ page: Int, at pageBar: MZPDFMainPageBar)
}
//MARK: - Constants
fileprivate let thumbSmallGap: CGFloat = 2
fileprivate let thumbSmallWidth: CGFloat = 22
fileprivate let thumbSmallHeight: CGFloat = 28

fileprivate let thumbLargeWidth: CGFloat = 32
fileprivate let thumbLargeHeight: CGFloat = 42

fileprivate let pageNumberWidth: CGFloat = 96
fileprivate let pageNumberHeight: CGFloat = 30

fileprivate let pageNumberSpaceLarge: CGFloat = 32
fileprivate let pageNumberSpaceSmall: CGFloat = 16

fileprivate let shadowHeight: CGFloat = 4

final class MZPDFMainPageBar: UIView {
    
    weak var delegate: MZPDFMainPageBarDelegate?
    var document: MZPDFDocument
    
    fileprivate var miniThumbViews = [Int: MZPDFPageBarThumb]()
    
    fileprivate var enableTimer: Timer?
    fileprivate var trackTimer: Timer?
    fileprivate var pageThumbView: MZPDFPageBarThumb?
    
    fileprivate lazy var lineView: UIView = {
        var lineRect = bounds
        lineRect.size.height = 1
        lineRect.origin.y -= lineRect.size.height
        let lineView = UIView(frame: lineRect)
        lineView.autoresizesSubviews = false
        lineView.isUserInteractionEnabled = false
        lineView.contentMode = .redraw
        lineView.backgroundColor = UIColor.init(white: 0.64, alpha: 0.94)
        return lineView
    }()
    
    /// Page numbers view
    fileprivate lazy var pageNumberView: UIView = {
        let space = (UIDevice.current.userInterfaceIdiom == .pad) ? pageNumberSpaceLarge : pageNumberSpaceSmall
        let numberY = (0.0 - (pageNumberHeight + space))
        let numberX = (bounds.size.width - pageNumberWidth) * 0.5
        let numberRect = CGRect(x: numberX, y: numberY, width: pageNumberWidth, height: pageNumberHeight)
        let pageNumberView = UIView(frame: numberRect)
        pageNumberView.autoresizesSubviews = false
        pageNumberView.isUserInteractionEnabled = false
        pageNumberView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        pageNumberView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.4)
        pageNumberView.layer.shadowOffset = CGSize.zero
        pageNumberView.layer.shadowColor  = UIColor.init(white: 0.0, alpha: 0.6).cgColor
        pageNumberView.layer.shadowPath = UIBezierPath(rect: pageNumberView.bounds).cgPath
        pageNumberView.layer.shadowRadius = 2.0
        pageNumberView.layer.shadowOpacity = 1.0
        
        return pageNumberView
    }()
    
    
    fileprivate lazy var pageNumberLabel: UILabel = {
        let textRect = pageNumberView.bounds.insetBy(dx: 4.0, dy: 2.0)
        let pageNumberLabel = UILabel(frame: textRect)
        pageNumberLabel.autoresizesSubviews = false
        //        pageNumberLabel.autoresizingMask = .none //default
        pageNumberLabel.textAlignment = .center
        pageNumberLabel.backgroundColor = .white
        pageNumberLabel.font = UIFont.systemFont(ofSize: 16)
        pageNumberLabel.shadowOffset = CGSize(width: 0, height: 1)
        pageNumberLabel.shadowColor = .black
        pageNumberLabel.adjustsFontSizeToFitWidth = true
        pageNumberLabel.minimumScaleFactor = 0.75
        return pageNumberLabel
    }()
    
    fileprivate lazy var trackControl: MZPDFTrackControl = {
        let trackControl = MZPDFTrackControl(frame: bounds)
        trackControl.addTarget(self, action: #selector(MZPDFMainPageBar.trackViewTouchDown(trackView:)), for: .touchDown)
        trackControl.addTarget(self, action: #selector(MZPDFMainPageBar.trackViewValueChange(trackView:)), for: .valueChanged)
        trackControl.addTarget(self, action: #selector(MZPDFMainPageBar.trackViewTouchUp(trackView:)), for: .touchUpInside)
        trackControl.addTarget(self, action: #selector(MZPDFMainPageBar.trackViewTouchUp(trackView:)), for: .touchUpOutside)
        return trackControl
    }()
    
    init(frame: CGRect, document: MZPDFDocument) {
        self.document = document
        super.init(frame: frame)
        
        autoresizesSubviews = true
        isUserInteractionEnabled = true
        contentMode = .redraw
        autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        
        // no shawdow
        backgroundColor = UIColor.init(white: 0.94, alpha: 0.94)
        
        addSubview(lineView)
        
        pageNumberView.addSubview(pageNumberLabel)
        addSubview(pageNumberView)
        
        addSubview(trackControl)
        
        updatePageNumberText(document.currentPage)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func removeFromSuperview() {
        enableTimer?.invalidate()
        enableTimer = nil
        
        trackTimer?.invalidate()
        trackTimer = nil
        
        super.removeFromSuperview()
    }
    
    override func layoutSubviews() {
        var controlRect = bounds.insetBy(dx: 4.0, dy: 0.0)
        let thumbWidth = thumbSmallWidth + thumbSmallGap
        //TODO: - Int Convert
        var thumbs = Int(controlRect.width / thumbWidth)
        let pages = document.pageCount
        if thumbs > pages {
            thumbs = pages
        }
        let controlWidth = CGFloat(thumbs) * thumbWidth - thumbSmallGap
        controlRect.size.width = controlWidth
        let widthDelta = bounds.width - controlWidth
        
        let X: Int = Int(widthDelta * 0.5)
        controlRect.origin.x = CGFloat(X)
        trackControl.frame = controlRect
        
        if pageThumbView == nil {
            let heightDelta = controlRect.height - thumbLargeHeight
            let thumbY: Int = Int(heightDelta * 0.5)
            let thumbX: Int = 0
            let thumbRect = CGRect(x: CGFloat(thumbX) , y: CGFloat(thumbY), width: thumbLargeWidth, height: thumbLargeHeight)
            pageThumbView = MZPDFPageBarThumb(frame: thumbRect, isSmall: false) // Create the thumb view
            pageThumbView?.layer.zPosition = 1.0 // Z position so that it sits on top of the small thumbs
            trackControl.addSubview(pageThumbView!) // Add as the first subview of the track control
        }
        updatePageThumbView(page: document.currentPage)
        var strideThumbs = thumbs - 1
        if strideThumbs < 1 {
            strideThumbs = 1
        }
        
        let stride = CGFloat(pages) / CGFloat(strideThumbs)
        let heightDelta = controlRect.size.height - thumbSmallHeight
        let thumbY = heightDelta / 2.0
        let thumbX: CGFloat = 0.0
        var thumbRect = CGRect(x: thumbX, y: thumbY, width: thumbSmallWidth, height: thumbSmallHeight)
        
        var thumbsToHide = miniThumbViews
        
        for thumb in 0..<thumbs {
            
            var page = Int(stride * CGFloat(thumb) + 1)
            if page > pages {
                page = pages
            }
            
            if let smallThumbView = miniThumbViews[page] {
                smallThumbView.isHidden = false
                thumbsToHide.removeValue(forKey: page)
                
                if !smallThumbView.frame.equalTo(thumbRect) {
                    smallThumbView.frame = thumbRect
                }
            } else {
                let size = CGSize(width: thumbSmallWidth, height: thumbSmallHeight)
                let fileURL = document.fileUrl
                let guid    = document.guid
                let password = document.password
                
                let smallThumbView = MZPDFPageBarThumb(frame: thumbRect,
                                                       isSmall: true)
                
                let request = MZPDFThumbRequest(view: smallThumbView, fileURL: fileURL!, password: password, guid: guid, page: page, size: size)
                if let image = MZPDFThumbCache.shared.thumbRequest(request, priority: false) as? UIImage {
                    smallThumbView.showImage(image)
                }
                
                trackControl.addSubview(smallThumbView)
                miniThumbViews[page] = smallThumbView
                
            }
            
            thumbRect.origin.x += thumbWidth
        }
        
        for thumb in thumbsToHide.values {
            thumb.isHidden = true
        }
        
    }
    
    func updatePageBarViews() {
        let page = document.currentPage
        updatePageNumberText(page)
        updatePageThumbView(page: page)
    }
    
    func updatePageBar() {
        if isHidden == false {
            updatePageBarViews()
        }
    }
    func hidePageBar()  {
        if isHidden == false {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.curveLinear, .allowUserInteraction], animations: {
                self.alpha = 0.0
            }) { (_) in
                self.isHidden = true
            }
        }
    }
    func showPageBar()  {
        if isHidden == true {
            updatePageBarViews()
            
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.curveLinear, .allowUserInteraction], animations: {
                self.isHidden = false
                self.alpha    = 1.0
            }, completion: nil)
        }
    }
}

//MARK: - MainPageBar Instance Methods
fileprivate extension MZPDFMainPageBar {
    func updatePageNumberText(_ page: Int)  {
        if (page != pageNumberLabel.tag) { // Only if page number changed
            let pages = document.pageCount
            let format = NSLocalizedString("%i of %i", comment: "format")
            let number = String.init(format: format, page,pages)
            pageNumberLabel.text = number
            pageNumberLabel.tag = tag  // Update the last page number tag
        }
    }
    
    func updatePageThumbView(page: Int) {
        let pages = document.pageCount
        
        if pages > 1 {
            let controlWidth = trackControl.bounds.size.width
            let useableWidth = controlWidth - thumbLargeWidth
            
            let stride = useableWidth / CGFloat(pages - 1)
            //            let x = Int(stride) * (page - 1)
            
            let floatX = stride * CGFloat(page - 1)
            let intX = Int(floatX)
            
            
            let pageThumbX = CGFloat(intX)
            guard let pageThumbView = pageThumbView else {
                return
            }
            var pageThumbRect = pageThumbView.frame
            
            if pageThumbX != pageThumbRect.origin.x {
                pageThumbRect.origin.x = pageThumbX
                pageThumbView.frame = pageThumbRect
            }
        }
        
        guard let pageThumbView = pageThumbView  else {
            return
        }
        
        if page != pageThumbView.tag {
            
            pageThumbView.tag = page
            pageThumbView.reuse()
            let size = CGSize(width: thumbLargeWidth, height: thumbLargeHeight)
            let fileURL = document.fileUrl
            let guid    = document.guid
            let phrase  = document.password
            
            let request = MZPDFThumbRequest.newForView(pageThumbView, fileURL: fileURL!, password: phrase, guid: guid, page: page, size: size)
            if  let image =  MZPDFThumbCache.shared.thumbRequest(request, priority: true) as? UIImage {
                pageThumbView.showImage(image)
            }
        }
    }
    
    
    
}

//MARK: - TrackControl action methos
fileprivate extension MZPDFMainPageBar {
    
    @objc  func trackTimerFired(_ timer: Timer) {
        trackTimer?.invalidate()
        trackTimer = nil
        
        if trackControl.tag != document.currentPage { // Only if different
            delegate?.gotoPage(trackControl.tag, at: self) //Go to document page
        }
    }
    
    @objc func enableTimerFired(_ timer: Timer) {
        enableTimer?.invalidate()
        enableTimer = nil
        
        trackControl.isUserInteractionEnabled  = true // Enable track Control interaction
    }
    
    func restartTrackTimer()  {
        if trackTimer != nil {
            trackTimer?.invalidate()
            trackTimer = nil
        }
        trackTimer = Timer(timeInterval: 0.25, target: self, selector: #selector(MZPDFMainPageBar.trackTimerFired(_:)), userInfo: nil, repeats: false)
    }
    
    func startEnableTimer()  {
        if enableTimer != nil {
            enableTimer?.invalidate()
            enableTimer = nil
        }
        
        enableTimer = Timer(timeInterval: 0.25, target: self, selector: #selector(MZPDFMainPageBar.enableTimerFired(_:)), userInfo: nil, repeats: false)
    }
    
    
    func trackViewPageNumber(trackView: MZPDFTrackControl) -> Int {
        let controlWidth = trackView.bounds.width
        let stride = controlWidth / CGFloat(document.pageCount)
        let page = Int(trackView.value / stride) //Integer page number
        return (page + 1) // + 1
    }
    
    @objc  func trackViewTouchDown(trackView: MZPDFTrackControl) {
        let page = trackViewPageNumber(trackView: trackView)
        if page != document.currentPage { // Only if different
            updatePageNumberText(page)
            updatePageThumbView(page: page)
            restartTrackTimer()
        }
        
        trackView.tag = page // Start page tracking
    }
    
    @objc  func trackViewValueChange(trackView: MZPDFTrackControl) {
        let page = trackViewPageNumber(trackView: trackView)
        if page != trackView.tag {
            updatePageNumberText(page)
            updatePageThumbView(page: page)
            
            trackView.tag = page
            
            restartTrackTimer()
        }
    }
    
    @objc  func trackViewTouchUp(trackView: MZPDFTrackControl) {
        if trackTimer != nil {
            trackTimer?.invalidate()
            trackTimer = nil
        }
        
        if trackView.tag != document.currentPage {
            trackView.isUserInteractionEnabled = false
            delegate?.gotoPage(trackView.tag, at: self)
            startEnableTimer()
        }
        trackView.tag = 0 // Reset page tracking
        
    }
    
    
}


