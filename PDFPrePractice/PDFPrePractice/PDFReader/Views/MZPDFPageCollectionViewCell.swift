//
//  MZPDFPageCollectionViewCell.swift
//  PDFPrePractice
//
//  Created by mozhe on 2018/11/20.
//  Copyright © 2018 mozhe. All rights reserved.
//
//  Inspired by https://github.com/Alua-Kinzhebayeva/iOS-PDF-Reader

import UIKit

//class MZPDFPageCollectionViewCell: UICollectionViewCell {
//
//}
/// Delegate that is informed of important interaction events with the pdf page collection view
protocol MZPDFPageCollectionViewCellDelegate: class {
    func handleSingleTap(_ cell: MZPDFPageCollectionViewCell, pdfPageView: MZPDFPageView)
}

/// A cell housing the interactable pdf page view
internal final class MZPDFPageCollectionViewCell: UICollectionViewCell {
    /// Index of the page
    var pageIndex: Int?
    
    /// Page view of the current page in the document
    var pageView: MZPDFPageView? {
        didSet {
            subviews.forEach{ $0.removeFromSuperview() }
            if let pageView = pageView {
                addSubview(pageView)
            }
        }
    }
    
    /// Delegate informed of important events
    private weak var pageCollectionViewCellDelegate: MZPDFPageCollectionViewCellDelegate?
    
    
    /// Customizes and sets up the cell to be ready to be displayed
    ///
    /// - parameter indexPathRow:                   page index of the document to be displayed
    /// - parameter collectionViewBounds:           bounds of the entire collection view
    /// - parameter document:                       document to be displayed
    /// - parameter pageCollectionViewCellDelegate: delegate informed of important events
    func setup(_ indexPathRow: Int, collectionViewBounds: CGRect, document: MZPDFDocument, pageCollectionViewCellDelegate: MZPDFPageCollectionViewCellDelegate?) {
        self.pageCollectionViewCellDelegate = pageCollectionViewCellDelegate
        document.pdfPageImage(at: indexPathRow + 1) { (backgroundImage) in
            pageView = MZPDFPageView(frame: bounds, document: document, pageNumber: indexPathRow, backgroundImage: backgroundImage, pageViewDelegate: self)
            pageIndex = indexPathRow
        }
    }
}

extension MZPDFPageCollectionViewCell: MZPDFPageViewDelegate {
    func handleSingleTap(_ pdfPageView: MZPDFPageView) {
        pageCollectionViewCellDelegate?.handleSingleTap(self, pdfPageView: pdfPageView)
    }
}
