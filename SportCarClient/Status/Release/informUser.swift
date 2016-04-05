//
//  informUser.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/18.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher


class InformOtherUserController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var users: [User] = []
    /// at按钮，表现在UI上面是『@提醒谁看』
    var atBtn: UIButton?
    /// 选中的用户显示在这个横向列表中
    var collectionView: UICollectionView?
    /// 这里采用closure来传递消息
    var onInvokeUserSelectController: ((sender: InformOtherUserController)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
    }
    
    internal func createSubviews() {
        let superview = self.view
        self.view.backgroundColor = UIColor.whiteColor()
        //
        atBtn = UIButton()
        superview.addSubview(atBtn!)
        atBtn?.setTitle(LS("@ 提醒谁看"), forState: .Normal)
        atBtn?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        atBtn?.titleLabel?.textAlignment = .Center
        atBtn?.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        atBtn?.addTarget(self, action: #selector(InformOtherUserController.atBtnPressed), forControlEvents: .TouchUpInside)
        atBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(superview).offset(15)
            make.centerY.equalTo(superview)
            make.size.equalTo(CGSizeMake(75, 35))
        })
        //
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Horizontal
        flowLayout.itemSize = CGSizeMake(35, 35)
        flowLayout.minimumInteritemSpacing = 5
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.delegate = self
        collectionView?.dataSource = self
        superview.addSubview(collectionView!)
        collectionView?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(atBtn!.snp_right).offset(15)
            make.top.equalTo(superview)
            make.bottom.equalTo(superview)
            make.right.equalTo(superview).offset(-15)
        })
        
        collectionView?.registerClass(InformOtherUserCell.self, forCellWithReuseIdentifier: InformOtherUserCell.reuseIdentifier)
    }
    
    func atBtnPressed() {
        if let handler = onInvokeUserSelectController {
            handler(sender: self)
        }else{
            assertionFailure()
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(InformOtherUserCell.reuseIdentifier, forIndexPath: indexPath) as! InformOtherUserCell
        let user = users[indexPath.row]
        cell.user = user
        cell.imageView?.kf_setImageWithURL(user.avatarURL!)
        return cell
    }
}


class InformOtherUserCell: UICollectionViewCell {
    static let reuseIdentifier = "inform_other_user_cell"
    /// 显示用户头像
    var imageView: UIImageView?
    /// 本cell绑定的用户
    var user: User?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func createSubviews() {
        let superview = self.contentView
        //
        imageView = UIImageView()
        imageView?.layer.cornerRadius = 17.5
        imageView?.clipsToBounds = true
        imageView?.backgroundColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(imageView!)
        imageView?.snp_makeConstraints(closure: { (make) -> Void in
            make.edges.equalTo(superview)
        })
    }
}
