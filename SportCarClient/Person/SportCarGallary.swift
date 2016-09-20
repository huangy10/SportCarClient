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
    
    func itemForPage(_ pageNum: Int) -> SportCargallaryItem
}


struct SportCargallaryItem {
    let itemType: String
    var resource: URL? {
        get {
            return URL(string: resourceString)
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
                pageMarker.isHidden = true
            } else {
                pageMarker.isHidden = false
            }
        }
    }
    
    var itemSize: CGSize {
        return dataSource.itemSize()
    }
    
    var pageMarker: UIPageControl!
    var collectionView: UICollectionView!
    
    init(dataSource: SportCarGallaryDataSource) {
        super.init(frame: CGRect.zero)
        self.dataSource = dataSource
        configCollectionView()
        configPageMarker()
        configCells()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configCells() {
        collectionView.register(SportCarGallaryImageCell.self, forCellWithReuseIdentifier: "image")
        collectionView.register(SportCarGallaryVideoCell.self, forCellWithReuseIdentifier: "video")
    }
    
    func configCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let size = dataSource.itemSize()
        layout.itemSize = size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        addSubview(collectionView)
        collectionView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }
    
    func configPageMarker() {
        pageMarker = UIPageControl()
        addSubview(pageMarker)
        pageMarker.layout { (make) in
            make.bottom.equalTo(self)
            make.centerX.equalTo(self)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = dataSource.itemForPage((indexPath as NSIndexPath).row)
        if item.itemType == "image" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as! SportCarGallaryImageCell
            cell.imageView.kf_setImageWithURL(item.resource!, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) in
                cell.imageView.setupForImageViewer(item.resource!, backgroundColor: UIColor.black, fadeToHide: false)
            })
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "video", for: indexPath) as! SportCarGallaryVideoCell
            cell.play(String(format: VIDEO_HTML_TEMPLATE, item.resourceString))
            return cell
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
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
        imageView.contentMode = .scaleAspectFill
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
        webPlayer.scrollView.isScrollEnabled = false
        contentView.addSubview(webPlayer)
        webPlayer.snp_makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
        webPlayer.isHidden = true
    }
    
    func play(_ content: String) {
        // <iframe height=498 width=510 src='http://player.youku.com/embed/XMTcwMTIxODgxMg==' frameborder=0 'allowfullscreen'></iframe>
        if let url = URL(string: content) {
            videoPlayer.view.isHidden = false
            let player = AVPlayer(url: url)
            videoPlayer.player = player
            player.play()
            
            webPlayer.isHidden = true
        } else {
            webPlayer.isHidden = false
            webPlayer.loadHTMLString(content, baseURL: nil)
            
            videoPlayer.view.isHidden = true
        }
    }
}
