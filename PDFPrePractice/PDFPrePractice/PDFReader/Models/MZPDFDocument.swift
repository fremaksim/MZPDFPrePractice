//
//  MZPDFDocument.swift
//  PDFPrePractice
//
//  Created by mozhe on 2018/11/2.
//  Copyright © 2018 mozhe. All rights reserved.
//

import Foundation
import UIKit


open class MZPDFDocument: Codable {
    
    open var documentRef: CGPDFDocument?
    
    /// Document Properties
    open var password: String?
    open var lastOpen: Date?
    open var pageCount: Int = 0
    
    open var currentPage: Int = 1
    open var bookmarks: IndexSet = IndexSet()
    open var fileUrl: URL?
    open var fileData: Data?
    open var fileSize: Int = 0
    open var guid: String
    
    /// File Properties
    open var title: String?
    open var author: String?
    open var subject: String?
    open var keywords: String?
    open var creator: String?
    open var producer: String?
    open var modificationDate: Date?
    open var creationDate: Date?
    open var version: Float = 0.0
    
    /// Document annotations
    open var annotations: MZPDFAnnotationStore = MZPDFAnnotationStore()
    
    /// Image cache with the page index and and image of the page
    let images = NSCache<NSNumber, UIImage>()
    
    func loadDocument() throws {
        if let fileURL = self.fileUrl {
            self.documentRef = try CGPDFDocument.create(url: fileURL, password: self.password)
        }else if let fileData = self.fileData {
            self.documentRef = try CGPDFDocument.create(data: fileData as NSData, password: self.password)
        }
        if documentRef == nil {
            throw CGPDFDocumentError.unableToOpen
        }
        self.loadDocumentInformation()
    }
    
    func loadDocumentInformation() {
        guard let pdfDocRef = documentRef else {
            return
        }
        
        let infoDic: CGPDFDictionaryRef = pdfDocRef.info!
        var string: CGPDFStringRef? = nil
        
        if CGPDFDictionaryGetString(infoDic, "Title", &string) {
            
            if let ref: CFString = CGPDFStringCopyTextString(string!) {
                self.title = ref as String
            }
        }
        
        if CGPDFDictionaryGetString(infoDic, "Author", &string) {
            
            if let ref: CFString = CGPDFStringCopyTextString(string!) {
                self.author = ref as String
            }
        }
        
        if CGPDFDictionaryGetString(infoDic, "Subject", &string) {
            
            if let ref: CFString = CGPDFStringCopyTextString(string!) {
                self.subject = ref as String
            }
        }
        
        if CGPDFDictionaryGetString(infoDic, "Keywords", &string) {
            
            if let ref: CFString = CGPDFStringCopyTextString(string!) {
                self.keywords = ref as String
            }
        }
        
        if CGPDFDictionaryGetString(infoDic, "Creator", &string) {
            
            if let ref: CFString = CGPDFStringCopyTextString(string!) {
                self.creator = ref as String
            }
        }
        
        if CGPDFDictionaryGetString(infoDic, "Producer", &string) {
            
            if let ref: CFString = CGPDFStringCopyTextString(string!) {
                self.producer = ref as String
            }
        }
        
        if CGPDFDictionaryGetString(infoDic, "CreationDate", &string) {
            
            if let ref: CFDate = CGPDFStringCopyDate(string!) {
                self.creationDate = ref as Date
            }
        }
        
        if CGPDFDictionaryGetString(infoDic, "ModDate", &string) {
            
            if let ref: CFDate = CGPDFStringCopyDate(string!) {
                self.modificationDate = ref as Date
            }
        }
        
        //            let majorVersion = UnsafeMutablePointer<Int32>()
        //            let minorVersion = UnsafeMutablePointer<Int32>()
        //            CGPDFDocumentGetVersion(pdfDocRef, majorVersion, minorVersion)
        //            self.version = Float("\(majorVersion).\(minorVersion)")!
        
        self.pageCount = pdfDocRef.numberOfPages
    }
    
    func page(at page: Int) -> CGPDFPage? {
        
        if let documentRef = self.documentRef,
            let pageRef = documentRef.page(at: page) {
            return pageRef
        }
        return nil
    }
    
