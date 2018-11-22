//
//  MZPDFThumbOperation.swift
//  PDFPrePractice
//
//  Created by mozhe on 2018/11/21.
//  Copyright © 2018 mozhe. All rights reserved.
//

import UIKit

class MZPDFThumbOperation: Operation {
    private(set) var guid: String!
    
    init(guid: String) {
        self.guid = guid
        super.init()
    }
    
    
}
