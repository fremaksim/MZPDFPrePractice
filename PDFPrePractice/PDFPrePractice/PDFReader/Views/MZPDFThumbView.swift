//
//  MZPDFThumbView.swift
//  PDFPrePractice
//
//  Created by mozhe on 2018/11/21.
//  Copyright © 2018 mozhe. All rights reserved.
//

import UIKit

class MZPDFThumbView: UIView {
    
    private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: bounds)
        imageView.autoresizesSubviews = false
        imageView.isUserInteractionEnabled = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var operation: Operation?
    var targetTag: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        autoresizesSubviews = false
        isUserInteractionEnabled = false
        contentMode = .redraw
        backgroundColor = .clear
        
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showImage(_ image: UIImage)  {
        imageView.image = image
    }
    
    func showTouched(_ touched: Bool) {
        // Implemented by subclass
    }
    
    override func removeFromSuperview() {
        targetTag = 0
        operation?.cancel()
        super.removeFromSuperview()
    }
    
    func reuse() {
        targetTag = 0
        operation?.cancel()
        imageView.image = nil
    }
    
    
}
