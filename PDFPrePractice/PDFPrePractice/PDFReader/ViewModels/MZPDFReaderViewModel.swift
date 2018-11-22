//
//  MZPDFReaderViewModel.swift
//  PDFPrePractice
//
//  Created by mozhe on 2018/11/20.
//  Copyright © 2018 mozhe. All rights reserved.
//

import UIKit

final class MZPDFReaderViewModel {
    
    // MARK: - Inputs
    let document: MZPDFDocument
    
    var currentPageIndex: Int = 1 {
        didSet{
            document.currentPage = currentPageIndex
        }
    }
    
    var backgroundColor: UIColor = .lightGray
    
    var scrollDirection: UICollectionView.ScrollDirection = .horizontal
    
    // MARK: - Outputs
    
    
    init(document: MZPDFDocument) {
        self.document = document
    }
    
    
}


