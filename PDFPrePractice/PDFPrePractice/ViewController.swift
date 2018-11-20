//
//  ViewController.swift
//  PDFPrePractice
//
//  Created by mozhe on 2018/11/2.
//  Copyright © 2018 mozhe. All rights reserved.
//

import UIKit
//import PDFKit
//import QuartzCore

import QuickLook

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let url = Bundle.main.path(forResource: "sample", ofType: "pdf")!
        
        let data = NSData(contentsOfFile: url)
        if let data = data  {
            let type =  FileFormat.format(with: data)
            switch type {
            case .image:
                print("image")
            case .PDF:
                print("PDF")
                //                let document = try! MZPDFDocument(filePath: url, password: "")
                //                print(document.lastOpen)
//               goToQuickLook()
             goToPDFReader(data: data as Data)
                
            case .unSupported:
                print("unSupported")
            }
        }else{
            print("file could not load")
        }
        
    }
    
    private func goToQuickLook(){
        let preViewController = QLPreviewController()
        preViewController.dataSource = self
        navigationController?.pushViewController(preViewController, animated: true)
    }
    
    private func goToPDFReader(data: Data){
        do {
            let document = try MZPDFDocument(fileData: data)
            LogManager.shared.log.info(document.lastOpen ?? "")
            let viewModel = MZPDFReaderViewModel(document: document)
            let vc = MZPDFReaderViewController(viewModel: viewModel)
            navigationController?.pushViewController(vc, animated: true)
        } catch {
            LogManager.shared.log.error(error.localizedDescription)
        }
    }
    
    
}

extension ViewController: QLPreviewControllerDataSource {
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let url = Bundle.main.path(forResource: "sample", ofType: "pdf")!
        
        let urlPath = NSURL(fileURLWithPath: url)
        return urlPath as QLPreviewItem
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
}
