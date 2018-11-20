//
//  MZPDFPageCache.swift
//  PDFPrePractice
//
//  Created by mozhe on 2018/11/20.
//  Copyright © 2018 mozhe. All rights reserved.
//

import Foundation
import UIKit

final class MZPDFPageCache {
    
    static let shared = MZPDFPageCache()
    
    static var cachesPath: String {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    }

    private(set) var documentCache: NSCache<NSString, MZPDFDocument> = NSCache()
    
    private(set) var imagesCache: NSCache<NSNumber, UIImage> = NSCache()
    
    

}
