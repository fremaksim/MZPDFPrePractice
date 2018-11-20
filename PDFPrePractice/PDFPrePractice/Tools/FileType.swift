//
//  FileType.swift
//  FileReader
//
//  Created by mozhe on 2018/11/6.
//  Copyright © 2018 mozhe. All rights reserved.
//

import Foundation

// inspired from Kingfisher  Image.swift
// reference https://www.garykessler.net/library/file_sigs.html

public enum FileType {
    
    case image(ImageFormat)
    case PDF
    case unSupported
    
    public enum ImageFormat {
        case PNG, JPEG, GIF
    }
    
}

// MARK: - Image format
private struct ImageHeaderData {
    static var PNG: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
    static var JPEG_SOI: [UInt8] = [0xFF, 0xD8]
    static var JPEG_IF: [UInt8] = [0xFF]
    static var GIF: [UInt8] = [0x47, 0x49, 0x46]
    
    static var PDF: [UInt8] = [0x25, 0x50, 0x44, 0x46, 0x2D] //%PDF-
}

public struct FileFormat {
    
    public static func format(with data: NSData) -> FileType {
        
        var buffer = [UInt8](repeating: 0, count: 8)
        data.getBytes(&buffer, length: 8)
        if buffer == ImageHeaderData.PNG {
            return .image(.PNG)
        } else if buffer[0] == ImageHeaderData.JPEG_SOI[0] &&
            buffer[1] == ImageHeaderData.JPEG_SOI[1] &&
            buffer[2] == ImageHeaderData.JPEG_IF[0]
        {
            return .image(.JPEG)
        } else if buffer[0] == ImageHeaderData.GIF[0] &&
            buffer[1] == ImageHeaderData.GIF[1] &&
            buffer[2] == ImageHeaderData.GIF[2]
        {
            return .image(.GIF)
        }else if buffer[0] == ImageHeaderData.PDF[0] &&
            buffer[1] == ImageHeaderData.PDF[1] &&
            buffer[2] == ImageHeaderData.PDF[2] &&
            buffer[3] == ImageHeaderData.PDF[3] &&
            buffer[4] == ImageHeaderData.PDF[4]{
            
            return .PDF
        }
        return .unSupported
    }
    
    public static func format(in filePath: String) -> FileType {
        guard let data = NSData(contentsOfFile: filePath)  else {
            return .unSupported
        }
        return format(with: data)
    }
    
}

/*
 Reader v2.8.6
 #import "ReaderDocument.h"
 #import <fcntl.h>
 
 + (BOOL)isPDF:(NSString *)filePath
 {
 BOOL state = NO;
 
 if (filePath != nil) // Must have a file path
 {
 const char *path = [filePath fileSystemRepresentation];
 
 int fd = open(path, O_RDONLY); // Open the file
 
 if (fd > 0) // We have a valid file descriptor
 {
 const char sig[1024]; // File signature buffer
 
 ssize_t len = read(fd, (void *)&sig, sizeof(sig));
 
 state = (strnstr(sig, "%PDF", len) != NULL);
 
 close(fd); // Close the file
 }
 }
 
 return state;
 }
 */
