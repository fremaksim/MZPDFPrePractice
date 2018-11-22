//
//  MZPDFThumbRequest.swift
//  PDFPrePractice
//
//  Created by mozhe on 2018/11/21.
//  Copyright © 2018 mozhe. All rights reserved.
//

import UIKit

class MZPDFThumbRequest: NSObject {
    
    private(set) var fileURL: URL!
    private(set) var guid: String!
    private(set) var cacheKey: String!
    private(set) var password: String?
    private(set) var thumbName: String
    var thumbView: MZPDFThumbView?
    private(set) var targetTag: Int = 0
    private(set) var thumbPage: Int
    private(set) var thumbSize: CGSize
    private(set) var scale: CGFloat =  UIScreen.main.scale
    
    static func newForView(_ view: MZPDFThumbView, fileURL: URL, password: String?, guid: String, page: Int, size: CGSize) -> MZPDFThumbRequest {
        return MZPDFThumbRequest.init(view: view, fileURL: fileURL, password: password, guid: guid, page: page, size: size)
    }
    
    init( view: MZPDFThumbView, fileURL: URL, password: String?, guid: String, page: Int, size: CGSize) {
        thumbView = view
        self.fileURL = fileURL
        self.password = password
        self.guid = guid
        self.thumbPage = page
        self.thumbSize = size
        
        let format = "%07i-%04i*%04i"
        
        thumbName = String(format: format, page,Int(size.width),Int(size.height))
        cacheKey =  thumbName + "+" + guid
        targetTag = view.targetTag
        
        super.init()
    }
    
    private func  initForView(_ view: MZPDFThumbView, fileURL: URL, password: String?, guid: String, page: Int, size: CGSize) -> MZPDFThumbRequest{
        
        return MZPDFThumbRequest(view: view, fileURL: fileURL, password: password, guid: guid, page: page, size: size)
    }
    
}
