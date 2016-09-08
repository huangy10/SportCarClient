//
//  SportCarGallary.swift
//  SportCarClient
//
//  Created by 黄延 on 16/8/12.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

protocol SportCarGallaryDataSource: class {
    func numberOfItems() -> Int
    
    func itemSize() -> CGSize
    
    func itemForPage(pageNum: Int) -> SportCargallaryItem
}


struct SportCargallaryItem {
    let itemType: String
    var resource: NSURL? {
        get {
            return NSURL(string: resourceString)
        }
    }
    let resourceString: String
    
    init(itemType: String, resource: String) {
        self.itemType = itemType
        self.resourceString = resource
    }
}

class SportCarGallary: UIView, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    weak var dataSource: SportCarGallaryDataSource! {
        didSet {
            if dataSource.numberOfItems() == 1 {
                pageMarker.hidden = true
            } else {
                pageMarker.hidden = false
            }
        }
    }
    
    var itemSize: CGSize {
        return dataSource.itemSize()
    }
    
    var pageMarker: UIPageControl!
    var collectionView: UICollectionView!
    
    init(dataSource: SportCarGallaryDataSource) {
        super.init(frame: CGRectZero)
        self.dataSource = dataSource
        configCollectionView()
        configPageMarker()
        configCells()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configCells() {
        collectionView.registerClass(SportCarGallaryImageCell.self, forCellWithReuseIdentifier: "image")
        collectionView.registerClass(SportCarGallaryVideoCell.self, forCellWithReuseIdentifier: "video")
    }
    
    func configCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let size = dataSource.itemSize()
        layout.itemSize = size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .Horizontal
        
        collectionView = UICollectionView(frame: CGRectMake(0, 0, size.width, size.height), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.pagingEnabled = true
        addSubview(collectionView)
        collectionView.frame = CGRectMake(0, 0, size.width, size.height)
    }
    
    func configPageMarker() {
        pageMarker = UIPageControl()
        addSubview(pageMarker)
        pageMarker.layout { (make) in
            make.bottom.equalTo(self)
            make.centerX.equalTo(self)
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfItems()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let item = dataSource.itemForPage(indexPath.row)
        if item.itemType == "image" {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("image", forIndexPath: indexPath) as! SportCarGallaryImageCell
            cell.imageView.kf_setImageWithURL(item.resource!, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) in
                cell.imageView.setupForImageViewer(item.resource!, backgroundColor: UIColor.blackColor(), fadeToHide: false)
            })
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("video", forIndexPath: indexPath) as! SportCarGallaryVideoCell
            cell.play("<body style=\"margin:0;\"><iframe style=\"width:375px; height:220px; border:0px; margin:0; padding: 0;\" src='\(item.resourceString)' frameborder=0 'allowfullscreen'></iframe></body>")
            return cell
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let width = scrollView.bounds.width
        let x = scrollView.contentOffset.x
        pageMarker.currentPage = Int(x/width)
    }
    
    func reloadData() {
        pageMarker.numberOfPages = dataSource.numberOfItems()
        collectionView.reloadData()
    }
}

class SportCarGallaryImageCell: UICollectionViewCell {
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configImageView() {
        imageView = contentView.addSubview(UIImageView)
            .layout({ (make) in
                make.edges.equalTo(contentView)
            })
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
    }
}

class SportCarGallaryVideoCell: UICollectionViewCell {
    var videoPlayer: AVPlayerViewController!
    var webPlayer: UIWebView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configVideoPlayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configVideoPlayer() {
        videoPlayer = AVPlayerViewController()
        contentView.addSubview(videoPlayer.view)
        videoPlayer.view.layout { (make) in
            make.edges.equalTo(contentView)
        }
        videoPlayer.showsPlaybackControls = false
        
        webPlayer = UIWebView()
        webPlayer.scrollView.scrollEnabled = false
        contentView.addSubview(webPlayer)
        webPlayer.snp_makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
        webPlayer.hidden = true
    }
    
    func play(content: String) {
        // <iframe height=498 width=510 src='http://player.youku.com/embed/XMTcwMTIxODgxMg==' frameborder=0 'allowfullscreen'></iframe>
        if let url = NSURL(string: content) {
            videoPlayer.view.hidden = false
            let player = AVPlayer(URL: url)
            videoPlayer.player = player
            player.play()
            
            webPlayer.hidden = true
        } else {
            webPlayer.hidden = false
            webPlayer.loadHTMLString(content, baseURL: nil)
            
            videoPlayer.view.hidden = true
        }
    }
}