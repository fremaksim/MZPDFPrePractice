//
//  MZPDFThumbCache.swift
//  PDFPrePractice
//
//  Created by mozhe on 2018/11/21.
//  Copyright © 2018 mozhe. All rights reserved.
//

import UIKit

fileprivate let cacheSize = 2097152 // 2*1024*1024

class MZPDFThumbCache: NSObject {
    //TODO: - lock
    let lock = NSLock()
    
    static let shared = MZPDFThumbCache()
    
    private var thumbCache = NSCache<NSString ,AnyObject>()
    
    static func appCachePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        return paths.first!
    }
    
    static func thumbCachePath(for guid: String) -> String {
        let cachePath = appCachePath()
        let cacheURL = URL(fileURLWithPath: cachePath)
        return cacheURL.appendingPathComponent(guid).path
    }
    static func touchThumbCache(with guid: String) {
        let fm = FileManager()
        let cachePath = MZPDFThumbCache.thumbCachePath(for: guid)
        let attributes = [FileAttributeKey.modificationDate : Date()]
        do {
            try fm.setAttributes(attributes, ofItemAtPath: cachePath)
        } catch  {
            LogManager.shared.log.error(error.localizedDescription)
        }
    }
    
    func setObject(image: UIImage ,key: NSString) {
        lock.lock()
        let bytes = Int(image.size.width * image.size.height * 4.0)
        thumbCache.setObject(image, forKey: key, cost: bytes)
        lock.unlock()
    }
    
    
    func thumbRequest(_ request: MZPDFThumbRequest, priority: Bool) -> AnyObject {
        lock.lock()
        if let object = thumbCache.object(forKey: request.cacheKey as NSString) {
            lock.unlock()
            return object
        }else{
            let emptyObject = NSNull()
            thumbCache.setObject(emptyObject, forKey: request.cacheKey as NSString)
            let thumbFetch = MZPDFThumbFetch(request: request)
            thumbFetch.queuePriority = priority ? .normal : .low
            request.thumbView?.operation = thumbFetch
            MZPDFThumbQueue.shared.addLoadOperation(operation: thumbFetch)
            lock.unlock()
            return emptyObject
        }
        
    }
    
    func removeNull(for key: NSString)  {
        lock.lock()
        let object = thumbCache.object(forKey: key)
        if object is NSNull {
            thumbCache.removeObject(forKey: key)
        }
        lock.unlock()
    }
    
    func removeAllObjects()  {
        lock.lock()
        thumbCache.removeAllObjects()
        lock.unlock()
    }
    
    
}
