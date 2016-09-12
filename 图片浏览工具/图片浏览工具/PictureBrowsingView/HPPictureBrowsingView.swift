//
//  PictureBrowsingView.swift
//  图片浏览工具
//
//  Created by 沈和平 on 16/8/29.
//  Copyright © 2016年 SHP. All rights reserved.
//

import UIKit

/// （假装）cell左右的间距
let pictureSpace:CGFloat = 15
class HPPictureBrowsingView: UIView {
    
    // 是否缓存本地
    var isLocalCache = false
    
        /// 当前页码
    private var currentPage = 1
    
        /// 加载图片数据源
    private var loadImageData = [AnyObject]()
    
        /// 占位图片数据源
    private var placeholdImageData = [AnyObject]()
    
    let cellID = "cellID"
    private lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        
        let collection = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.delegate = self
        collection.dataSource = self
        collection.pagingEnabled = true
        collection.bounces = false
        collection.registerClass(HPCollectionViewCell.self, forCellWithReuseIdentifier: self.cellID)
        return collection
    }()
    
    private lazy var pictureNumberDesc:UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.blackColor()
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        return label
    }()
    
    // MARK: - 初始化
    init(frame: CGRect, dataSource:[HPPictureBrowsingModel], currentNumber:NSInteger, localCache:Bool) {
        super.init(frame: frame)
        
        // 目的：使得将超出view的cell区域裁剪掉
        self.clipsToBounds = true
        
        self.loadImageData = dataSource
        
        self.isLocalCache = localCache
        
        // 当前页码
        self.currentPage = currentNumber
        
        // 创建UI
        UIConfig()
    }
    
    private func UIConfig() {
        
        let pictureNumberDescH:CGFloat = 30
        
        self.collectionView.frame = CGRectMake(0, 0, self.bounds.width + pictureSpace, self.bounds.height - pictureNumberDescH)
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSizeMake(collectionView.bounds.width, collectionView.bounds.height)
        layout.minimumLineSpacing = 0.0
        collectionView.contentOffset = CGPointMake(CGFloat(currentPage - 1) * collectionView.bounds.width, 0)
        self.addSubview(collectionView)
        
        self.pictureNumberDesc.frame = CGRectMake(0, CGRectGetMaxY(collectionView.frame), collectionView.bounds.width, pictureNumberDescH)
        self.addSubview(pictureNumberDesc)
        self.pictureNumberDesc.text = String(format: "%d/%d", currentPage, self.loadImageData.count)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HPPictureBrowsingView:UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        return loadImageData.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell:HPCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(cellID, forIndexPath: indexPath) as! HPCollectionViewCell
        
        cell.isCache = isLocalCache
        
        let pictureBrowsingModel = loadImageData[indexPath.row] as? HPPictureBrowsingModel
        cell.pictureBrowsingModel = pictureBrowsingModel
        
        return cell
    }
}

extension HPPictureBrowsingView:UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let offPage = Int(scrollView.contentOffset.x / collectionView.bounds.width) + 1
        self.pictureNumberDesc.text = String(format: "%d/%d", offPage, loadImageData.count)
    }
}

































