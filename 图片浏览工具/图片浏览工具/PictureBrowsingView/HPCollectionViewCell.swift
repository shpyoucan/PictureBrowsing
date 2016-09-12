//
//  HPCollectionViewCell.swift
//  图片浏览工具
//
//  Created by 沈和平 on 16/9/1.
//  Copyright © 2016年 SHP. All rights reserved.
//

import UIKit

class HPCollectionViewCell: UICollectionViewCell {
    
    // 内存保存网络加载的图片
    private var tempSaveUrlImageDic = [String:UIImage]()
    
    /// 默认不缓存本地
    var isCache = false
    
    var pictureBrowsingModel:HPPictureBrowsingModel? {
        
        didSet {
            
            // 还原缩放的图片
            scrollView.zoomScale = 1.0
            
            // 对占位图片处理
            if pictureBrowsingModel!.placeholdImage != nil {
                adjustImageViewAndDisplay(pictureBrowsingModel!.placeholdImage!)
                
            }else {
                adjustImageViewAndDisplay(UIImage(named: "placeholdImage")!)
            }
            
            // 动画loading视图
            loadWithAnimation()
            
            
            // 对加载的图片进行压缩
            if pictureBrowsingModel!.loadImage != nil { // 加载本地图片
                // 开启新线程去压缩图片
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    let compressImage = self.compressImage(self.pictureBrowsingModel!.loadImage!, compressSize: CGSizeZero)
                    
                    // 回归主线程展示图片
                    dispatch_sync(dispatch_get_main_queue(), {
                        self.adjustImageViewAndDisplay(compressImage)
                    })
                })
                
            }else if pictureBrowsingModel!.loadImageUrl != nil { // 加载网络图片
                
                // 先从内存中查找图片是否存在
                if tempSaveUrlImageDic[pictureBrowsingModel!.loadImageUrl!] != nil {
                    let tempSaveImge = tempSaveUrlImageDic[pictureBrowsingModel!.loadImageUrl!]
                    self.adjustImageViewAndDisplay(tempSaveImge!)
                    
                }else {
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        
                        // 存储要展示的图片
                        var dispalyImage = UIImage()
                        
                        // 先去本地缓存中查找是否存在
                        let path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as String
                        let cacheFilePath = path + "/" + self.pictureBrowsingModel!.loadImageUrl!.stringByReplacingOccurrencesOfString("/", withString: "")
                        let localCacheImage = UIImage(contentsOfFile: cacheFilePath)
                        
                        if localCacheImage != nil { // 本地存在
                            dispalyImage = self.compressImage(localCacheImage!, compressSize: CGSizeZero)
                            
                        }else { // 本地不存在, 网络请求图片
                            let imageurl = NSURL(string: self.pictureBrowsingModel!.loadImageUrl!)!
                            let imageData = NSData(contentsOfURL: imageurl)
                            let img = UIImage(data: imageData!)!
                            let compressImage = self.compressImage(img, compressSize: CGSizeZero)
                            
                            dispalyImage = compressImage
                            
                            // 保存内存中
                            self.tempSaveUrlImageDic.updateValue(compressImage, forKey: self.pictureBrowsingModel!.loadImageUrl!)
                            
                            if self.isCache {
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
                                    // 缓存本地
                                    let path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as String
                                    let cacheFilePath = path + "/" + self.pictureBrowsingModel!.loadImageUrl!.stringByReplacingOccurrencesOfString("/", withString: "")
                                    let localImageData = UIImagePNGRepresentation(img)
                                    localImageData!.writeToFile(cacheFilePath, atomically: true)
                                })
                            }
                        }
                        
                        // 回归主线程刷新UI
                        dispatch_sync(dispatch_get_main_queue(), {
                            self.adjustImageViewAndDisplay(dispalyImage)
                        })
                    })
                }
            }
        }
    }
    
    private lazy var scrollView:UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = UIColor.blackColor()
        scroll.minimumZoomScale = 1.0
        scroll.maximumZoomScale = 2.0
        scroll.delegate = self
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.layer.masksToBounds = true
        return scroll
    }()
    
    private lazy var pictureImageV:UIImageView = {
        let imgV = UIImageView()
        imgV.frame = self.scrollView.bounds
        imgV.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.85)
        imgV.userInteractionEnabled = true
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(HPCollectionViewCell.longPressAction(_:)))
        longPressGesture.minimumPressDuration = 1.0
        imgV.addGestureRecognizer(longPressGesture)
        return imgV
    }()
    
    lazy var loadImageView:UIImageView = {
        let imgV = UIImageView(frame: CGRectMake(0, 0, 50, 50))
        imgV.image = UIImage(named: "loadding")
        imgV.backgroundColor = UIColor.clearColor()
        return imgV
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        UIConfig()
    }
    
    private func UIConfig() {
        self.scrollView.frame = CGRectMake(0, 0, self.bounds.width - pictureSpace, self.bounds.height)
        self.contentView.addSubview(scrollView)
        
        scrollView.addSubview(self.pictureImageV)
        
        // 创建loading图
        let loadBGView = UIView(frame: scrollView.bounds)
        loadBGView.backgroundColor = UIColor.clearColor()
        self.addSubview(loadBGView)
        
        loadImageView.center = loadBGView.center
        loadBGView.addSubview(self.loadImageView)
    }
    
    // MARK: - 渲染cell
    private func adjustImageViewAndDisplay(image:UIImage) {
        
        // 停止转圈，并隐藏
        loadImageView.layer.removeAllAnimations()
        loadImageView.superview?.hidden = true
        
        let img = image
        var pictureW = img.size.width
        var pictureH = img.size.height
        
        let divisionW = scrollView.bounds.width / pictureW
        let divisionH = scrollView.bounds.height / pictureH
        
        if divisionW >= 1.0 && divisionH >= 1.0 {
            pictureImageV.frame = CGRectMake(0, 0, pictureW, pictureH)
            
        }else {
            if divisionW > divisionH {
                pictureW = pictureW * divisionH
                pictureH = pictureH * divisionH
                
            }else {
                pictureW = pictureW * divisionW
                pictureH = pictureH * divisionW
            }
            pictureImageV.frame = CGRectMake(0, 0, pictureW, pictureH)
        }
        
        pictureImageV.center = scrollView.center
        
        pictureImageV.image = img
        
    }
    
    // MARK: - 压缩图片（此操作原图片比较大时耗时比较久，建议放入子线程中去执行）
    private func compressImage(oldImage:UIImage, compressSize:CGSize) -> UIImage {
        let compressWidth = oldImage.size.width
        let compressHeight = oldImage.size.height
        
        UIGraphicsBeginImageContext(CGSizeMake(compressWidth, compressHeight))
        oldImage.drawInRect(CGRectMake(0, 0, compressWidth, compressHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
        
    }
    
    // loading转圈动画
    private func loadWithAnimation() {
        
        // 将转圈显示出来
        loadImageView.superview?.hidden = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        
        rotationAnimation.toValue = M_PI * 2
        
        rotationAnimation.duration = 1.5
        
        rotationAnimation.repeatCount = MAXFLOAT
        
        loadImageView.layer.addAnimation(rotationAnimation, forKey: "rotationAnimation")
        
    }
    
   @objc private func longPressAction(gesture:UIGestureRecognizer) {
        
        if gesture.state == .Began {
            print("后续开发")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HPCollectionViewCell: UIScrollViewDelegate {
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return pictureImageV
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        
        let offsetX:CGFloat = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
        let offsetY:CGFloat = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
        
        pictureImageV.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                           scrollView.contentSize.height * 0.5 + offsetY);
    }
}


























