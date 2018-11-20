//
//  Coordinator.swift
//  PDFPrePractice
//
//  Created by mozhe on 2018/11/6.
//  Copyright © 2018 mozhe. All rights reserved.
//

import Foundation

protocol Coordinator: class {
    var coordinators: [Coordinator] { get set }
}

extension Coordinator {
    
    func addCoordinator(_ coordinator: Coordinator) {
        coordinators.append(coordinator)
    }
    
    func removeCoordinator(_ coordinator: Coordinator) {
        coordinators = coordinators.filter { return $0 !== coordinator }
    }
    
    func removeAll() {
        coordinators.removeAll()
    }
    
}
