//
//  MZPDFReaderViewController.swift
//  PDFPrePractice
//
//  Created by mozhe on 2018/11/20.
//  Copyright © 2018 mozhe. All rights reserved.
//

import UIKit
class MZPDFReaderViewController: UIViewController {
    
    let viewModel: MZPDFReaderViewModel
    
    fileprivate lazy var collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }()
    
    fileprivate lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: collectionLayout)
        cv.isPagingEnabled = true
        cv.contentInset = .zero
        cv.isPrefetchingEnabled = true
        cv.delegate = self
        cv.dataSource = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(MZPDFPageCollectionViewCell.self, forCellWithReuseIdentifier: MZPDFPageCollectionViewCell.reuseIdentifier)
        return cv
    }()
    
    //MARK: --- Life Cycle
    init(viewModel: MZPDFReaderViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        
        initBindings()
        
    }
    
    deinit {
        
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        didSelectIndexPath(IndexPath(row: viewModel.currentPageIndex, section: 0))
    }
    override public var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }
    
    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    /// adapt rolate layout
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { context in
            let currentIndexPath = IndexPath(row: self.viewModel.currentPageIndex, section: 0)
            self.collectionView.reloadItems(at: [currentIndexPath])
            self.collectionView.scrollToItem(at: currentIndexPath, at: .centeredHorizontally, animated: false)
        }) { context in
            //            self.thumbnailCollectionController?.currentPageIndex = self.currentPageIndex
        }
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    
    //MARK: --- Private Methods
    private func initViews(){
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
    }
    
    private func initBindings(){
        
        collectionView.backgroundColor = viewModel.backgroundColor
        collectionLayout.scrollDirection = viewModel.scrollDirection
        
    }
    private func  didSelectIndexPath(_ indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
    }
    
    
}

extension MZPDFReaderViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.document.pageCount
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MZPDFPageCollectionViewCell.reuseIdentifier, for: indexPath) as! MZPDFPageCollectionViewCell
        cell.setup(indexPath.row, collectionViewBounds: collectionView.bounds, document: viewModel.document, pageCollectionViewCellDelegate: self)
        return cell
    }
}

extension MZPDFReaderViewController: UICollectionViewDelegate {
    
}

extension MZPDFReaderViewController: MZPDFPageCollectionViewCellDelegate {
    /// Toggles the hiding/showing of the thumbnail controller
    ///
    /// - parameter shouldHide: whether or not the controller should hide the thumbnail controller
    private func hideThumbnailController(_ shouldHide: Bool) {
        //        self.thumbnailCollectionControllerBottom.constant = shouldHide ? -thumbnailCollectionControllerHeight.constant : 0
    }
    
    func handleSingleTap(_ cell: MZPDFPageCollectionViewCell, pdfPageView: MZPDFPageView) {
        var shouldHide: Bool {
            guard let isNavigationBarHidden = navigationController?.isNavigationBarHidden else {
                return false
            }
            return !isNavigationBarHidden
        }
        UIView.animate(withDuration: 0.25) {
            self.hideThumbnailController(shouldHide)
            self.navigationController?.setNavigationBarHidden(shouldHide, animated: true)
        }
    }
}

extension MZPDFReaderViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 1, height: collectionView.frame.height)
    }
}

extension MZPDFReaderViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let updatedPageIndex: Int
        if viewModel.scrollDirection == .vertical {
            updatedPageIndex = Int(round(max(scrollView.contentOffset.y, 0) / scrollView.bounds.height))
        } else {
            updatedPageIndex = Int(round(max(scrollView.contentOffset.x, 0) / scrollView.bounds.width))
        }
        
        if updatedPageIndex != viewModel.currentPageIndex{
            //            if resetZoom {
            //                self.collectionView.reloadItems(at: [IndexPath(item: currentPageIndex, section: 0)])
            //            }
            viewModel.currentPageIndex = updatedPageIndex
            //            thumbnailCollectionController?.currentPageIndex = currentPageIndex
        }
    }
}

