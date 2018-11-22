//
//  MZPDFThumbFetch.swift
//  PDFPrePractice
//
//  Created by mozhe on 2018/11/21.
//  Copyright © 2018 mozhe. All rights reserved.
//

import UIKit
import ImageIO

class MZPDFThumbFetch: MZPDFThumbOperation {
    private let request: MZPDFThumbRequest
    
    init(request: MZPDFThumbRequest) {
        self.request = request
        super.init(guid: request.guid)
    }
    
    override func cancel() {
        super.cancel()
        
        request.thumbView?.operation = nil
        request.thumbView = nil
        
        MZPDFThumbCache.shared.removeNull(for: request.cacheKey as NSString)
    }
    
    func thumbFileURL() -> URL {
        let cachePath = MZPDFThumbCache.thumbCachePath(for: request.guid)
        let fileName = request.thumbName + ".png"
        return URL(fileURLWithPath: cachePath).appendingPathComponent(fileName)
    }
    
    override func main() {
        var imageRef: CGImage? = nil
        let thumbURL = thumbFileURL()
        let cfURL = thumbURL as CFURL
        if let loadRef = CGImageSourceCreateWithURL(cfURL, nil)  {
            imageRef = CGImageSourceCreateImageAtIndex(loadRef, 0,nil)
        }else {
            let thumbRender = MZPDFThumbRender(request: request)
            thumbRender.queuePriority = queuePriority
            
            if isCancelled == false {
                request.thumbView?.operation = thumbRender
                MZPDFThumbQueue.shared.addWorkOperation(operation: thumbRender)
                return
            }
        }
        if let imageRef = imageRef {
            let image = UIImage(cgImage: imageRef, scale: request.scale, orientation: UIImage.Orientation.up)
            image.draw(at: CGPoint.zero)
            
            let decodedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let decodedImage = decodedImage {
                MZPDFThumbCache.shared.setObject(image: decodedImage, key: request.cacheKey as NSString)
                if isCancelled == false {
                    let thumbView = request.thumbView
                    let targetTag = request.targetTag
                    
                    DispatchQueue.main.async {
                        if thumbView?.targetTag == targetTag {
                            thumbView?.showImage(decodedImage)
                        }
                    }
                }
            }else {
                assertionFailure("decodeImage failure")
            }
        }
        request.thumbView?.operation = nil // Break retain loop
    }
    
    
}
