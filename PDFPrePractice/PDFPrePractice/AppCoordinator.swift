//
//  AppCordinator.swift
//  PDFPrePractice
//
//  Created by mozhe on 2018/11/6.
//  Copyright © 2018 mozhe. All rights reserved.
//

import UIKit

final class AppCoordinator {
    let splitViewController: UISplitViewController
    
    init(_ splitView: UISplitViewController) {
        splitViewController = splitView
        splitViewController.loadViewIfNeeded()
        

    }
}

