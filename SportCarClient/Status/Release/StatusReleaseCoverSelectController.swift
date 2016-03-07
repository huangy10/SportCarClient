//
//  StatusReleaseCoverSelectController.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/13.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Photos
import SnapKit


protocol StatusReleasePhotoSelectDelegate {
    
    /**
     完成了图片筛选的
     
     - parameter images: 选中的图片组
     */
    func photoSelected(images: [UIImage])
    /**
     取消本次选择
     */
    func photeSelectCancelled()
    
}


class StatusReleasePhotoSelectController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    //
    var delegate: StatusReleasePhotoSelectDelegate?
    /// 最大选择的数量
    var maxSelectLimit: Int
    
    var fetchResult: PHFetchResult?
    let photosManager: PHCachingImageManager = PHCachingImageManager.defaultManager() as! PHCachingImageManager
    let contentMode: PHImageContentMode = .AspectFill
    let imageSize = CGSizeMake(100, 100)
    
    var selectedImageRow: [Int] = []
    var selectedImageTasks: [Int: PHImageRequestID] = [:]
    
    var rightNavBtn: UIButton?
    
    convenience init(fetchResult: PHFetchResult, maxSelectLimit: Int) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        
        self.init(collectionViewLayout: layout)
        self.fetchResult = fetchResult
        self.maxSelectLimit = maxSelectLimit
    }
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        maxSelectLimit = 9
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        layout.itemSize = CGSizeMake(screenWidth / 4, screenWidth / 4)
        layout.scrollDirection = .Vertical
        self.init(collectionViewLayout: layout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.registerClass(StatusReleasePhotoSelectCell.self, forCellWithReuseIdentifier: StatusReleasePhotoSelectCell.reuseIdentifier)
        collectionView?.backgroundColor = UIColor.whiteColor()
        navSettings()
    }
    
    func createSubviews() {
        let superview = self.view
        let bottomBar = UIView()
        bottomBar.backgroundColor = UIColor(white: 0.92, alpha: 1)
        superview.addSubview(bottomBar)
        bottomBar.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(superview)
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.height.equalTo(45)
        }
        
        let cancelBtn = UIButton()
        cancelBtn.setTitle(LS("取消"), forState: .Normal)
        cancelBtn.setTitleColor(UIColor(white: 0.72, alpha: 1), forState: .Normal)
        cancelBtn.titleLabel?.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        cancelBtn.addTarget(self, action: "bottomBtnPressed", forControlEvents: .TouchUpInside)
        bottomBar.addSubview(cancelBtn)
        cancelBtn.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(bottomBar)
            make.height.equalTo(bottomBar)
            make.width.equalTo(72)
            make.left.equalTo(bottomBar)
        }
    }
    
    func navSettings() {
        self.navigationItem.title = LS("相机胶卷")
        
        rightNavBtn = UIButton()
        rightNavBtn?.setTitle(LS("确定") + "(0/\(maxSelectLimit))", forState: .Normal)
        rightNavBtn?.setTitleColor(kHighlightedRedTextColor, forState: .Normal)
        rightNavBtn?.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        rightNavBtn?.addTarget(self, action: "navRightBtnPressed", forControlEvents: .TouchUpInside)
        rightNavBtn?.frame = CGRectMake(0, 0, 60, 20)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightNavBtn!)
        
        let leftNavBtn = UIButton()
        leftNavBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        leftNavBtn.frame = CGRectMake(0, 0, 10.5, 18)
        leftNavBtn.addTarget(self, action: "navLeftBtnPressed", forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftNavBtn)
    }
    
    /**
     确定按钮，提取照片并返回
     */
    func navRightBtnPressed() {
        let requestOption = PHImageRequestOptions()
        requestOption.synchronous = true
        requestOption.networkAccessAllowed = true
        
        let screenWidth = UIScreen.mainScreen().bounds.width
        let outputImageSize = CGSizeMake(screenWidth, screenWidth)
        
        var outputImage: [UIImage] = []
        for row: Int in selectedImageRow {
            if let asset = fetchResult![row] as? PHAsset {
                photosManager.requestImageForAsset(asset, targetSize: outputImageSize, contentMode: contentMode, options: requestOption, resultHandler: { (image, info) -> Void in
                    print(info)
                    outputImage.append(image!)
                })
            }
        }
        delegate?.photoSelected(outputImage)
    }
    
    func navLeftBtnPressed() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func bottomBtnPressed() {
        delegate?.photeSelectCancelled()
    }
}


extension StatusReleasePhotoSelectController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return fetchResult!.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StatusReleasePhotoSelectCell.reuseIdentifier, forIndexPath: indexPath) as! StatusReleasePhotoSelectCell
        
        if cell.tag != 0 {
            // 如果检测到cell的tag不为0，这意味着这个cell是复用的，可能有正在pending的请求，将其取消
            photosManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        if let asset = fetchResult![indexPath.row] as? PHAsset {
            cell.tag = Int(photosManager.requestImageForAsset(asset, targetSize: imageSize, contentMode: contentMode, options: nil, resultHandler: { (image, _) -> Void in
                cell.imageView?.image = image
            }))
        }
        
        if selectedImageRow.contains(indexPath.row) {
            cell.setSelected(true, animtated: true)
        }else{
            cell.selectBtn?.selected = false
        }
        cell.backgroundColor = UIColor.redColor()
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let row = indexPath.row
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! StatusReleasePhotoSelectCell
        if selectedImageRow.contains(row) {
            selectedImageRow.remove(row)
            cell.setSelected(false, animtated: true)
        }else {
            // 检查是否已经到了选择上限
            if selectedImageRow.count >= maxSelectLimit {
                displayAlertController(nil, message: "你最多只能选择\(maxSelectLimit)张照片")
                return
            }
            cell.setSelected(true, animtated: true)
            selectedImageRow.append(row)
            let selectedCount = selectedImageRow.count
            rightNavBtn?.setTitle(LS("确定") + "(\(selectedCount)/\(maxSelectLimit))", forState: .Normal)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = self.view.frame.width
        return CGSizeMake(screenWidth / 4 - 8, screenWidth / 4 - 8)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(4, 4, 4, 4)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
}


protocol StatusReleasePhotoSelectCellDelegate {
    func photoSelected(cell: StatusReleasePhotoSelectCell)
}

class StatusReleasePhotoSelectCell: UICollectionViewCell {
    
    static let reuseIdentifier = "status_release_phote_select_cell"
    
    var imageView: UIImageView?
    var selectBtn: UIButton?
    
    var delegate: StatusReleasePhotoSelectCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubivews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func createSubivews() {
        imageView = UIImageView()
        contentView.addSubview(imageView!)
        imageView?.contentMode = .ScaleAspectFill
        imageView?.clipsToBounds = true
        imageView?.snp_makeConstraints(closure: { (make) -> Void in
            make.edges.equalTo(contentView)
        })
        //
        selectBtn = UIButton()
        selectBtn?.addTarget(self, action: "selectBtnPressed", forControlEvents: .TouchUpInside)
        selectBtn?.setImage(UIImage(named: "status_photo_unselected_small"), forState: .Normal)
        selectBtn?.setImage(UIImage(named: "status_photo_selected_small"), forState: .Selected)
        contentView.addSubview(selectBtn!)
        selectBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.size.equalTo(16)
            make.right.equalTo(contentView).offset(-2)
            make.top.equalTo(contentView).offset(2)
        })
    }
    
    func setSelected(selected: Bool, animtated: Bool) {
        selectBtn?.selected = selected
    }
    
    
    func selectBtnPressed() {
        delegate?.photoSelected(self)
    }
}