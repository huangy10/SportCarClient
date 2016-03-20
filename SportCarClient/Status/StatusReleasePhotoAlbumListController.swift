//
//  StatusReleasePhotoAlbumListController.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/13.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Photos


/// 选择照片系统的相册部分的controller
class StatusReleasePhotoAlbumListController: UITableViewController {
    
    /// 代理
    weak var delegate: StatusReleasePhotoSelectDelegate?
    /// 最大选择的照片数量
    var maxSelectLimit: Int
    /// 从照片库里面获取结果
    var fetchResult: [PHFetchResult]
    
    override init(style: UITableViewStyle) {
        
        let fetchOption = PHFetchOptions()
        // 用户定义的智能相册
        let cameraRollResult = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .SmartAlbumUserLibrary, options: fetchOption)
        // 机器创建的相册
        let albumResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOption)
        //
        fetchResult = [cameraRollResult, albumResult]
        //
        maxSelectLimit = 9
        //
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(maxSelectLimit: Int) {
        self.init(style: .Plain)
        self.maxSelectLimit = maxSelectLimit
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(StatusReleasePhotoAlbumListCell.self, forCellReuseIdentifier: StatusReleasePhotoAlbumListCell.reuseIdentifier)
        tableView.rowHeight = 100
        tableView.separatorStyle = .None
        
        navSettings()
    }
    
    convenience init() {
        self.init(style: .Plain)
    }
    
    func navSettings() {
        self.navigationItem.title = LS("相册")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: LS("取消"), style: .Done, target: self, action: "photoSelectCancelled")
    }
    
    func photoSelectCancelled() {
        delegate?.photeSelectCancelled()
    }
    
}

// MARK: - Table相关
extension StatusReleasePhotoAlbumListController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchResult.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResult[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StatusReleasePhotoAlbumListCell.reuseIdentifier, forIndexPath: indexPath) as! StatusReleasePhotoAlbumListCell
        let cachingManager = PHCachingImageManager.defaultManager() as? PHCachingImageManager
        cachingManager?.allowsCachingHighQualityImages = false
        
        if let album = fetchResult[indexPath.section][indexPath.row] as? PHAssetCollection {
            // title
            cell.albumNameLbl?.text = album.localizedTitle
            //
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false)
            ]
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.Image.rawValue)
            
            let result = PHAsset.fetchAssetsInAssetCollection(album, options: fetchOptions)
            cell.photoNumInAlbumLbl?.text = "(\(result.count))"
            
            if let asset = result.firstObject as? PHAsset {
                let imageSize = CGSizeMake(100, 100)
                let imageContentMode: PHImageContentMode = .AspectFill
                PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: imageSize, contentMode: imageContentMode, options: nil, resultHandler: { (image, _) -> Void in
                    cell.imageCover?.image = image
                })
            }
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let album = fetchResult[indexPath.section][indexPath.row] as? PHAssetCollection {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false)
            ]
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.Image.rawValue)
            let detail = StatusReleasePhotoSelectController(fetchResult: PHAsset.fetchAssetsInAssetCollection(album, options: fetchOptions), maxSelectLimit: maxSelectLimit)
            detail.delegate = self.delegate
            self.navigationController?.pushViewController(detail, animated: true)
        }
    }
}


class StatusReleasePhotoAlbumListCell: UITableViewCell {
    static let reuseIdentifier = "status_release_photo_album_list_cell"
    /// 专辑封面
    var imageCover: UIImageView?
    /// 专辑名称
    var albumNameLbl: UILabel?
    /// 专辑里面的数字
    var photoNumInAlbumLbl: UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func createSubviews() {
        let superview = self.contentView
        //
        imageCover = UIImageView()
        imageCover?.clipsToBounds = true
        imageCover?.contentMode = .ScaleAspectFill
        superview.addSubview(imageCover!)
        imageCover?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(superview)
            make.centerY.equalTo(superview)
            make.height.equalTo(superview)
            make.width.equalTo(superview.snp_height)
        })
        //
        albumNameLbl = UILabel()
        albumNameLbl?.font = UIFont.systemFontOfSize(12, weight: UIFontWeightBold)
        albumNameLbl?.textColor = UIColor.blackColor()
        superview.addSubview(albumNameLbl!)
        albumNameLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.centerY.equalTo(superview)
            make.left.equalTo(imageCover!.snp_right).offset(3)
        })
        //
        photoNumInAlbumLbl = UILabel()
        photoNumInAlbumLbl?.textColor = UIColor(white: 0.72, alpha: 1)
        photoNumInAlbumLbl?.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        superview.addSubview(photoNumInAlbumLbl!)
        photoNumInAlbumLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(albumNameLbl!.snp_right)
            make.centerY.equalTo(albumNameLbl!)
        })
        //
        let rightArrow = UIImageView(image: UIImage(named: "account_btn_next_icon"))
        superview.addSubview(rightArrow)
        rightArrow.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(CGSizeMake(9, 15.5))
            make.centerY.equalTo(imageCover!)
            make.right.equalTo(superview).offset(-10)
        }
        //
    }
}