    static func archiveFilePathForFile(path: String) -> URL {
        let archivePath = try! MZPDFDocument.applicationSupportPath()
        // let archiveName = (path as NSString).lastPathComponent + ".plist"
        let pathURL = URL(string: path)!
        let archiveName = pathURL.lastPathComponent + ".plist"
        return archivePath.appendingPathComponent(archiveName)
        
    }
    
    
    static func unarchiveDocument(filePath: String, password: String?) throws -> MZPDFDocument?
    {
        let archiveFilePath = MZPDFDocument.archiveFilePathForFile(path: filePath)
        
        guard let data =  NSKeyedUnarchiver.unarchiveObject(withFile: archiveFilePath.path) as? Data else {
            return nil
        }
        do {
            let document = try PropertyListDecoder().decode(MZPDFDocument.self, from: data)
            document.fileUrl  = URL(fileURLWithPath: filePath, isDirectory: false)
            document.password = password
            
            try  document.loadDocument()
            return document
        } catch  {
            throw error
        }
    }
    
    public static func from(filePath: String, password: String? = nil) throws -> MZPDFDocument? {
        
        return try MZPDFDocument.unarchiveDocument(filePath: filePath, password: password)
    }
    
    public init(filePath: String, password: String? = nil) throws {
        
        self.guid = MZPDFDocument.GUID()
        self.password = password
        self.fileUrl = URL(fileURLWithPath: filePath, isDirectory: false)
        self.lastOpen = Date()
        
        try self.loadDocument()
        
        self.save()
    }
    
    public init(fileData: Data, password: String? = nil) throws {
        self.guid = MZPDFDocument.GUID()
        self.fileData = fileData
        self.password = password
        self.lastOpen = Date()
        
        try self.loadDocument()
        
        self.save()
    }
    
    
    //MARK: --- Help Methods
    static func GUID() -> String {
        return ProcessInfo.processInfo.globallyUniqueString
    }
    
    public static func applicationSupportPath() throws  -> URL {
        return try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    public static func documentsPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
    public static func applicationPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return (paths.first! as NSString).deletingLastPathComponent
    }
    
    
    func archiveWithFileAtPath(_ filePath: String) -> Bool {
        
        let archiveFilePath = MZPDFDocument.archiveFilePathForFile(path: filePath)
        
        do {
            let data = try PropertyListEncoder().encode(self)
            return NSKeyedArchiver.archiveRootObject(data, toFile: archiveFilePath.path)
        } catch  {
            print(error)
            return false
        }
    }
    
    public func save() {
        //TODO: Better solution to support NSData
        if let filePath = fileUrl?.path {
            let _ = self.archiveWithFileAtPath(filePath)
        }
    }
    
    //MARK: --- Encodabel && Decodable
    enum CodingKeys: String,CodingKey {
        
        case guid
        case currentPage
        case bookmarks
        case lastOpen
        case annotations
        
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(guid, forKey: .guid)
        try container.encode(currentPage, forKey: .currentPage)
        try container.encode(bookmarks, forKey: .bookmarks)
        try container.encode(lastOpen, forKey: .lastOpen)
        try container.encode(annotations, forKey: .annotations)
    }
    
    public required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guid = try container.decode(String.self, forKey: .guid)
        currentPage = try container.decode(Int.self, forKey: .currentPage)
        bookmarks = try container.decode(IndexSet.self, forKey: .bookmarks)
        lastOpen  = try container.decode(Date.self, forKey: .lastOpen)
        annotations =  try container.decode(MZPDFAnnotationStore.self, forKey: .annotations)
    }
    
}

extension MZPDFDocument {
    
    /// Extracts image representations of each page in a background thread and stores them in the cache
    func loadPages() {
        DispatchQueue.global(qos: .background).async {
            for pageNumber in 1...self.pageCount {
                self.imageFromPDFPage(at: pageNumber, callback: { backgroundImage in
                    guard let backgroundImage = backgroundImage else { return }
                    self.images.setObject(backgroundImage, forKey: NSNumber(value: pageNumber))
                })
            }
        }
    }
    
