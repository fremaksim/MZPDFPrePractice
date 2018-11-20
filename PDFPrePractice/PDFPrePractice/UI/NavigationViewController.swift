//
//  NavigationViewController.swift
//  PDFPrePractice
//
//  Created by mozhe on 2018/11/6.
//  Copyright © 2018 mozhe. All rights reserved.
//

import UIKit

public class NavigationViewController: UIViewController {
    // Properties
    private let rootViewController: UIViewController
    private var viewControllersToCoordinators: [UIViewController: Coordinator] = [:]
    
    let childNavigationController: UINavigationController
    var viewControllers: [UIViewController] {
        get {return childNavigationController.viewControllers}
        set {childNavigationController.viewControllers = newValue}
    }
    var navigationBar: UINavigationBar {
        return childNavigationController.navigationBar
    }
    var isToolBarHidden: Bool {
        get { return childNavigationController.isToolbarHidden }
        set {childNavigationController.isToolbarHidden = newValue }
    }
    var topViewController: UIViewController? {
        return childNavigationController.topViewController
    }
    
    //MARK: --- Life Cycle
    init(rootViewController: UIViewController = UIViewController()) {
        self.rootViewController = rootViewController
        self.childNavigationController = UINavigationController(rootViewController: rootViewController)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: --- Public
    
    
    
}
