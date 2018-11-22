//
//  MZPDFThumbQueue.swift
//  PDFPrePractice
//
//  Created by mozhe on 2018/11/22.
//  Copyright © 2018 mozhe. All rights reserved.
//

import UIKit

class MZPDFThumbQueue: NSObject {
    
    private let loadQueue: OperationQueue
    private let workQueue: OperationQueue
    
    static let shared = MZPDFThumbQueue()
    
    override init() {
        loadQueue = OperationQueue()
        loadQueue.name = "MZPDFThumbLoadQueue"
        loadQueue.maxConcurrentOperationCount = 1
        
        workQueue = OperationQueue()
        workQueue.name = "MZPDFThumbWorkQueue"
        loadQueue.maxConcurrentOperationCount = 1
        
        super.init()
        
    }
    
    func addLoadOperation(operation: MZPDFThumbOperation)  {
        loadQueue.addOperation(operation)
    }
    
    func addWorkOperation(operation: MZPDFThumbOperation)  {
        workQueue.addOperation(operation)
    }
    
    func cancelOperation(with guid: String) {
        
        loadQueue.isSuspended = true
        workQueue.isSuspended = true
        
        for operation in loadQueue.operations  {
            if let operation = operation as? MZPDFThumbOperation,
                operation.guid == guid{
                operation.cancel()
            }
        }
        for operation in workQueue.operations where operation is MZPDFThumbOperation {
            if let operation = operation as? MZPDFThumbOperation,
                operation.guid == guid{
                operation.cancel()
            }
        }
        
        loadQueue.isSuspended = false
        workQueue.isSuspended = false
    }
    
    func cancelAllOperations() {
        loadQueue.cancelAllOperations()
        workQueue.cancelAllOperations()
    }

}
