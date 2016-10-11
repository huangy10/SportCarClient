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
    var fetchResult: [PHFetchResult<AnyObject>]
    
    override init(style: UITableViewStyle) {
        
        let fetchOption = PHFetchOptions()
        // 用户定义的智能相册
        let cameraRollResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: fetchOption)
        // 机器创建的相册
        let albumResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOption)
        //
        fetchResult = [cameraRollResult as! PHFetchResult<AnyObject>, albumResult as! PHFetchResult<AnyObject>]
        //
        maxSelectLimit = 9
        //
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(maxSelectLimit: Int) {
        self.init(style: .plain)
        self.maxSelectLimit = maxSelectLimit
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(StatusReleasePhotoAlbumListCell.self, forCellReuseIdentifier: StatusReleasePhotoAlbumListCell.reuseIdentifier)
        tableView.rowHeight = 100
        tableView.separatorStyle = .none
        
        navSettings()
    }
    
    convenience init() {
        self.init(style: .plain)
    }
    
    func navSettings() {
        self.navigationItem.title = LS("相册")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: LS("取消"), style: .done, target: self, action: #selector(StatusReleasePhotoAlbumListController.photoSelectCancelled))
    }
    
    func photoSelectCancelled() {
        delegate?.photeSelectCancelled()
    }
    
}

// MARK: - Table相关
extension StatusReleasePhotoAlbumListController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchResult.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResult[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StatusReleasePhotoAlbumListCell.reuseIdentifier, for: indexPath) as! StatusReleasePhotoAlbumListCell
        let cachingManager = PHCachingImageManager.default() as? PHCachingImageManager
        cachingManager?.allowsCachingHighQualityImages = false
        
        if let album = fetchResult[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row] as? PHAssetCollection {
            // title
            cell.albumNameLbl?.text = album.localizedTitle
            //
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false)
            ]
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            
            let result = PHAsset.fetchAssets(in: album, options: fetchOptions)
            cell.photoNumInAlbumLbl?.text = "(\(result.count))"
            
            if let asset = result.firstObject {
                let imageSize = CGSize(width: 100, height: 100)
                let imageContentMode: PHImageContentMode = .aspectFill
                PHCachingImageManager.default().requestImage(for: asset, targetSize: imageSize, contentMode: imageContentMode, options: nil, resultHandler: { (image, _) -> Void in
                    cell.imageCover?.image = image
                })
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let album = fetchResult[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row] as? PHAssetCollection {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false)
            ]
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            let detail = StatusReleasePhotoSelectController(fetchResult: PHAsset.fetchAssets(in: album, options: fetchOptions) as! PHFetchResult<AnyObject>, maxSelectLimit: maxSelectLimit)
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
        imageCover?.contentMode = .scaleAspectFill
        superview.addSubview(imageCover!)
        imageCover?.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(superview)
            make.centerY.equalTo(superview)
            make.height.equalTo(superview)
            make.width.equalTo(superview.snp.height)
        })
        //
        albumNameLbl = UILabel()
        albumNameLbl?.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightSemibold)
        albumNameLbl?.textColor = UIColor.black
        superview.addSubview(albumNameLbl!)
        albumNameLbl?.snp.makeConstraints({ (make) -> Void in
            make.centerY.equalTo(superview)
            make.left.equalTo(imageCover!.snp.right).offset(3)
        })
        //
        photoNumInAlbumLbl = UILabel()
        photoNumInAlbumLbl?.textColor = kTextGray28
        photoNumInAlbumLbl?.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
        superview.addSubview(photoNumInAlbumLbl!)
        photoNumInAlbumLbl?.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(albumNameLbl!.snp.right)
            make.centerY.equalTo(albumNameLbl!)
        })
        //
        let rightArrow = UIImageView(image: UIImage(named: "account_btn_next_icon"))
        superview.addSubview(rightArrow)
        rightArrow.snp.makeConstraints { (make) -> Void in
            make.size.equalTo(CGSize(width: 9, height: 15.5))
            make.centerY.equalTo(imageCover!)
            make.right.equalTo(superview).offset(-10)
        }
        //
    }
}