    /// Image representations of all the document pages
    func allPageImages(callback: ([UIImage]) -> Void) {
        var images = [UIImage]()
        var pagesCompleted = 0
        for pageNumber in 0..<pageCount {
            pdfPageImage(at: pageNumber+1, callback: { (image) in
                if let image = image {
                    images.append(image)
                }
                pagesCompleted += 1
                if pagesCompleted == pageCount {
                    callback(images)
                }
            })
        }
    }
    
    /// Image representation of the document page, first looking at the cache, calculates otherwise
    ///
    /// - parameter pageNumber: page number index of the page
    /// - parameter callback: callback to execute when finished
    ///
    /// - returns: Image representation of the document page
    func pdfPageImage(at pageNumber: Int, callback: (UIImage?) -> Void) {
        if let image = images.object(forKey: NSNumber(value: pageNumber)) {
            callback(image)
        } else {
            imageFromPDFPage(at: pageNumber, callback: { image in
                guard let image = image else {
                    callback(nil)
                    return
                }
                
                images.setObject(image, forKey: NSNumber(value: pageNumber))
                callback(image)
            })
        }
    }
    
    /// Grabs the raw image representation of the document page from the document reference
    ///
    /// - parameter pageNumber: page number index of the page
    /// - parameter callback: callback to execute when finished
    ///
    /// - returns: Image representation of the document page
    private func imageFromPDFPage(at pageNumber: Int, callback: (UIImage?) -> Void) {
        guard let page = documentRef?.page(at: pageNumber) else {
            callback(nil)
            return
        }
        
        let originalPageRect = page.originalPageRect
        
        let scalingConstant: CGFloat = 240
        let pdfScale = min(scalingConstant/originalPageRect.width, scalingConstant/originalPageRect.height)
        let scaledPageSize = CGSize(width: originalPageRect.width * pdfScale, height: originalPageRect.height * pdfScale)
        let scaledPageRect = CGRect(origin: originalPageRect.origin, size: scaledPageSize)
        
        // Create a low resolution image representation of the PDF page to display before the TiledPDFView renders its content.
        UIGraphicsBeginImageContextWithOptions(scaledPageSize, true, 1)
        guard let context = UIGraphicsGetCurrentContext() else {
            callback(nil)
            return
        }
        
        // First fill the background with white.
        context.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        context.fill(scaledPageRect)
        
        context.saveGState()
        
        // Flip the context so that the PDF page is rendered right side up.
        let rotationAngle: CGFloat
        switch page.rotationAngle {
        case 90:
            rotationAngle = 270
            context.translateBy(x: scaledPageSize.width, y: scaledPageSize.height)
        case 180:
            rotationAngle = 180
            context.translateBy(x: 0, y: scaledPageSize.height)
        case 270:
            rotationAngle = 90
            context.translateBy(x: scaledPageSize.width, y: scaledPageSize.height)
        default:
            rotationAngle = 0
            context.translateBy(x: 0, y: scaledPageSize.height)
        }
        
        context.scaleBy(x: 1, y: -1)
        context.rotate(by: rotationAngle.degreesToRadians)
        
        // Scale the context so that the PDF page is rendered at the correct size for the zoom level.
        context.scaleBy(x: pdfScale, y: pdfScale)
        context.drawPDFPage(page)
        context.restoreGState()
        
        defer { UIGraphicsEndImageContext() }
        guard let backgroundImage = UIGraphicsGetImageFromCurrentImageContext() else {
            callback(nil)
            return
        }
        
        callback(backgroundImage)
    }
    
}


//  Inspired by https://github.com/Alua-Kinzhebayeva/iOS-PDF-Reader
extension CGPDFPage {
    /// original size of the PDF page.
    var originalPageRect: CGRect {
        switch rotationAngle {
        case 90, 270:
            let originalRect = getBoxRect(.mediaBox)
            let rotatedSize = CGSize(width: originalRect.height, height: originalRect.width)
            return CGRect(origin: originalRect.origin, size: rotatedSize)
        default:
            return getBoxRect(.mediaBox)
        }
    }
}




