# PictureBrowsing
图片放大浏览

使用说明：
1.创建HPPictureBrowsingModel实例对象；
2.调用HPPictureBrowsingView的初始化方法：init(frame: CGRect, dataSource:[HPPictureBrowsingModel], currentNumber:NSInteger, localCache:Bool)；

使用举例：

         // 加载网络图片
        let loadImageUrlArray = [
            "http://www.bz55.com/uploads/allimg/150414/140-150414102U7.jpg",
            "http://www.bz55.com/uploads/allimg/150708/140-150FQ42011.jpg",
            "http://cache.365jia.com/uploads/10/0927/4ca0469778c38.jpg",
            "http://www.bz55.com/uploads/allimg/150719/139-150G9151227.jpg",
            "http://a.ikafan.com/attachment/forum/201304/06/223247ha510huf5g09f7o5.jpg",
            "http://img1.tgbusdata.cn/thumbnail/jpg/MmMyYyw5NjAsMjAwLDQsMSwxLC0xLDEsMSxyazUw/u/pc.tgbus.com/uploads/allimg/140111/5-140111105518.jpg",
            "http://www.bz55.com/uploads/allimg/150410/139-150410101U6.jpg",
            "http://att.bbs.duowan.com/forum/201503/18/205608ulef6m5uzmrl5uf7.jpg",
            "http://imgsrc.baidu.com/forum/pic/item/4423008d3fea8f6499502724.jpg"
        ]
        
        for i:Int in 0..<loadImageUrlArray.count {
            let imgeUrl = loadImageUrlArray[i]
            let model = HPPictureBrowsingModel()
            model.loadImageUrl = imgeUrl
            // 可设置占位图片
            // model.placeholdImage = UIImage(named: "placeholdImage")
            loadArray.append(model)
        }
        
        let pictureBrowsingView = HPPictureBrowsingView(frame: CGRectMake(0, 20, UIScreen.mainScreen().bounds.width, 400), dataSource: loadArray, currentNumber: 6, localCache:true)
        pictureBrowsingView.backgroundColor = UIColor.whiteColor()
        view.addSubview(pictureBrowsingView) 
    }
