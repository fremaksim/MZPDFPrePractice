//
//  MZPDFPageBarThumb.swift
//  PDFPrePractice
//
//  Created by mozhe on 2018/11/21.
//  Copyright © 2018 mozhe. All rights reserved.
//

import UIKit

class MZPDFPageBarThumb: MZPDFThumbView {
    
    init(frame: CGRect, isSmall: Bool) {
        super.init(frame: frame)
        let value: CGFloat = (isSmall ? 0.6 : 0.7)
        let background = UIColor.init(white: 0.8, alpha: value)
        backgroundColor = background
        imageView.backgroundColor = background
        imageView.layer.borderColor = UIColor.init(white: 0.4, alpha: 0.6).cgColor
        imageView.layer.borderWidth = 1.0
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
