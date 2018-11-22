//
//  MZPDFTrackControl.swift
//  PDFPrePractice
//
//  Created by mozhe on 2018/11/21.
//  Copyright © 2018 mozhe. All rights reserved.
//

import UIKit

class MZPDFTrackControl: UIControl {
    private(set) var value: CGFloat = 0.0
    
    //MARK: - Instance Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizesSubviews = false
        isUserInteractionEnabled = true
        contentMode = .redraw
        backgroundColor = .clear
        isExclusiveTouch = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func limitValue(_ valueX: CGFloat) -> CGFloat {
        var newValueX = valueX
        let minX = bounds.origin.x // 0.0 f
        let maxX = bounds.size.width - 1.0
        
        if (valueX < minX) {newValueX = minX } //Minimum X
        if (valueX > maxX) {newValueX = maxX} // Maxinum X
        
        return newValueX
    }
    
    //MARK: - Subclass methods
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let point = touch.location(in: self) // Touch point
        value = limitValue(point.x) // Limit control value
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        if isTouchInside {// Only if inside the control
            let point = touch.location(in: touch.view) // Touch point
            let x = limitValue(point.x) // Potential new control value
            if (x != value){ // Only if the new value has changed since the last time
                value = x
                sendActions(for: .valueChanged)
            }
        }
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if let point = touch?.location(in: self) {  // Touch point
            value = limitValue(point.x) // Limit control value
        }
    }
    
    
}
