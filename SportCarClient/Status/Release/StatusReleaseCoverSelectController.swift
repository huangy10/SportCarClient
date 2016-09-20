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


protocol StatusReleasePhotoSelectDelegate: class {
    
    /**
     完成了图片筛选的
     
     - parameter images: 选中的图片组
     */
    func photoSelected(_ images: [UIImage])
    /**
     取消本次选择
     */
    func photeSelectCancelled()
    
}


class StatusReleasePhotoSelectController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    //
    weak var delegate: StatusReleasePhotoSelectDelegate?
    /// 最大选择的数量
    var maxSelectLimit: Int
    
    var fetchResult: PHFetchResult<AnyObject>?
    let photosManager: PHCachingImageManager = PHCachingImageManager.default() as! PHCachingImageManager
    let contentMode: PHImageContentMode = .aspectFill
    let imageSize = CGSize(width: 100, height: 100)
    
    var selectedImageRow: [Int] = []
    var selectedImageTasks: [Int: PHImageRequestID] = [:]
    
    var rightNavBtn: UIButton?
    
    convenience init(fetchResult: PHFetchResult<AnyObject>, maxSelectLimit: Int) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
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
        let screenWidth = UIScreen.main.bounds.size.width
        layout.itemSize = CGSize(width: screenWidth / 4, height: screenWidth / 4)
        layout.scrollDirection = .vertical
        self.init(collectionViewLayout: layout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(StatusReleasePhotoSelectCell.self, forCellWithReuseIdentifier: StatusReleasePhotoSelectCell.reuseIdentifier)
        collectionView?.backgroundColor = UIColor.white
        navSettings()
    }
    
    func createSubviews() {
        let superview = self.view
        let bottomBar = UIView()
        bottomBar.backgroundColor = UIColor(white: 0.92, alpha: 1)
        superview?.addSubview(bottomBar)
        bottomBar.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(superview)
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.height.equalTo(45)
        }
        
        let cancelBtn = UIButton()
        cancelBtn.setTitle(LS("取消"), for: UIControlState())
        cancelBtn.setTitleColor(UIColor(white: 0.72, alpha: 1), for: UIControlState())
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        cancelBtn.addTarget(self, action: #selector(StatusReleasePhotoSelectController.bottomBtnPressed), for: .touchUpInside)
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
        rightNavBtn?.setTitle(LS("确定") + "(0/\(maxSelectLimit))", for: UIControlState())
        rightNavBtn?.setTitleColor(kHighlightedRedTextColor, for: UIControlState())
        rightNavBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        rightNavBtn?.addTarget(self, action: #selector(StatusReleasePhotoSelectController.navRightBtnPressed), for: .touchUpInside)
        rightNavBtn?.frame = CGRect(x: 0, y: 0, width: 60, height: 20)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightNavBtn!)
        
        let leftNavBtn = UIButton()
        leftNavBtn.setImage(UIImage(named: "account_header_back_btn"), for: UIControlState())
        leftNavBtn.frame = CGRect(x: 0, y: 0, width: 10.5, height: 18)
        leftNavBtn.addTarget(self, action: #selector(StatusReleasePhotoSelectController.navLeftBtnPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftNavBtn)
    }
    
    /**
     确定按钮，提取照片并返回
     */
    func navRightBtnPressed() {
        let requestOption = PHImageRequestOptions()
        requestOption.isSynchronous = true
        requestOption.isNetworkAccessAllowed = true
        
        let screenWidth = UIScreen.main.bounds.width
        let outputImageSize = CGSize(width: screenWidth, height: screenWidth)
        
        var outputImage: [UIImage] = []
        for row: Int in selectedImageRow {
            if let asset = fetchResult![row] as? PHAsset {
                photosManager.requestImage(for: asset, targetSize: outputImageSize, contentMode: contentMode, options: requestOption, resultHandler: { (image, info) -> Void in
                    outputImage.append(image!)
                })
            }
        }
        delegate?.photoSelected(outputImage)
    }
    
    func navLeftBtnPressed() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func bottomBtnPressed() {
        delegate?.photeSelectCancelled()
    }
}


extension StatusReleasePhotoSelectController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return fetchResult!.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatusReleasePhotoSelectCell.reuseIdentifier, for: indexPath) as! StatusReleasePhotoSelectCell
        
        if cell.tag != 0 {
            // 如果检测到cell的tag不为0，这意味着这个cell是复用的，可能有正在pending的请求，将其取消
            photosManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        if let asset = fetchResult![(indexPath as NSIndexPath).row] as? PHAsset {
            cell.tag = Int(photosManager.requestImage(for: asset, targetSize: imageSize, contentMode: contentMode, options: nil, resultHandler: { (image, _) -> Void in
                cell.imageView?.image = image
            }))
        }
        
        if selectedImageRow.contains((indexPath as NSIndexPath).row) {
            cell.setSelected(true, animtated: true)
        }else{
            cell.selectBtn?.isSelected = false
        }
        cell.backgroundColor = UIColor.red
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let row = (indexPath as NSIndexPath).row
        let cell = collectionView.cellForItem(at: indexPath) as! StatusReleasePhotoSelectCell
        if selectedImageRow.contains(row) {
            selectedImageRow.remove(row)
            cell.setSelected(false, animtated: true)
        }else {
            // 检查是否已经到了选择上限
            if selectedImageRow.count >= maxSelectLimit {
                showToast("你最多只能选择\(maxSelectLimit)张照片")
                return
            }
            cell.setSelected(true, animtated: true)
            selectedImageRow.append(row)
            let selectedCount = selectedImageRow.count
            rightNavBtn?.setTitle(LS("确定") + "(\(selectedCount)/\(maxSelectLimit))", for: UIControlState())
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = self.view.frame.width
        return CGSize(width: screenWidth / 4 - 8, height: screenWidth / 4 - 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(4, 4, 4, 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}


protocol StatusReleasePhotoSelectCellDelegate: class {
    func photoSelected(_ cell: StatusReleasePhotoSelectCell)
}

class StatusReleasePhotoSelectCell: UICollectionViewCell {
    
    static let reuseIdentifier = "status_release_phote_select_cell"
    
    var imageView: UIImageView?
    var selectBtn: UIButton?
    
    weak var delegate: StatusReleasePhotoSelectCellDelegate?
    
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
        imageView?.contentMode = .scaleAspectFill
        imageView?.clipsToBounds = true
        imageView?.snp_makeConstraints(closure: { (make) -> Void in
            make.edges.equalTo(contentView)
        })
        //
        selectBtn = UIButton()
        selectBtn?.addTarget(self, action: #selector(StatusReleasePhotoSelectCell.selectBtnPressed), for: .touchUpInside)
        selectBtn?.setImage(UIImage(named: "status_photo_unselected_small"), for: UIControlState())
        selectBtn?.setImage(UIImage(named: "status_photo_selected_small"), for: .selected)
        contentView.addSubview(selectBtn!)
        selectBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.size.equalTo(16)
            make.right.equalTo(contentView).offset(-2)
            make.top.equalTo(contentView).offset(2)
        })
    }
    
    func setSelected(_ selected: Bool, animtated: Bool) {
        selectBtn?.isSelected = selected
    }
    
    
    func selectBtnPressed() {
        delegate?.photoSelected(self)
    }
}
