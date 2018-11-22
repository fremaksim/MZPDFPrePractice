//
//  MZPDFThumbRender.swift
//  PDFPrePractice
//
//  Created by mozhe on 2018/11/21.
//  Copyright © 2018 mozhe. All rights reserved.
//

import UIKit
import ImageIO

class MZPDFThumbRender: MZPDFThumbOperation {
    
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
        let fm = FileManager()
        let cachePath = MZPDFThumbCache.thumbCachePath(for: request.guid)
//        do {
            try? fm.createDirectory(atPath: cachePath, withIntermediateDirectories: false, attributes: nil)
            let fileName = request.thumbName + ".png"
            return URL(fileURLWithPath: cachePath).appendingPathComponent(fileName)
//        } catch  {
//            assertionFailure(error.localizedDescription)
//        }

    }
    
    override func main() {
        let page = request.thumbPage
        let password = request.password
        
        var imageRef: CGImage? = nil
        guard let fileURL = request.fileURL else {
            assertionFailure("fileURL cannot nil")
            return
        }
        do {
            let thePDFDocRef = try CGPDFDocument.create(url: fileURL, password: password)
            if let thePDFPageRef = thePDFDocRef.page(at: page)  {
                let thumb_w = request.thumbSize.width
                let thumb_h = request.thumbSize.height
                let cropBoxRect = thePDFPageRef.getBoxRect(CGPDFBox.cropBox)
                let mediaBoxRect = thePDFPageRef.getBoxRect(CGPDFBox.mediaBox)
                let effectiveRect = cropBoxRect.intersection(mediaBoxRect)
                let pageRotate = thePDFPageRef.rotationAngle
                
                var page_w: CGFloat = 0.0
                var page_h: CGFloat = 0.0
                switch pageRotate {
                case 0, 180:
                    page_w = effectiveRect.width
                    page_h = effectiveRect.height
                case 90, 270:
                    page_h = effectiveRect.width
                    page_w = effectiveRect.height
                default:
                    break
                }
                let scale_w = thumb_w / page_w
                let scale_h = thumb_h / page_h
                var scale: CGFloat = 0.0
                
                if page_h > page_w {
                    scale = (thumb_h > thumb_w) ? scale_w : scale_h
                }else{
                    scale = (thumb_h < thumb_w) ? scale_h : scale_w
                }
                var target_w: Int = Int(page_w * scale)
                var target_h: Int = Int(page_h * scale)
                if (target_w % 2) != 0 {
                    target_w -= 1
                }
                if (target_h % 2) != 0 {
                    target_h -= 1
                }
                let mutable_w = CGFloat(target_w) * request.scale
                let mutable_h = CGFloat(target_h) * request.scale
                target_w = Int(mutable_w)
                target_h = Int(mutable_h)
                
//                let bmi = [CGBitmapInfo.byteOrder32Little]
                
                let rgb = CGColorSpaceCreateDeviceRGB()
                guard let bitmapContext = CGContext(data: nil,
                                                    width: target_w,
                                                    height: target_h,
                                                    bitsPerComponent: 8,
                                                    bytesPerRow: 0,
                                                    space: rgb,
                                                    bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
                                                        assertionFailure()
                                                        return
                }
                let thumbRect = CGRect(x: 0, y: 0, width: target_w, height: target_h)
                bitmapContext.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                bitmapContext.fill(thumbRect)
                let ctm = thePDFPageRef.getDrawingTransform(CGPDFBox.cropBox, rect: thumbRect, rotate: 0, preserveAspectRatio: true)
                bitmapContext.concatenate(ctm)
                bitmapContext.drawPDFPage(thePDFPageRef)
                
                imageRef = bitmapContext.makeImage()
                
                if let imageRef = imageRef {
                    let image = UIImage(cgImage: imageRef, scale: request.scale, orientation: UIImage.Orientation.up)
                    MZPDFThumbCache.shared.setObject(image: image, key: request.cacheKey as String as NSString)
                    if isCancelled == false {
                        if let thumbView = request.thumbView {
                            let targetTag = request.targetTag
                            DispatchQueue.main.async {
                                if thumbView.targetTag == targetTag {
                                    thumbView.showImage(image)
                                }
                            }
                        }
                    }
                    let thumbURL = thumbFileURL() as CFURL
                    let cfName = "public.png" as CFString
                    let thumbRef = CGImageDestinationCreateWithURL(thumbURL, cfName, 1,nil)
                    
                    if let thumbRef = thumbRef {
                        CGImageDestinationAddImage(thumbRef, imageRef, nil)
                        CGImageDestinationFinalize(thumbRef)
                    }
                    
                }else {
                    
                }
            
                
            }else {
                
            }
            
        } catch  {
            MZPDFThumbCache.shared.removeNull(for: request.cacheKey as NSString)
            assertionFailure(error.localizedDescription)
        }
        request.thumbView?.operation = nil 
    }
    
    
}
